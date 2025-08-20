#!/usr/bin/env python3

import sys
import io
import traceback

try:
    from pygments import highlight
    from pygments.util import ClassNotFound
    from pygments.lexers import TextLexer
    from pygments.lexers import guess_lexer
    from pygments.lexers import guess_lexer_for_filename
    from pygments.formatters import HtmlFormatter
    PYGMENTS_AVAILABLE = True
except ImportError:
    PYGMENTS_AVAILABLE = False

def safe_highlight(data, filename):
    """Safely highlight code with fallback to plain text"""
    if not PYGMENTS_AVAILABLE:
        return f'<pre>{data}</pre>'
    
    try:
        formatter = HtmlFormatter(style='pastie', nobackground=True)
        
        # Try to guess lexer
        try:
            lexer = guess_lexer_for_filename(filename, data)
        except (ClassNotFound, TypeError):
            if data.startswith('#!'):
                try:
                    lexer = guess_lexer(data)
                except (ClassNotFound, TypeError):
                    lexer = TextLexer()
            else:
                lexer = TextLexer()
        
        # Generate CSS and highlighted content
        css = formatter.get_style_defs('.highlight')
        highlighted = highlight(data, lexer, formatter, outfile=None)
        
        return f'<style>{css}</style>{highlighted}'
        
    except Exception as e:
        # Log error and fallback to plain text
        error_msg = f'<!-- Syntax highlighting error: {str(e)} -->'
        return f'{error_msg}<pre>{data}</pre>'

def main():
    try:
        # Setup UTF-8 handling
        sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8', errors='replace')
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        
        # Read input
        data = sys.stdin.read()
        filename = sys.argv[1] if len(sys.argv) > 1 else "unknown"
        
        # Process and output
        result = safe_highlight(data, filename)
        sys.stdout.write(result)
        sys.stdout.flush()
        
    except Exception as e:
        # Ultimate fallback - output raw content with error
        try:
            error_info = f'<!-- Filter error: {str(e)} -->\n<pre>{data}</pre>'
            sys.stdout.write(error_info)
            sys.stdout.flush()
        except:
            # If even that fails, output nothing rather than crash
            pass

if __name__ == '__main__':
    main()