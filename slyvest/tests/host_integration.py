"""Host-only test: real native builds, temporary user unit/journal, no private URL output.
Usage: python3 host_integration.py OLD_RELEASE NEW_RELEASE
"""
import importlib.util
import os
from pathlib import Path
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
from unittest.mock import patch

manager = Path(__file__).parents[1] / 'manager.py'
spec = importlib.util.spec_from_file_location('manager', manager)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

def main(a, b):
    ma, mb = m.validate_release(a), m.validate_release(b)
    assert ma['sha'] != mb['sha']
    with tempfile.TemporaryDirectory(prefix='slyvest-host-test-') as tmp:
        root = Path(tmp)
        unit = root.name + '.service'
        db = root / 'journal.sqlite'
        m.run([a/'bin/slyvest','--db',db,'init'])
        before = m.digest(db)
        cfg = dict(journal=str(db), state=str(root/'state'), unit=unit,
            runtimeName=root.name, port=0, authoring=False, backupDirectory=None, readinessTimeout=5)
        m.private_dir(cfg['state'])
        m.atomic_json(root/'config.json',cfg)
        m.publish_link(cfg,'current',a)
        command=[sys.executable,str(manager),'--config',str(root/'config.json')]
        units=Path(os.environ['XDG_RUNTIME_DIR'])/'systemd/user'
        units.mkdir(parents=True,exist_ok=True)
        unit_file=units/unit
        unit_file.write_text('[Unit]\nDescription=Temporary Slyvest test\n[Service]\n'
            'Type=exec\nKillSignal=SIGINT\nKillMode=mixed\nTimeoutStopSec=30\nUMask=0077\nLimitCORE=0\n'
            'RuntimeDirectory='+root.name+'\nRuntimeDirectoryMode=0700\n'
            'ExecStart='+shlex.join(command+['serve'])+'\n'
            'ExecStopPost='+shlex.join(command+['cleanup'])+'\n')
        try:
            m.run(['systemctl','--user','daemon-reload'])
            m.start_unit(cfg)
            m.wait_ready(cfg,ma['sha'])
            first=m.handoff(cfg)
            assert stat.S_IMODE(m.runtime(cfg).stat().st_mode)==0o700
            assert stat.S_IMODE((m.runtime(cfg)/'session.json').stat().st_mode)==0o600
            if os.environ.get('PLAYWRIGHT_MODULE'):
                m.run(['node',manager.parent/'tests/browser_smoke.mjs',m.runtime(cfg)/'session.json'])
                print('PASS: real Chromium, embedded frontend, authenticated loopback, no external requests')
            m.run(['systemctl','--user','stop',unit])
            assert not (m.runtime(cfg)/'session.json').exists()
            try: m.handoff(cfg); raise AssertionError('stopped session accepted')
            except m.SafeError: pass
            m.start_unit(cfg)
            m.wait_ready(cfg,ma['sha'])
            second=m.handoff(cfg)
            assert first['url'] != second['url'] and first['invocation'] != second['invocation']
            assert first['journal']==second['journal']==str(db)
            m.activate(cfg,b)
            third=m.handoff(cfg)
            assert third['sha']==mb['sha'] and third['journal']==str(db)
            with patch.object(m,'fetch_main',return_value=(root,mb['sha'])), patch.object(m,'reviewed_main'):
                m.update(cfg)
            assert m.handoff(cfg)['invocation']==third['invocation']
            with patch.object(m,'fetch_main',return_value=(root,ma['sha'])), patch.object(m,'reviewed_main'), patch.object(m,'build',side_effect=m.SafeError('injected build failure')):
                try: m.update(cfg); raise AssertionError('build failure ignored')
                except m.SafeError: pass
            assert m.current(cfg)==b and m.handoff(cfg)['invocation']==third['invocation']
            broken=root/'broken'
            (broken/'bin').mkdir(parents=True)
            shutil.copy2(a/'bin/slyvest',broken/'bin/slyvest')
            wrapper=broken/'bin/slyvest-viewer'
            wrapper.write_text('#!/bin/sh\nif [ "$1" = "--version" ]; then exec '+shlex.quote(str(a/'bin/slyvest-viewer'))+' --version; fi\nexit 1\n')
            wrapper.chmod(0o755)
            m.atomic_json(broken/'manifest.json',{**ma,'binaries':{name:m.digest(broken/'bin'/name) for name in ['slyvest','slyvest-viewer']}})
            try: m.activate(cfg,broken); raise AssertionError('bad readiness accepted')
            except m.SafeError: pass
            restored=m.handoff(cfg)
            assert m.current(cfg)==b and restored['sha']==mb['sha'] and restored['journal']==str(db)
            m.activate(cfg,m.current(cfg,'previous'))
            assert m.handoff(cfg)['sha']==ma['sha']
            assert m.digest(db)==before
            logs=m.run(['journalctl','--user','--unit',unit,'--no-pager','--output=cat'])
            assert '#session=' not in logs and 'Bearer ' not in logs
            for session in (first,second,third,restored):
                assert m.validate_url(session['url'])[1] not in logs
            print('PASS: start/stop/restart, two SHAs, no-op, build failure, readiness rollback, explicit rollback, permissions, token-free logs, unchanged journal')
            powershell='/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe'
            if Path(powershell).is_file():
                origin,_=m.validate_url(m.handoff(cfg)['url'])
                script="$ProgressPreference='SilentlyContinue'; (Invoke-WebRequest -UseBasicParsing -Uri '"+origin+"/').StatusCode"
                try:
                    code=m.run([powershell,'-NoProfile','-NonInteractive','-Command',script],timeout=20)
                    print('Windows loopback HTTP:', 'PASS' if code.strip()=='200' else 'not verified')
                except m.SafeError: print('Windows loopback HTTP: unavailable; manual check needed')
        finally:
            subprocess.run(['systemctl','--user','stop',unit],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            subprocess.run(['systemctl','--user','reset-failed',unit],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
            unit_file.unlink(missing_ok=True)
            subprocess.run(['systemctl','--user','daemon-reload'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)

if __name__=='__main__': main(Path(sys.argv[1]),Path(sys.argv[2]))
