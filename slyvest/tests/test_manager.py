import importlib.util
import json
import os
from pathlib import Path
import stat
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('manager', Path(__file__).parents[1] / 'manager.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

class SafetyTests(unittest.TestCase):
    def test_private_atomic_handoff_and_permissions(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory = m.private_dir(Path(tmp) / 'runtime')
            target = directory / 'session.json'
            m.atomic_json(target, {'value': 'first'})
            m.atomic_json(target, {'value': 'second'})
            self.assertEqual(m.private_json(target), {'value': 'second'})
            self.assertEqual(stat.S_IMODE(directory.stat().st_mode), 0o700)
            self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o600)
            self.assertEqual(len(list(directory.iterdir())), 1)
            target.chmod(0o644)
            with self.assertRaises(m.SafeError): m.private_json(target)

    def test_handoff_rejects_symlinks(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp)
            (p / 'link').symlink_to(p, target_is_directory=True)
            with self.assertRaises(m.SafeError): m.private_dir(p / 'link')
            m.atomic_json(p / 'file', {})
            (p / 'alias').symlink_to(p / 'file')
            with self.assertRaises(OSError): m.private_json(p / 'alias')

    def test_only_loopback_fragment_capability_is_valid(self):
        token = 'a' * 64
        valid = f'http://127.0.0.1:12345/#session={token}'
        self.assertEqual(m.validate_url(valid)[0], 'http://127.0.0.1:12345')
        for bad in [valid.replace('127.0.0.1', 'localhost'), valid.replace('127.0.0.1', '0.0.0.0'), valid.replace('#session', '?session'), valid.replace('12345', '0'), valid.replace('12345', '99999'), valid + '\n']:
            with self.subTest(bad=bad[:25]), self.assertRaises(m.SafeError): m.validate_url(bad)

    def checks(self, sha):
        return {'total_count': 2, 'check_runs': [dict(name=n, id=i, head_sha=sha, status='completed', conclusion='success', app={'slug':'github-actions'}) for i, n in enumerate(m.JOBS)]}

    def test_gate_requires_merged_main_and_latest_success_for_exact_sha(self):
        sha = 'a' * 40
        checks = self.checks(sha)
        prs = [{'merged_at': 'today', 'merge_commit_sha': sha, 'base': {'ref':'main'}}]
        fetch = lambda endpoint: prs if '/pulls?' in endpoint else checks
        m.reviewed_main(sha, fetch)
        prs[0]['merged_at'] = None
        with self.assertRaises(m.SafeError): m.reviewed_main(sha, fetch)
        prs[0]['merged_at'] = 'today'
        checks['check_runs'][0]['head_sha'] = 'b' * 40
        with self.assertRaises(m.SafeError): m.reviewed_main(sha, fetch)
        checks = self.checks(sha)
        checks['check_runs'].append({**checks['check_runs'][0], 'id':100, 'conclusion':None, 'status':'in_progress'})
        with self.assertRaises(m.SafeError): m.reviewed_main(sha, fetch)

    def test_no_activation_when_build_fails_or_same_sha(self):
        with tempfile.TemporaryDirectory() as tmp:
            cfg = {'state':tmp}
            sha = 'a' * 40
            with patch.object(m, 'fetch_main', return_value=(Path(tmp), sha)), patch.object(m, 'reviewed_main'), patch.object(m, 'activate') as activate:
                with patch.object(m, 'build', side_effect=m.SafeError('build failed')):
                    with self.assertRaises(m.SafeError): m.update(cfg)
                activate.assert_not_called()
                with patch.object(m, 'current', return_value=Path(tmp)), patch.object(m, 'validate_release', return_value={'sha':sha}), patch.object(m, 'build') as build:
                    m.update(cfg)
                    build.assert_not_called()
                    activate.assert_not_called()

    def test_stale_or_inactive_runtime_never_exposes_url(self):
        with tempfile.TemporaryDirectory() as tmp:
            cfg={'journal':'/exact/journal.sqlite', 'runtimeName':'test', 'authoring':False}
            with patch.dict(os.environ, XDG_RUNTIME_DIR=tmp):
                d=m.private_dir(m.runtime(cfg))
                m.atomic_json(d/'session.json', {'url':'http://127.0.0.1:12345/#session='+'a'*64, 'pid':12, 'invocation':'old', 'journal':cfg['journal']})
                for state in [{'ActiveState':'inactive'}, {'ActiveState':'active', 'MainPID':'13', 'InvocationID':'old'}, {'ActiveState':'active', 'MainPID':'12', 'InvocationID':'new'}]:
                    with self.assertRaises(m.SafeError): m.handoff(cfg, state)

    def test_start_only_resets_an_actually_failed_unit(self):
        cfg={'unit':'fixture.service'}
        with patch.object(m, 'unit_info', return_value={'ActiveState':'inactive'}), patch.object(m,'run') as run:
            m.start_unit(cfg)
            run.assert_called_once_with(['systemctl','--user','start','fixture.service'])
        with patch.object(m, 'unit_info', return_value={'ActiveState':'failed'}), patch.object(m,'run') as run:
            m.start_unit(cfg)
            self.assertEqual(run.call_count,2)
            self.assertEqual(run.call_args_list[0].args[0],['systemctl','--user','reset-failed','fixture.service'])

    def test_deployment_lock_excludes_competing_writers(self):
        with tempfile.TemporaryDirectory() as tmp:
            with m.locked({'state':tmp}):
                with self.assertRaises(m.SafeError):
                    with m.locked({'state':tmp}): pass

if __name__ == '__main__': unittest.main()
