"""Offline integration tests; every test receives a disposable HOME and kit copy."""
import ast
import hashlib
import importlib.util
import json
import os
import pty
import select
import time
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]


class KitTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workspace = tempfile.TemporaryDirectory(prefix='kit-tests-')
        cls.repo = Path(cls.workspace.name) / "kit with spaces & quote'"
        shutil.copytree(SOURCE, cls.repo, ignore=shutil.ignore_patterns(
            '.git', '.env', '__pycache__', '*.pyc', '*.ep-backup-*', '.tmp',
            '.engineering-productivity*', 'node_modules'))

    @classmethod
    def tearDownClass(cls):
        cls.workspace.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='kit-home-')
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home & quote'"
        self.home.mkdir()
        self.env = {k: v for k, v in os.environ.items() if k not in (
            'CODEX_HOME', 'CLAUDE_CONFIG_DIR', 'PI_CODING_AGENT_DIR', 'XDG_CONFIG_HOME',
            'XDG_CACHE_HOME', 'BASH_ENV', 'ENV', 'GIT_CONFIG_GLOBAL', 'GIT_CONFIG_SYSTEM',
            'GIT_DIR', 'GIT_WORK_TREE')}
        self.env.update(HOME=str(self.home), XDG_CACHE_HOME=str(self.home / '.cache'),
                        GIT_CONFIG_NOSYSTEM='1', PYTHONDONTWRITEBYTECODE='1', TERM='xterm')

    def run_cmd(self, *args, ok=True, cwd=None, data=None, env=None):
        result = subprocess.run(list(map(str, args)), cwd=cwd or self.repo,
                                env=env or self.env, input=data, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=60)
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout)
        return result

    def script(self, path, *args, **kwargs):
        return self.run_cmd('bash', self.repo / path, *args, **kwargs)

    def init_repo(self, name):
        path = self.home / name
        path.mkdir()
        self.run_cmd('git', 'init', '-q', path)
        return path

    def snapshot(self, path):
        return {str(p.relative_to(path)): (os.readlink(p) if p.is_symlink() else
                hashlib.sha256(p.read_bytes()).hexdigest())
                for p in path.rglob('*') if p.is_file() or p.is_symlink()}

    def test_cli_and_syntax(self):
        self.assertEqual(self.script('forge', 'version').stdout.strip(),
                         'forge v' + (self.repo / 'VERSION').read_text().strip())
        for path in self.repo.rglob('*'):
            if not path.is_file() or 'results' in path.relative_to(self.repo).parts:
                continue
            if path.suffix == '.py':
                ast.parse(path.read_bytes(), filename=str(path))
            if path.suffix in ('.sh', '.target') or str(path.relative_to(self.repo)) in (
                'forge', 'bench', 'shell/aliases/al', 'git/hooks/pre-commit', 'git/hooks/pre-push'):
                self.run_cmd('bash', '-n', path)
            if path.suffix == '.json':
                json.loads(path.read_text())
        self.script('forge', '--help')
        self.script('forge', 'status')
        self.script('forge', 'doctor', ok=False)
        self.script('forge', data='', ok=False)
        self.script('forge', 'install', 'shell', data='', ok=False)
        self.script('shell/aliases/al', data='', ok=False)

    def test_ai_render_install_idempotence_and_dry_run(self):
        before = self.snapshot(self.home)
        self.script('ai/scripts/install-global.sh', 'all', '--dry-run')
        self.assertEqual(self.snapshot(self.home), before)
        self.script('ai/scripts/install-global.sh', 'all')
        before = self.snapshot(self.home)
        self.script('ai/scripts/install-global.sh', 'all')
        self.assertEqual(self.snapshot(self.home), before)
        self.assertFalse((self.home / '.claude/settings.json').exists())
        self.assertIn('Global Codex Preferences', (self.home / '.codex/AGENTS.md').read_text())
        for p in self.home.rglob('*'):
            if p.is_file() and p.suffix in ('.md', '.mdc'):
                text = p.read_text()
                self.assertNotIn('{{SKILLS_DIR}}', text)
                self.assertNotIn('moustafa.hakam', text)
        try:
            import tomllib
        except ImportError:
            tomllib = None
        if tomllib:
            for p in (self.home / '.codex/agents').glob('*.toml'):
                self.assertIsInstance(tomllib.loads(p.read_text())['developer_instructions'], str)
        self.script('forge', 'status')
        cursor_rule = self.home / '.cursor/rules/code-review.mdc'
        self.assertIn(str(self.repo / 'ai/shared/skills/code-review/references/mr-review-conventions.md'), cursor_rule.read_text())
        # Doctor should return its dependency status without aborting on empty
        # Cursor agents/commands counts or emitting an unknown function error.
        result = self.run_cmd('bash', self.repo / 'forge', 'doctor', ok=False)
        self.assertNotIn('command not found', result.stdout)

    def test_ai_backups_and_unmanaged_files(self):
        config = self.home / '.claude'
        (config / 'skills/custom').mkdir(parents=True)
        (config / 'CLAUDE.md').write_text('personal instructions')
        (config / 'skills/custom/SKILL.md').write_text('user skill')
        self.script('ai/scripts/install-global.sh', 'claude')
        backups = list(config.glob('CLAUDE.md.ep-backup-*'))
        self.assertEqual([p.read_text() for p in backups], ['personal instructions'])
        self.assertEqual((config / 'skills/custom/SKILL.md').read_text(), 'user skill')

    def test_ai_permission_opt_in_preserves_settings(self):
        config = self.home / '.claude'
        config.mkdir()
        settings = config / 'settings.json'
        settings.write_text(json.dumps({'theme': 'dark', 'permissions': {'allow': ['custom']}}))
        before = settings.read_bytes()
        self.script('ai/scripts/install-global.sh', 'claude')
        self.assertEqual(settings.read_bytes(), before)
        self.script('ai/scripts/install-global.sh', 'claude', '--permissions')
        merged = json.loads(settings.read_text())
        self.assertEqual(merged['theme'], 'dark')
        self.assertIn('custom', merged['permissions']['allow'])
        settings.chmod(0o600)
        self.script('ai/scripts/install-global.sh', 'claude', '--permissions')
        self.assertEqual(settings.stat().st_mode & 0o777, 0o600)
        before = settings.read_bytes()
        self.script('ai/scripts/install-global.sh', 'claude')
        self.assertEqual(settings.read_bytes(), before)
        settings.write_text('{broken JSON')
        before = self.snapshot(config)
        self.script('ai/scripts/install-global.sh', 'claude', '--permissions', ok=False)
        self.assertEqual(self.snapshot(config), before)

    def test_manifest_traversal_is_rejected_before_writes(self):
        config = self.home / '.claude'
        config.mkdir()
        (config / '.engineering-productivity.manifest').write_text('../victim\n')
        victim = self.home / 'victim'
        victim.write_text('keep')
        self.script('ai/scripts/install-global.sh', 'claude', ok=False)
        self.assertEqual(victim.read_text(), 'keep')
        self.assertFalse((config / 'CLAUDE.md').exists())

    def test_symlink_ancestors_do_not_modify_other_locations(self):
        outside = self.home / 'outside'
        outside.mkdir()
        config = self.home / '.claude'
        config.mkdir()
        (config / 'skills').symlink_to(outside, target_is_directory=True)
        self.script('ai/scripts/install-global.sh', 'claude', ok=False)
        self.assertEqual(list(outside.iterdir()), [])
        self.assertFalse((config / 'CLAUDE.md').exists())

    def test_pruning_preserves_locally_modified_files(self):
        self.script('ai/scripts/install-global.sh', 'claude')
        config = self.home / '.claude'
        keep = config / 'skills/retired-custom/SKILL.md'
        clean = config / 'skills/retired-clean/SKILL.md'
        keep.parent.mkdir(); clean.parent.mkdir()
        keep.write_text('original'); clean.write_text('original')
        state_path = config / '.engineering-productivity.state.json'
        state = json.loads(state_path.read_text())
        digest = hashlib.sha256(b'original').hexdigest()
        for p in (keep, clean):
            state['files'][str(p.relative_to(config))] = {'sha256': digest, 'mode': clean.stat().st_mode & 0o777}
        state_path.write_text(json.dumps(state))
        keep.write_text('user changes')
        self.script('ai/scripts/install-global.sh', 'claude')
        self.assertEqual(keep.read_text(), 'user changes')
        self.assertFalse(clean.exists())

    def test_project_templates_and_force_backups(self):
        for target in ('claude', 'codex', 'cursor', 'metwally'):
            project = self.home / target
            project.mkdir()
            self.script('ai/scripts/install-project.sh', target, cwd=project)
            before = self.snapshot(project)
            self.script('ai/scripts/install-project.sh', target, cwd=project, ok=False)
            self.assertEqual(self.snapshot(project), before)
            self.script('ai/scripts/install-project.sh', target, '--force', cwd=project)
            if target == 'cursor':
                # Flattened project rule links must match their generated files.
                self.assertTrue((project / '.cursor/rules/README.mdc').is_file())
            if target in ('codex', 'metwally'):
                (project / 'AGENTS.md').write_text('custom')
                self.script('ai/scripts/install-project.sh', target, '--force', cwd=project)
                self.assertEqual(next(project.glob('AGENTS.md.ep-backup-*')).read_text(), 'custom')
        self.script('ai/scripts/install-project.sh', 'codex', '--invalid', ok=False)
        self.script('ai/scripts/install-global.sh', '../codex', ok=False)

    def test_render_refuses_nonempty_output(self):
        dest = self.home / 'render'
        dest.mkdir()
        (dest / 'personal').write_text('keep')
        self.script('ai/scripts/port.sh', 'codex', '--out', dest, ok=False)
        self.assertEqual(self.snapshot(dest), {'personal': hashlib.sha256(b'keep').hexdigest()})

    def test_shell_all_methods_and_cli_discovery(self):
        unmanaged = self.home / '.bashrc.d/personal.sh'
        unmanaged.parent.mkdir()
        unmanaged.write_text('export PERSONAL_VALUE=ok\n')
        (self.home / '.bashrc').write_text('# personal startup\n')
        for method in ('copy', 'symlink', 'direct', 'copy'):
            self.script('shell/aliases/setup.sh', method)
            result = self.run_cmd('bash', '--noprofile', '--norc', '-c',
                'source "$HOME/.bashrc"; command -v forge al bench; '
                'ai-targets; forge version; [[ "$ENGPROD_DIR" = "$1" ]]', '_', self.repo)
            self.assertNotIn('command not found', result.stdout)
            self.assertEqual(unmanaged.read_text(), 'export PERSONAL_VALUE=ok\n')
            self.assertEqual((self.home / '.bashrc').read_text().count('# >>> engineering-productivity >>>'), 1)
        before = self.snapshot(self.home)
        self.script('shell/aliases/setup.sh', 'copy')
        self.assertEqual(self.snapshot(self.home), before)
        self.assertTrue(any(self.home.glob('.bashrc.ep-backup-*')))

    def test_shell_collision_backup_and_symlink_refusal(self):
        existing = self.home / '.bashrc.d/00-core.sh'
        existing.parent.mkdir()
        existing.write_text('my existing core')
        self.script('shell/aliases/setup.sh', 'copy')
        self.assertEqual(next(existing.parent.glob('00-core.sh.ep-backup-*')).read_text(), 'my existing core')
        outside = self.home / 'outside'
        outside.mkdir()
        shutil.rmtree(self.home / '.bashrc.d')
        (self.home / '.bashrc.d').symlink_to(outside, target_is_directory=True)
        self.script('shell/aliases/setup.sh', 'copy', ok=False)
        self.assertEqual(list(outside.iterdir()), [])

    def test_hooks_explicit_repository_and_worktree(self):
        caller = self.init_repo('caller')
        target = self.init_repo('target')
        self.script('git/hooks/setup.sh', target, cwd=caller)
        self.assertTrue((target / '.git/hooks/pre-commit').is_file())
        self.assertFalse((caller / '.git/hooks/pre-commit').exists())
        self.run_cmd('git', '-C', target, '-c', 'user.name=Test', '-c', 'user.email=test@example.invalid',
                     'commit', '--allow-empty', '-qm', 'baseline')
        worktree = self.home / 'worktree'
        self.run_cmd('git', '-C', target, 'worktree', 'add', '-qb', 'test-worktree', worktree)
        self.script('git/hooks/setup.sh', worktree, cwd=caller)
        self.assertTrue((target / '.git/hooks/pre-push').is_file())

    def test_existing_hooks_policy_is_preserved(self):
        self.run_cmd('git', 'config', '--global', 'core.hooksPath', '/custom/hooks')
        self.script('git/hooks/install-global.sh', ok=False)
        result = self.run_cmd('git', 'config', '--global', 'core.hooksPath')
        self.assertEqual(result.stdout.strip(), '/custom/hooks')

    def test_global_hook_install_backs_up_existing_hooks(self):
        hooks = self.home / '.git-hooks'
        hooks.mkdir()
        (hooks / 'pre-commit').write_text('personal hook')
        self.script('git/hooks/install-global.sh')
        self.assertEqual(next(hooks.glob('pre-commit.ep-backup-*')).read_text(), 'personal hook')
        self.assertEqual(self.run_cmd('git', 'config', '--global', 'core.hooksPath').stdout.strip(), str(hooks))

    def test_hooks_do_not_execute_application_or_write_bytecode(self):
        repo = self.init_repo('hooks-test')
        (repo / 'app.py').write_text('print("legitimate output")\n')
        (repo / 'manage.py').write_text('raise RuntimeError("must never execute")\n')
        self.run_cmd('git', '-C', repo, 'add', '.')
        self.script('git/hooks/pre-commit', cwd=repo)
        self.script('git/hooks/pre-push', cwd=repo)
        self.assertFalse(list(repo.rglob('__pycache__')))
        (repo / 'app.py').write_text('def broken(\n')
        self.script('git/hooks/pre-push', cwd=repo, ok=False)
        (repo / 'credentials.txt').write_text('-----BEGIN PRIVATE KEY-----\n')
        self.run_cmd('git', '-C', repo, 'add', 'credentials.txt')
        self.script('git/hooks/pre-commit', cwd=repo, ok=False)

    def test_browser_configuration_is_data_and_backups_are_preserved(self):
        env_file = self.home / '.env'
        env_file.write_text('GITLAB_URL=gitlab.example.invalid\nCOMPANY_NAME="R&D | Team"\n'
                            'AUTHOR_NAME="$(touch injected)"\nSTORAGE_KEY_PREFIX=ep\n')
        output = self.home / 'userscripts'
        self.script('browser/scripts/setup.sh', '--env', env_file, '--out', output)
        self.assertFalse((self.repo / 'injected').exists())
        generated = list(output.glob('*.js'))
        self.assertEqual(len(generated), 3)
        for p in generated:
            self.assertNotIn('{{GITLAB_URL}}', p.read_text())
            if shutil.which('node'):
                major = int(self.run_cmd('node', '-p', 'process.versions.node.split(".")[0]').stdout.strip())
                if major >= 18:
                    self.run_cmd('node', '--check', p)
        first = generated[0]
        first.write_text('personal custom script')
        self.script('browser/scripts/setup.sh', '--env', env_file, '--out', output)
        self.assertEqual(next(output.glob(first.name + '.ep-backup-*')).read_text(), 'personal custom script')
        before = self.snapshot(output)
        env_file.write_text('GITLAB_URL=bad/path\nCOMPANY_NAME=x\nAUTHOR_NAME=x\nSTORAGE_KEY_PREFIX=ep\n')
        self.script('browser/scripts/setup.sh', '--env', env_file, '--out', output, ok=False)
        self.assertEqual(self.snapshot(output), before)

    def test_optional_installers_reject_bad_arguments_without_side_effects(self):
        before = self.snapshot(self.home)
        self.script('ai/scripts/install-external-skills.sh', '--help')
        self.script('ai/scripts/install-external-skills.sh', 'unknown', ok=False)
        self.script('ai/scripts/install-external-skills.sh', 'cursor', ok=False)
        self.script('extensions/install.sh', '--help')
        self.script('extensions/install.sh', '--invalid', ok=False)
        self.script('extensions/install.sh', '../metwally', ok=False)
        self.assertEqual(self.snapshot(self.home), before)

    def test_real_terminal_menu_refresh(self):
        master, slave = pty.openpty()
        process = subprocess.Popen(['bash', str(self.repo / 'forge'), 'menu'],
                                   cwd=self.repo, env=self.env, stdin=slave, stdout=slave, stderr=slave)
        os.close(slave)
        self.addCleanup(lambda: process.kill() if process.poll() is None else None)
        self.addCleanup(os.close, master)
        output = b''
        def until(marker):
            nonlocal output
            end = time.monotonic() + 10
            while marker not in output:
                if time.monotonic() > end:
                    self.fail('terminal timeout: ' + output.decode(errors='replace')[-2000:])
                ready, _, _ = select.select([master], [], [], 0.2)
                if ready:
                    output += os.read(master, 65536)
        until(b'navigate')
        os.write(master, b'jjjjjj\n')
        until(b'Press Enter to continue')
        output = b''
        os.write(master, b'\n')
        until(b'navigate')
        os.write(master, b'q')
        self.assertEqual(process.wait(timeout=5), 0)
        self.assertNotIn(b'command not found', output)

    @unittest.skipUnless(shutil.which('jq') and shutil.which('bc'), 'benchmark requires jq and bc')
    def test_benchmark_with_stubbed_model_and_failure_reporting(self):
        binary = self.home / 'bin'
        binary.mkdir()
        claude = binary / 'claude'
        payload = json.dumps({'usage': {'input_tokens': 20, 'output_tokens': 10},
                              'total_cost_usd': 0.01, 'duration_ms': 10})
        claude.write_text('#!/bin/sh\n' + "printf '%s\\n' '" + payload + "'\n")
        claude.chmod(0o755)
        env = dict(self.env, PATH=str(binary) + ':' + self.env['PATH'])
        result = self.script('bench', 'fixture task', 'debug', env=env)
        self.assertIn('cost_usd', result.stdout)
        self.assertIn('debug', result.stdout)
        claude.write_text('#!/bin/sh\nexit 1\n')
        self.script('bench', 'fixture failure', env=env, ok=False)
        self.script('bench', 'fixture task', '../invalid', env=env, ok=False)

    def test_destructive_helpers_decline_without_a_terminal(self):
        code = r'''
source shell/aliases/core/core.sh
source shell/aliases/tools/tools.sh
source shell/aliases/git/git.sh
source shell/aliases/docker/docker.sh
marker="$HOME/destructive-command-ran"
rm() { echo called >> "$marker"; }
git() { echo called >> "$marker"; }
docker() { echo called >> "$marker"; }
rmf "$HOME/victim" && exit 9
gpf && exit 9
guncommit-hard && exit 9
dclean && exit 9
dstopall && exit 9
drmall && exit 9
drmfall && exit 9
drmia && exit 9
dvolprune && exit 9
[[ ! -e "$marker" ]]
'''
        self.run_cmd('bash', '--noprofile', '--norc', '-c', code)

    def test_checkpoint_helpers(self):
        script = self.repo / 'ai/shared/skills/checkpoint/scripts/project.py'
        result = self.run_cmd('python3', script, 'mr', data=json.dumps([
            {'iid': 7, 'title': 'Example', 'state': 'opened', 'author': {'username': 'test'},
             'description': 'Closes #8', 'source_branch': 'fix', 'target_branch': 'devel'}]))
        self.assertIn('!7', result.stdout)
        self.assertIn('refs=#8', result.stdout)
        self.run_cmd('python3', script, 'mr', data='not JSON')
        tidy = self.repo / 'ai/shared/skills/checkpoint/scripts/tidy_notes.py'
        result = self.run_cmd('python3', tidy, data='Someone wrote <b>hello</b>\n')
        self.assertIn('Someone wrote hello', result.stdout)


if __name__ == '__main__':
    unittest.main(verbosity=2)
