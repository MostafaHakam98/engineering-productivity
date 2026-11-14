#!/usr/bin/env python3
"""Install a staged tree, preserving replaced files and locally edited stale files.

Only files recorded with matching fingerprints are pruned. Legacy line manifests
are never trusted for deletion. Destination symlink ancestors are refused.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import tempfile


def relative(value):
    parts = PurePosixPath(value).parts
    if not parts or value.startswith('/') or any(p in ('.', '..') for p in value.split('/')):
        raise ValueError(f'unsafe relative path: {value!r}')
    if '\n' in value or '\t' in value or '\\' in value:
        raise ValueError(f'unsupported path: {value!r}')
    return value


def checked(path, leaf=False):
    path = Path(os.path.abspath(path))
    for parent in reversed((path if leaf else path.parent).parents):
        if parent.is_symlink():
            raise ValueError(f'refusing symlink ancestor: {parent}')
    current = path if leaf else path.parent
    if current.is_symlink():
        raise ValueError(f'refusing symlink ancestor: {current}')
    if path.exists() and path.is_dir() and not path.is_symlink() and not leaf:
        raise ValueError(f'refusing to replace directory: {path}')
    return path


def fingerprint(path):
    if path.is_symlink():
        return {'link': os.readlink(path)}
    if path.is_file():
        return {'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                'mode': stat.S_IMODE(path.stat().st_mode)}
    return None


def atomic_text(path, text):
    checked(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=f'.{path.name}.', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as handle:
            handle.write(text)
        os.replace(name, path)
    finally:
        if os.path.lexists(name):
            os.unlink(name)


def backup(path):
    checked(path)
    if not os.path.lexists(path):
        return
    fd, name = tempfile.mkstemp(prefix=f'{path.name}.ep-backup-', dir=path.parent)
    os.close(fd)
    os.unlink(name)
    # Rename a symlink itself; never follow it into somebody else's files.
    os.replace(path, name)
    print(f'  backup: {name}')


def deploy(stage, destination, prefix='.engineering-productivity', dry_run=False,
           allow_links=False, prune=True, keep=()):
    root = checked(destination, leaf=True)
    if root == Path('/'):
        raise ValueError('refusing filesystem root as install destination')
    manifest = root / f'{prefix}.manifest'
    state_path = root / f'{prefix}.state.json'
    for path in (manifest, state_path):
        checked(path)
        if path.is_symlink():
            raise ValueError(f'refusing symlink metadata: {path}')
    previous = {}
    if state_path.exists():
        state = json.loads(state_path.read_text())
        if state.get('version') != 1 or not isinstance(state.get('files'), dict):
            raise ValueError(f'invalid install state: {state_path}')
        previous = state['files']
    # Validate ALL prior entries before any write, including retained entries.
    for rel in previous:
        checked(root / relative(rel))
    if manifest.exists():
        for rel in manifest.read_text().splitlines():
            if rel:
                checked((root / relative(rel)).parent, leaf=True)
    sources = {}
    for source in sorted(stage.rglob('*')):
        if source.is_dir() and not source.is_symlink():
            continue
        if source.is_symlink() and not allow_links:
            raise ValueError(f'symlink in staged source: {source}')
        if not source.is_file() and not (allow_links and source.is_symlink() and source.is_dir()):
            raise ValueError(f'not a regular staged file: {source}')
        rel = relative(source.relative_to(stage).as_posix())
        checked(root / rel)
        sources[rel] = source
    current = {}
    for rel, source in sources.items():
        dest = root / rel
        desired = fingerprint(source)
        existing = fingerprint(dest)
        # Preserve restrictive permissions on existing regular config files.
        if existing and 'mode' in existing and 'mode' in desired:
            desired['mode'] = existing['mode']
        current[rel] = desired
        if existing == desired:
            continue
        print(f'  install: {dest}')
        if dry_run:
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        if os.path.lexists(dest):
            backup(dest)
        fd, name = tempfile.mkstemp(prefix=f'.{dest.name}.', dir=dest.parent)
        os.close(fd)
        try:
            if source.is_symlink():
                os.unlink(name)
                os.symlink(os.readlink(source), name)
            else:
                shutil.copy2(source, name)
                os.chmod(name, desired['mode'])
            os.replace(name, dest)
        finally:
            if os.path.lexists(name):
                os.unlink(name)
    for rel, old in previous.items():
        if rel in current:
            continue
        dest = root / rel
        if not prune or rel in keep:
            current[rel] = old
        elif fingerprint(dest) == old:
            print(f'  prune unchanged kit file: {dest}')
            if not dry_run:
                dest.unlink()
        elif os.path.lexists(dest):
            print(f'  preserve locally modified file: {dest}')
    if not dry_run:
        atomic_text(manifest, ''.join(f'{p}\n' for p in sorted(current)))
        atomic_text(state_path, json.dumps({'version': 1, 'files': current}, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage', type=Path)
    parser.add_argument('destination', type=Path)
    parser.add_argument('--prefix', default='.engineering-productivity')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--allow-links', action='store_true')
    parser.add_argument('--no-prune', action='store_true')
    parser.add_argument('--keep', action='append', default=[])
    args = parser.parse_args()
    if '/' in args.prefix or args.prefix in ('', '.', '..'):
        parser.error('prefix must be a filename')
    if not args.stage.is_dir():
        parser.error('stage must be a directory')
    try:
        deploy(args.stage, args.destination, args.prefix, args.dry_run, args.allow_links,
               not args.no_prune, args.keep)
    except (OSError, ValueError) as error:
        parser.exit(1, f'install refused: {error}\n')


if __name__ == '__main__':
    main()
