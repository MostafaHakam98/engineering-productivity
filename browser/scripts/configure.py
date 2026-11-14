#!/usr/bin/env python3
"""Generate userscripts from a deliberately small, non-executable .env format."""
from pathlib import Path
import argparse
import re
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts/lib'))
from install_files import deploy


def configuration(path):
    values = {}
    for number, line in enumerate(path.read_text().splitlines(), 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        key, sep, value = line.partition('=')
        if not sep or not re.fullmatch(r'[A-Z][A-Z0-9_]*', key):
            raise ValueError(f'invalid assignment on line {number}')
        value = value.strip()
        if value[:1] in ('"', "'"):
            if len(value) < 2 or value[-1] != value[0]:
                raise ValueError(f'unbalanced quotes on line {number}')
            value = value[1:-1]
        values[key] = value
    for key in ('GITLAB_URL', 'COMPANY_NAME', 'AUTHOR_NAME', 'STORAGE_KEY_PREFIX'):
        if not values.get(key):
            raise ValueError(f'missing required field: {key}')
    host = re.sub(r'^https?://', '', values['GITLAB_URL']).rstrip('/')
    if not re.fullmatch(r'[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?(?::[0-9]{1,5})?', host):
        raise ValueError('GITLAB_URL must be a hostname with an optional port')
    values['GITLAB_URL'] = host
    prefix = values['STORAGE_KEY_PREFIX'].lower()
    if not re.fullmatch(r'[a-z][a-z0-9_-]{1,15}', prefix):
        raise ValueError('STORAGE_KEY_PREFIX must be 2–16 letters/digits/underscores/hyphens')
    values['STORAGE_KEY_PREFIX'] = prefix
    # These fields appear only in userscript metadata comments.
    for key in ('COMPANY_NAME', 'AUTHOR_NAME'):
        if not values[key].isprintable() or '{{' in values[key]:
            raise ValueError(f'{key} must contain printable text without placeholders')
    values['COMPANY_NAME_LOWER'] = values['COMPANY_NAME'].lower()
    return values


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--env', type=Path, default=ROOT / '.env')
    parser.add_argument('--out', type=Path, default=Path(__file__).resolve().parent)
    args = parser.parse_args()
    values = configuration(args.env)
    with tempfile.TemporaryDirectory(prefix='ep-browser-') as tmp:
        stage = Path(tmp)
        for template in sorted(Path(__file__).resolve().parent.glob('*.js.template')):
            text = template.read_text()
            text = re.sub(r'{{([A-Z_]+)}}', lambda match: values[match[1]], text)
            (stage / template.name.removesuffix('.template')).write_text(text)
        deploy(stage, args.out, prefix='.engineering-productivity-browser')
    print('Generated scripts. Review them before installing in Tampermonkey.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        raise SystemExit(f'configuration refused: {error}')
