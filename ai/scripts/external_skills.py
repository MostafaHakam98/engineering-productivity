#!/usr/bin/env python3
"""Fetch pinned external skills and install only their declared paths, with backups."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / 'scripts/lib'))
from install_files import checked, deploy, relative


def git(*args):
    return subprocess.check_output(['git', *map(str, args)], text=True, timeout=120).strip()


def target_config(name):
    if not re.fullmatch(r'[a-z][a-z0-9-]*', name):
        raise ValueError(f'invalid target: {name}')
    path = REPO / 'ai/targets' / f'{name}.target'
    if not path.is_file():
        raise ValueError(f'unknown target: {name}')
    result = subprocess.check_output(['bash', '-c', '. "$1"; printf "%s\\0%s" "$SKILLS_DEST" "$SKILLS_FORMAT"', '_', str(path)])
    dest, fmt = result.decode().split('\0')
    if fmt != 'skill-dir':
        raise ValueError(f'{name} does not support external skill directories')
    return checked(dest, leaf=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('targets', nargs='*')
    parser.add_argument('--update', action='store_true', help='refetch pinned revisions (does not change pins)')
    args = parser.parse_args()
    targets = args.targets or [p.stem for p in (REPO / 'ai/targets').glob('*.target')
                              if 'SKILLS_FORMAT="skill-dir"' in p.read_text()]
    destinations = [target_config(name) for name in targets]
    manifest = json.loads((REPO / 'ai/shared/external-skills.json').read_text())
    root = checked(os.path.expanduser(manifest['root']), leaf=True)
    cache = checked(Path(os.environ.get('XDG_CACHE_HOME', Path.home() / '.cache')) /
                    'engineering-productivity/external-skills', leaf=True)
    names = set()
    for source in manifest['sources']:
        if not re.fullmatch(r'[a-z0-9-]+', source['name']):
            raise ValueError('invalid source name')
        if not re.fullmatch(r'[a-f0-9]{40}', source['ref']):
            raise ValueError(f'unpinned source: {source["name"]}')
        if not source['url'].startswith('https://'):
            raise ValueError('external sources must use HTTPS')
        for skill in source['skills']:
            name = relative(skill['name'])
            if '/' in name or name in names:
                raise ValueError(f'duplicate or invalid skill name: {name}')
            relative(skill['path'])
            names.add(name)
    if not shutil.which('git'):
        raise ValueError('git is required')
    with tempfile.TemporaryDirectory(prefix='ep-external-') as tmp:
        stage = Path(tmp) / 'skills'
        stage.mkdir()
        for source in manifest['sources']:
            repo = checked(cache / source['name'], leaf=True)
            if not (repo / '.git').exists():
                cache.mkdir(parents=True, exist_ok=True)
                git('clone', '--quiet', source['url'], repo)
            elif git('-C', repo, 'remote', 'get-url', 'origin') != source['url']:
                raise ValueError(f'cache origin mismatch: {repo}')
            if git('-C', repo, 'status', '--porcelain'):
                raise ValueError(f'cache contains local changes: {repo}')
            if args.update:
                git('-C', repo, 'fetch', '--quiet', 'origin', source['ref'])
            git('-C', repo, 'checkout', '--quiet', '--detach', source['ref'])
            for skill in source['skills']:
                src = checked(repo / skill['path'], leaf=True)
                if not (src / 'SKILL.md').is_file():
                    raise ValueError(f'missing skill at pinned ref: {src}')
                shutil.copytree(src, stage / skill['name'], symlinks=True)
        deploy(stage, root, prefix='.engineering-productivity-external')
        links = Path(tmp) / 'links'
        links.mkdir()
        for name in sorted(names):
            (links / name).symlink_to(root / name, target_is_directory=True)
        for dest in destinations:
            # Never shadow the kit's own skills or an unmanaged directory.
            for name in names:
                link = dest / name
                if link.exists() and not link.is_symlink():
                    raise ValueError(f'existing skill directory; resolve manually: {link}')
            deploy(links, dest, prefix='.engineering-productivity-external-links', allow_links=True)
    print('External skills installed at their pinned revisions.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        raise SystemExit(f'external skill install failed: {error}')
