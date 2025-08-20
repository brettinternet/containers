#!/usr/bin/env python3

import sys
import io

try:
    # Setup UTF-8 handling
    sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8', errors='replace')
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    
    # Read input
    data = sys.stdin.read()
    filename = sys.argv[1] if len(sys.argv) > 1 else "unknown"
    
    # Output immediately with no processing
    sys.stdout.write(f'<pre>MINIMAL: {filename}\n{data}</pre>')
    sys.stdout.flush()
    
except Exception as e:
    # Write error and exit
    try:
        sys.stdout.write(f'<pre>ERROR: {str(e)}</pre>')
        sys.stdout.flush()
    except:
        pass