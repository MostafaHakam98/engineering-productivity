#!/usr/bin/env python3
"""Stage shell startup, aliases, and CLI launchers with recoverable replacements."""
import argparse
import os
from pathlib import Path
import shlex
import shutil
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent / 'lib'))
from install_files import checked, deploy


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('method', choices=['copy', 'symlink', 'direct'], nargs='?', default='copy')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parent.parent
    home = Path(os.environ['HOME'])
    bashrc = checked(home / '.bashrc')
    if bashrc.is_symlink():
        parser.error('~/.bashrc is a symlink; merge the loader manually instead')
    original = bashrc.read_text() if bashrc.exists() else ''
    begin, end = '# >>> engineering-productivity >>>', '# <<< engineering-productivity <<<'
    if original.count(begin) != original.count(end) or original.count(begin) > 1:
        parser.error('malformed managed block in ~/.bashrc; resolve manually')
    if begin in original:
        start = original.index(begin)
        stop = original.index(end, start) + len(end)
        original = original[:start] + original[stop:].lstrip('\n')
    with tempfile.TemporaryDirectory(prefix='ep-shell-') as tmp:
        stage = Path(tmp)
        aliases = repo / 'shell/aliases'
        if args.method != 'direct':
            for line in (aliases / 'load-order.conf').read_text().splitlines():
                if not line.strip() or line.lstrip().startswith('#'):
                    continue
                num, category, filename = line.split(':')
                src = aliases / category / filename
                dest = stage / '.bashrc.d' / f'{num}-{filename}'
                dest.parent.mkdir(exist_ok=True)
                if args.method == 'symlink':
                    dest.symlink_to(src)
                else:
                    shutil.copy2(src, dest)
        for name, script in [('forge', 'forge'), ('al', 'shell/aliases/al'), ('bench', 'bench')]:
            dest = stage / '.local/bin' / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text('#!/usr/bin/env bash\nexec bash ' + shlex.quote(str(repo / script)) + ' "$@"\n')
            dest.chmod(0o755)
        block = [begin, 'export ENGPROD_DIR=' + shlex.quote(str(repo)),
                 'case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac']
        if args.method == 'direct':
            block += ['if [ -r "$ENGPROD_DIR/shell/aliases/loader.sh" ]; then',
                      '  source "$ENGPROD_DIR/shell/aliases/loader.sh"', 'fi']
        else:
            # Source only this kit's files; unrelated ~/.bashrc.d files remain
            # under the user's own startup configuration.
            for line in (aliases / 'load-order.conf').read_text().splitlines():
                if not line.strip() or line.lstrip().startswith('#'):
                    continue
                num, _, filename = line.split(':')
                path = f'"$HOME/.bashrc.d/{num}-{filename}"'
                block += [f'if [ -r {path} ]; then source {path}; fi']
        block += [end, '']
        (stage / '.bashrc').write_text(original.rstrip('\n') + '\n\n' + '\n'.join(block))
        deploy(stage, home, prefix='.engineering-productivity-shell', allow_links=True)
    print('Shell installed. Open a new Bash terminal or run: source ~/.bashrc')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as error:
        raise SystemExit(f'shell install refused: {error}')
