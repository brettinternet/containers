#!/usr/bin/env python3

import sys
import io

# Simple filter that just wraps content in <pre> tags
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8', errors='replace')
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

data = sys.stdin.read()
filename = sys.argv[1] if len(sys.argv) > 1 else "unknown"

# Add markers to see where truncation occurs
lines = data.split('\n')
output = f'<pre>FILTER DEBUG START: {filename} ({len(lines)} lines, {len(data)} chars)\n'

for i, line in enumerate(lines, 1):
    output += f'LINE{i:03d}: {line}\n'
    if i % 10 == 0:  # Add markers every 10 lines
        output += f'--- MARKER AT LINE {i} ---\n'

output += 'FILTER DEBUG END</pre>'
sys.stdout.write(output)
sys.stdout.flush()