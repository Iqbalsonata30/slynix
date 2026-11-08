"""Personal Slyvest supervisor/deployer. Never print child output or capability in diagnostics."""
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import shutil
import signal
import stat
import subprocess
import sys
import tempfile
import time
import tomllib
import urllib.error
import urllib.request

UPSTREAM = 'https://github.com/Iqbalsonata30/slyvest.git'
API = 'https://api.github.com/repos/Iqbalsonata30/slyvest'
JOBS = {'Format, Clippy and Tests', 'Linux package and extracted journal recovery acceptance'}
SHA = re.compile(r'[0-9a-f]{40}\Z')
URL = re.compile(r'http://127\.0\.0\.1:([0-9]{1,5})/#session=([0-9a-f]{64})\Z')

class SafeError(Exception):
    pass

def run(args, **kwargs):
    # Command arguments never include a capability. Suppress subprocess stderr so
    # callers only expose fixed safe messages (not SQLite/HTTP bodies or notes).
    try:
        return subprocess.check_output([str(a) for a in args], stderr=subprocess.DEVNULL, **kwargs).decode().strip()
    except (OSError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        raise SafeError('A local command failed; existing journal data was not replaced.') from None

def private_dir(path):
    path = Path(path)
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    info = path.lstat()
    if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.getuid():
        raise SafeError('Private directory has an unsafe owner or file type.')
    path.chmod(0o700)
    return path

def atomic_json(path, value):
    path = Path(path)
    fd, tmp = tempfile.mkstemp(prefix='.pending-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as out:
            os.fchmod(out.fileno(), 0o600)
            json.dump(value, out)
            out.flush()
            os.fsync(out.fileno())
        os.replace(tmp, path)
    finally:
        Path(tmp).unlink(missing_ok=True)

def private_json(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(fd) as src:
        info = os.fstat(src.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o600:
            raise SafeError('Runtime handoff permissions are unsafe.')
        return json.load(src)

def unit_info(cfg):
    out = run(['systemctl', '--user', 'show', cfg['unit'], '--property=ActiveState,MainPID,InvocationID'])
    return dict(line.split('=', 1) for line in out.splitlines() if '=' in line)

def runtime(cfg):
    root = os.environ.get('XDG_RUNTIME_DIR')
    if not root or not Path(root).is_dir():
        raise SafeError('No user runtime directory; start this from the active user session.')
    return Path(root) / cfg['runtimeName']

def validate_url(url):
    match = URL.fullmatch(url)
    if not match or not 1 <= int(match[1]) <= 65535:
        raise SafeError('Viewer did not provide a valid loopback session.')
    return url.split('/#')[0], match[2]

def http(url, endpoint='/api/health'):
    origin, token = validate_url(url)
    request = urllib.request.Request(origin + endpoint, headers={
        'Authorization': 'Bearer ' + token, 'Origin': origin,
        'Sec-Fetch-Site': 'same-origin',
    })
    # No proxy receives local capabilities, even if the shell has proxy variables.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with opener.open(request, timeout=2) as response:
        if response.headers.get('Cache-Control') != 'no-store':
            raise SafeError('Viewer response lacks its expected privacy headers.')
        return json.load(response)

def handoff(cfg, info=None):
    info = info or unit_info(cfg)
    if info.get('ActiveState') != 'active':
        raise SafeError('Viewer service is not active; no session URL is available.')
    try:
        value = private_json(runtime(cfg) / 'session.json')
        if str(value['pid']) != info['MainPID'] or value['invocation'] != info['InvocationID'] or value['journal'] != cfg['journal']:
            raise SafeError('Session is stale; wait for this service invocation to become ready.')
        validate_url(value['url'])
        if http(value['url'])['read_only'] != (not cfg['authoring']):
            raise SafeError('Viewer mode does not match configuration.')
        return value
    except (OSError, ValueError, KeyError, urllib.error.URLError):
        raise SafeError('Viewer session is not ready. Check service status; do not reuse an old URL.') from None

def digest(path):
    with open(path, 'rb') as src:
        return hashlib.file_digest(src, 'sha256').hexdigest()

def validate_release(path):
    try:
        data = json.loads((path / 'manifest.json').read_text())
        if not SHA.fullmatch(data['sha']):
            raise ValueError()
        for binary in ('slyvest', 'slyvest-viewer'):
            target = path / 'bin' / binary
            if digest(target) != data['binaries'][binary] or run([target, '--version']) != f"{binary} {data['version']} (build {data['sha']})":
                raise SafeError('Installed executable identity does not match its validated release.')
        return data
    except (OSError, ValueError, KeyError):
        raise SafeError('No validated release is available. Run slyvest-update first.') from None

def current(cfg, name='current'):
    link = Path(cfg['state']) / name
    return link.resolve() if link.is_symlink() else None

def publish_link(cfg, name, release):
    root = private_dir(cfg['state'])
    tmp = root / ('.' + name + '-' + str(os.getpid()))
    try:
        tmp.symlink_to(release)
        os.replace(tmp, root / name)
    finally:
        tmp.unlink(missing_ok=True)

@contextlib.contextmanager
def locked(cfg):
    root = private_dir(cfg['state'])
    with open(root / 'deployment.lock', 'a') as lock:
        os.chmod(root / 'deployment.lock', 0o600)
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise SafeError('Another update or activation is in progress.') from None
        yield

def stop_child(child):
    if child.poll() is None:
        child.send_signal(signal.SIGINT)
        try:
            child.wait(timeout=20)
        except subprocess.TimeoutExpired:
            child.kill()
            child.wait()

def launch(binary, args, timeout, stopped=lambda: False):
    child = subprocess.Popen([str(binary), *args], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout, selectors.EVENT_READ)
            data = b''
            deadline = time.monotonic() + timeout
            while time.monotonic() < deadline and child.poll() is None and not stopped():
                if selector.select(0.1):
                    data += os.read(child.stdout.fileno(), 1024)
                    if len(data) > 1024:
                        raise SafeError('Unexpected viewer startup output was suppressed.')
                    if b'\n' in data:
                        url = data.split(b'\n')[0].decode('ascii')
                        validate_url(url)
                        while time.monotonic() < deadline and child.poll() is None and not stopped():
                            try:
                                health = http(url)
                                return child, url, health
                            except (OSError, ValueError, urllib.error.URLError):
                                time.sleep(0.1)
                        break
        raise SafeError('Viewer failed readiness. Check the existing journal, schema and chosen port; no journal was initialized or migrated.')
    except BaseException:
        stop_child(child)
        raise

def cleanup(cfg):
    (runtime(cfg) / 'session.json').unlink(missing_ok=True)

def serve(cfg):
    directory = private_dir(runtime(cfg))
    cleanup(cfg)
    child = None
    stopping = False
    def shutdown(_sig, _frame):
        nonlocal stopping
        stopping = True
        if child and child.poll() is None:
            child.send_signal(signal.SIGINT)
    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)
    try:
        release = current(cfg)
        if release is None:
            raise SafeError('No installed release; stage and activate a reviewed main build first.')
        meta = validate_release(release)
        if not Path(cfg['journal']).is_file():
            raise SafeError('Configured journal is missing. No replacement will be created.')
        args = ['--db', cfg['journal'], '--port', str(cfg['port'])]
        if cfg['authoring']:
            args.append('--enable-authoring')
        if cfg['backupDirectory']:
            args.extend(['--backup-dir', cfg['backupDirectory']])
        child, url, health = launch(release / 'bin/slyvest-viewer', args, cfg['readinessTimeout'], lambda: stopping)
        if stopping or health['read_only'] != (not cfg['authoring']):
            raise SafeError('Startup interrupted or mode mismatch; session was not published.')
        atomic_json(directory / 'session.json', {
            'url': url, 'pid': os.getpid(), 'invocation': os.environ['INVOCATION_ID'],
            'journal': cfg['journal'], 'sha': meta['sha'],
        })
        print('Slyvest ready; private session available through slyvest-url.', flush=True)
        # Drain all subsequent stdout without logging it, even if a future binary
        # prints another credential. Do not allow a full pipe to block shutdown.
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout, selectors.EVENT_READ)
            while child.poll() is None and not stopping:
                if selector.select(0.2):
                    os.read(child.stdout.fileno(), 4096)
        if stopping:
            stop_child(child)
        elif child.returncode:
            raise SafeError('Viewer exited unexpectedly; its runtime handoff was removed.')
    finally:
        cleanup(cfg)
        if child:
            stop_child(child)

def github_json(endpoint):
    # Reuse gh's existing user credential/keyring for private repositories.
    # No GitHub credential is copied into Nix, the journal or integration state.
    if shutil.which('gh'):
        try:
            return json.loads(run(['gh', 'api', 'repos/Iqbalsonata30/slyvest' + endpoint],
                env={**os.environ, 'GH_PROMPT_DISABLED': '1'}, timeout=20))
        except (SafeError, ValueError):
            pass
    request = urllib.request.Request(API + endpoint, headers={'Accept': 'application/vnd.github+json', 'User-Agent': 'slyvest-personal-updater'})
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            return json.load(response)
    except (OSError, ValueError, urllib.error.URLError):
        raise SafeError('Cannot verify GitHub merge/check status (network or rate limit). Nothing was activated.') from None

def reviewed_main(sha, fetch=github_json):
    prs = fetch(f'/commits/{sha}/pulls?per_page=100')
    if not any(p.get('merged_at') and p.get('merge_commit_sha') == sha and p['base']['ref'] == 'main' for p in prs):
        raise SafeError('This main SHA has no confirmed merged-main PR. No PR branch is deployed.')
    checks = fetch(f'/commits/{sha}/check-runs?per_page=100')
    if checks['total_count'] > 100:
        raise SafeError('Check history exceeds the bounded audit; inspect it before activation.')
    latest = {}
    for check in checks['check_runs']:
        if check['app']['slug'] == 'github-actions' and check['head_sha'] == sha:
            if check['name'] not in latest or check['id'] > latest[check['name']]['id']:
                latest[check['name']] = check
    if not all(name in latest and latest[name]['status'] == 'completed' and latest[name]['conclusion'] == 'success' for name in JOBS):
        raise SafeError('Required exact-main checks are missing, pending or failed. Nothing was activated.')

def fetch_main(cfg):
    root = private_dir(cfg['state'])
    repo = root / 'source.git'
    if not repo.exists():
        run(['git', 'init', '--bare', repo])
        run(['git', '--git-dir', repo, 'remote', 'add', 'origin', UPSTREAM])
    if run(['git', '--git-dir', repo, 'remote', 'get-url', 'origin']) != UPSTREAM:
        raise SafeError('Updater origin differs from the configured upstream.')
    run(['git', '--git-dir', repo, 'fetch', '--no-tags', 'origin', '+refs/heads/main:refs/remotes/origin/main'])
    sha = run(['git', '--git-dir', repo, 'rev-parse', 'refs/remotes/origin/main'])
    if not SHA.fullmatch(sha):
        raise SafeError('Invalid fetched main identity.')
    atomic_json(root / 'origin-main.json', {'sha': sha, 'fetched_at': int(time.time())})
    return repo, sha

def smoke(release):
    # Temporary test journal only. Capture all viewer output including synthetic
    # capabilities; retain neither URL nor domain data in build reports.
    with tempfile.TemporaryDirectory(prefix='slyvest-smoke-') as tmp:
        db = Path(tmp) / 'journal.sqlite'
        cli = release / 'bin/slyvest'
        run([cli, '--db', db, 'init'])
        before = digest(db)
        subprocess.run([str(cli), '--db', str(db), 'init'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        if digest(db) != before:
            raise SafeError('Synthetic smoke: init changed an existing journal.')
        child, url, health = launch(release / 'bin/slyvest-viewer', ['--db', str(db)], 15)
        try:
            if health['read_only'] is not True or health['schema_version'] != 3:
                raise SafeError('Synthetic smoke: unexpected viewer mode/schema.')
            origin, _ = validate_url(url)
            with urllib.request.build_opener(urllib.request.ProxyHandler({})).open(origin, timeout=3) as response:
                if b'/app.js' not in response.read():
                    raise SafeError('Synthetic smoke: missing embedded frontend.')
            for asset in ('/app.js', '/style.css'):
                with urllib.request.build_opener(urllib.request.ProxyHandler({})).open(origin + asset, timeout=3) as response:
                    if not response.read(1):
                        raise SafeError('Synthetic smoke: empty embedded asset.')
            http(url, '/api/journal/summary')
        finally:
            stop_child(child)
        run([cli, '--db', db, 'journal', 'verify'])
        if digest(db) != before:
            raise SafeError('Synthetic read-only smoke changed the journal bytes.')

def build(cfg, repo, sha):
    root = private_dir(Path(cfg['state']) / 'releases')
    release = root / sha
    if (release / 'manifest.json').exists():
        validate_release(release)
        return release
    release.mkdir(mode=0o700, exist_ok=True)
    # A failed build can be retried without removing developer files. Worktrees
    # are owned only by this separate bare repository.
    source = release / 'source'
    if not source.exists():
        run(['git', '--git-dir', repo, 'worktree', 'add', '--detach', source, sha])
    if run(['git', '-C', source, 'rev-parse', 'HEAD']) != sha or run(['git', '-C', source, 'status', '--porcelain']):
        raise SafeError('Updater checkout is not clean; inspect its private release directory.')
    version = tomllib.loads((source / 'crates/slyvest-cli/Cargo.toml').read_text())['package']['version']
    viewer_version = tomllib.loads((source / 'crates/slyvest-viewer/Cargo.toml').read_text())['package']['version']
    if version != viewer_version:
        raise SafeError('CLI/viewer manifest versions disagree.')
    print(f'Building reviewed origin/main {sha} with pinned native Nix tools.', flush=True)
    log = release / 'build.log'
    with open(log, 'w') as out:
        os.chmod(log, 0o600)
        result = subprocess.run(['nix', 'develop', '--accept-flake-config', '--profile', str(release / 'toolchain'),
            'path:' + cfg['buildFlake'], '--command', 'bash', cfg['builder'], str(source), str(release), sha], stdout=out, stderr=subprocess.STDOUT)
    if result.returncode:
        raise SafeError(f'Candidate build/check failed. Existing service was not restarted. Build log: {log}')
    for binary in ('slyvest', 'slyvest-viewer'):
        if run([release / 'bin' / binary, '--version']) != f'{binary} {version} (build {sha})':
            raise SafeError('Candidate binary identity mismatch. Nothing was activated.')
    smoke(release)
    atomic_json(release / 'manifest.json', {'sha': sha, 'version': version,
        'binaries': {b: digest(release / 'bin' / b) for b in ('slyvest', 'slyvest-viewer')}})
    return release

def wait_ready(cfg, sha):
    deadline = time.monotonic() + cfg['readinessTimeout'] + 3
    while time.monotonic() < deadline:
        try:
            info = unit_info(cfg)
            if info.get('ActiveState') == 'failed':
                break
            if handoff(cfg, info)['sha'] == sha:
                return
        except SafeError:
            pass
        time.sleep(0.2)
    raise SafeError('Candidate did not become ready; restoring the previous release.')

def start_unit(cfg):
    # systemd may unload inactive units; reset-failed then fails unnecessarily.
    if unit_info(cfg).get('ActiveState') == 'failed':
        run(['systemctl', '--user', 'reset-failed', cfg['unit']])
    run(['systemctl', '--user', 'start', cfg['unit']])

def activate(cfg, release):
    data = validate_release(release)
    old = current(cfg)
    try:
        if old == release and handoff(cfg)['sha'] == data['sha']:
            print('Already running this SHA; no restart.')
            return
    except SafeError:
        pass
    run(['systemctl', '--user', 'stop', cfg['unit']])
    publish_link(cfg, 'current', release)
    try:
        start_unit(cfg)
        wait_ready(cfg, data['sha'])
    except SafeError:
        run(['systemctl', '--user', 'stop', cfg['unit']])
        if old:
            publish_link(cfg, 'current', old)
            start_unit(cfg)
            wait_ready(cfg, validate_release(old)['sha'])
        else:
            (Path(cfg['state']) / 'current').unlink(missing_ok=True)
        raise SafeError('Activation failed; previous installation restored using the same journal. No data repair/migration was attempted.') from None
    if old and old != release:
        publish_link(cfg, 'previous', old)
    print('Activated ' + data['sha'] + '. Use slyvest-url for the new private session.')

def update(cfg, requested=None):
    with locked(cfg):
        repo, sha = fetch_main(cfg)
        reviewed_main(sha)
        old = current(cfg)
        if old and validate_release(old)['sha'] == sha:
            if requested:
                if requested != sha:
                    raise SafeError('Requested activation is not current origin/main.')
                activate(cfg, old)
            else:
                print('Installed SHA already equals origin/main; no build or restart.')
            return
        if requested and requested != sha:
            raise SafeError('Requested activation is not current origin/main; inspect the new main before proceeding.')
        release = build(cfg, repo, sha)
        if requested:
            activate(cfg, release)
        else:
            print(f'Candidate ready: {sha}. Service unchanged. After saving/closing editors, run slyvest-update --activate {sha}')

def status(cfg):
    try:
        with locked(cfg):
            _, sha = fetch_main(cfg)
        source = sha
    except SafeError:
        source = 'unavailable (cannot fetch current origin/main)'
    installed = current(cfg)
    print('origin/main: ' + source)
    print('installed: ' + (validate_release(installed)['sha'] if installed else 'none'))
    try:
        active = handoff(cfg)
        print('running: ' + active['sha'])
    except SafeError:
        print('running: not ready/inactive (no usable session)')
    if SHA.fullmatch(source):
        try:
            reviewed_main(source)
            print('main gate: merged PR and required exact-SHA checks successful')
        except SafeError as e:
            print('main gate: ' + str(e))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', required=True)
    parser.add_argument('action', choices=['serve', 'cleanup', 'url', 'status', 'update', 'rollback', 'smoke'])
    parser.add_argument('--activate', metavar='MAIN_SHA')
    parser.add_argument('--release', type=Path)
    args = parser.parse_args()
    try:
        cfg = json.loads(Path(args.config).read_text())
        if args.action == 'serve': serve(cfg)
        elif args.action == 'cleanup': cleanup(cfg)
        elif args.action == 'url': print(handoff(cfg)['url'])
        elif args.action == 'status': status(cfg)
        elif args.action == 'update': update(cfg, args.activate)
        elif args.action == 'smoke': smoke(args.release)
        elif args.action == 'rollback':
            with locked(cfg):
                previous = current(cfg, 'previous')
                if not previous: raise SafeError('No previous validated release is retained.')
                activate(cfg, previous)
    except (SafeError, OSError, ValueError, KeyError) as e:
        print(str(e) if isinstance(e, SafeError) else 'Integration operation failed safely; inspect configuration and service state. No journal was replaced.', file=sys.stderr)
        return 1
    return 0

if __name__ == '__main__':
    sys.exit(main())
