#!/usr/bin/env python3

import sys
import io

# Fast syntax highlighting with size limits and simpler processing
def fast_highlight(data, filename):
    # Skip highlighting for very large files
    if len(data) > 50000:  # 50KB limit
        return f'<pre>{data}</pre>'
    
    try:
        from pygments import highlight
        from pygments.util import ClassNotFound
        from pygments.lexers import TextLexer, get_lexer_by_name
        from pygments.formatters import HtmlFormatter
        
        # Simple lexer detection based on file extension
        lexer = TextLexer()  # Default fallback
        
        if filename.endswith('.py'):
            lexer = get_lexer_by_name('python')
        elif filename.endswith('.js'):
            lexer = get_lexer_by_name('javascript')
        elif filename.endswith(('.yaml', '.yml')):
            lexer = get_lexer_by_name('yaml')
        elif filename.endswith('.md'):
            lexer = get_lexer_by_name('markdown')
        elif filename.endswith('.sh'):
            lexer = get_lexer_by_name('bash')
        elif filename.endswith('.json'):
            lexer = get_lexer_by_name('json')
        elif filename.endswith(('.html', '.htm')):
            lexer = get_lexer_by_name('html')
        elif filename.endswith('.css'):
            lexer = get_lexer_by_name('css')
        # Add more as needed, but keep it simple
        
        # Use simpler formatter options for speed
        formatter = HtmlFormatter(
            style='default',  # Simpler style
            nobackground=True,
            noclasses=True    # Inline styles instead of CSS classes
        )
        
        # Highlight with timeout protection (will rely on external timeout)
        result = highlight(data, lexer, formatter)
        return result
        
    except Exception:
        # Fast fallback - no error logging to save time
        return f'<pre>{data}</pre>'

def main():
    try:
        # Faster I/O setup
        data = sys.stdin.buffer.read().decode('utf-8', errors='replace')
        filename = sys.argv[1] if len(sys.argv) > 1 else "unknown"
        
        # Process and output
        result = fast_highlight(data, filename)
        sys.stdout.buffer.write(result.encode('utf-8', errors='replace'))
        sys.stdout.buffer.flush()
        
    except Exception:
        # Ultra-fast fallback
        try:
            sys.stdout.buffer.write(f'<pre>{data}</pre>'.encode('utf-8', errors='replace'))
            sys.stdout.buffer.flush()
        except:
            pass

if __name__ == '__main__':
    main()