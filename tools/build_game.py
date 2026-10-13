#!/usr/bin/env python3
"""Turn the web version of Castaway (a single HTML file) into the offline index.html bundled in the app.

Usage:  python3 tools/build_game.py path/to/castaway-island.html
Writes: Castaway/Game/index.html
It swaps the CDN script tags and Google Fonts link for the local copies in Castaway/Game/lib and Castaway/Game/fonts.
"""
import re, sys, pathlib
root = pathlib.Path(__file__).resolve().parent.parent
src = pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')

src = re.sub(r'<link rel="preconnect"[^>]*>\s*', '', src)
src, n_font = re.subn(r'<link rel="stylesheet" href="https://fonts\.googleapis\.com[^"]*">', '<link rel="stylesheet" href="fonts/fonts.css">', src)
src, n_three = re.subn(r'<script src="https://[^"]*three\.min\.js"></script>', '<script src="lib/three.min.js"></script>', src)
src, n_bgu = re.subn(r'<script src="https://[^"]*BufferGeometryUtils\.js"></script>', '<script src="lib/BufferGeometryUtils.js"></script>', src)
assert n_font == 1 and n_three == 1 and n_bgu == 1, (n_font, n_three, n_bgu)
assert 'https://' not in re.sub(r'<!--.*?-->', '', src, flags=re.S).split('<script>')[0], 'an external resource is still referenced in the head'

head = '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
<meta name="format-detection" content="telephone=no">
<style>html,body{-webkit-touch-callout:none;-webkit-user-select:none;user-select:none;-webkit-text-size-adjust:100%;overscroll-behavior:none}</style>
'''
# the web version is a body fragment: split it into head (title, links, style) and body (markup, scripts)
cut = src.index('</style>') + len('</style>')
out = head + src[:cut] + '\n</head>\n<body>\n' + src[cut:] + '\n</body>\n</html>\n'
(root / 'Castaway' / 'Game' / 'index.html').write_text(out, encoding='utf-8')
print('wrote', root / 'Castaway' / 'Game' / 'index.html', len(out), 'bytes')
