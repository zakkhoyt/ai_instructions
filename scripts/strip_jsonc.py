#!/usr/bin/env python3
"""Strip JSONC (JSON with Comments) to valid JSON.

Removes:
- Single-line comments: // ...
- Block comments: /* ... */
- Trailing commas before closing braces/brackets

Preserves:
- String literals (including escaped quotes)
- Whitespace structure
"""

import json
import sys
from pathlib import Path


def strip_jsonc(text: str) -> str:
    """Remove comments and trailing commas from JSONC text."""
    result = []
    length = len(text)
    i = 0
    in_string = False
    string_char = ''
    
    while i < length:
        ch = text[i]
        
        # Handle string literals
        if in_string:
            result.append(ch)
            if ch == '\\' and i + 1 < length:
                result.append(text[i + 1])
                i += 2
                continue
            if ch == string_char:
                in_string = False
            i += 1
            continue
        
        # Start of string
        if ch in ('"', "'"):
            in_string = True
            string_char = ch
            result.append(ch)
            i += 1
            continue
        
        # Handle comments
        if ch == '/' and i + 1 < length:
            nxt = text[i + 1]
            # Single-line comment
            if nxt == '/':
                i += 2
                while i < length and text[i] not in '\r\n':
                    i += 1
                continue
            # Block comment
            if nxt == '*':
                i += 2
                while i + 1 < length and not (text[i] == '*' and text[i + 1] == '/'):
                    if text[i] in '\r\n':
                        result.append(text[i])
                    i += 1
                i += 2
                continue
        
        # Handle trailing commas
        if ch == ',':
            k = i + 1
            while k < length and text[k].isspace():
                k += 1
            if k < length and text[k] in '}]':
                i += 1
                continue
        
        result.append(ch)
        i += 1
    
    return ''.join(result)


def main():
    """Read JSONC from source file, validate, and write to dest file."""
    if len(sys.argv) != 3:
        print("Usage: strip_jsonc.py <source_file> <dest_file>", file=sys.stderr)
        sys.exit(1)
    
    source_path = Path(sys.argv[1])
    dest_path = Path(sys.argv[2])
    
    # Read source
    try:
        content = source_path.read_text()
    except OSError as exc:
        print(f"Failed to read {source_path}: {exc}", file=sys.stderr)
        sys.exit(1)
    
    # Strip comments
    clean = strip_jsonc(content)
    
    # Validate JSON
    try:
        json.loads(clean)
    except json.JSONDecodeError as exc:
        print(f"Sanitized JSON is invalid: {exc}", file=sys.stderr)
        sys.exit(1)
    
    # Write output
    try:
        dest_path.write_text(clean)
    except OSError as exc:
        print(f"Failed to write {dest_path}: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
