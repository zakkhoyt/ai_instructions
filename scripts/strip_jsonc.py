#!/usr/bin/env python3
"""JSONC Sanitizer - Convert JSON with comments into strict JSON.

PURPOSE:
    Provide a reusable helper that strips line/block comments and trailing
    commas from JSON-with-comments (JSONC) files so downstream tooling can
    safely parse them using Python's standard `json` module.

USAGE:
    >>> from pathlib import Path
    >>> from strip_jsonc import sanitize_jsonc_file
    >>> sanitize_jsonc_file(Path("settings.jsonc"), Path("settings.json"))

KEY DEPENDENCIES:
    - json: validates sanitized content using the standard library parser
    - logging: emits structured diagnostics rather than print statements
    - pathlib.Path: handles filesystem interactions in a cross-platform way

COMPATIBILITY:
    Python 3.11+
    Tested on: Python 3.11 on macOS

Author: GitHub Copilot
Date: 2025-12-09
"""

from __future__ import annotations

import argparse
import json
import logging
import re
import sys
from pathlib import Path
from typing import Sequence

LOGGER = logging.getLogger(__name__)
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
TRAILING_COMMA_PATTERN = re.compile(r",(?P<ws>\s*)(?=[}\]])")


def configure_logging(debug: bool = False) -> None:
    """Configure module-wide logging handlers.

    Args:
        debug: When True, enable verbose DEBUG output; otherwise INFO.

    References:
        - Python logging HOWTO: https://docs.python.org/3/howto/logging.html
    """

    logging.basicConfig(level=logging.DEBUG if debug else logging.INFO, format=LOG_FORMAT)


def sanitize_jsonc_text(text: str) -> str:
    """Remove comments and trailing commas from JSONC text.

    Args:
        text: Raw JSONC content that may contain comments or trailing commas.

    Returns:
        Comment-free JSON text compatible with `json.loads`.

    References:
        - JSON grammar overview: https://www.json.org/json-en.html
        - Escaped characters: https://docs.python.org/3/reference/lexical_analysis.html
    """

    result: list[str] = []
    length = len(text)
    index = 0
    in_string = False
    string_char = ""

    while index < length:
        ch = text[index]

        if in_string:
            result.append(ch)
            if ch == "\\" and index + 1 < length:
                result.append(text[index + 1])
                index += 2
                continue
            if ch == string_char:
                in_string = False
            index += 1
            continue

        if ch in ('"', "'"):
            in_string = True
            string_char = ch
            result.append(ch)
            index += 1
            continue

        if ch == "/" and index + 1 < length:
            nxt = text[index + 1]
            if nxt == "/":
                index += 2
                while index < length and text[index] not in "\r\n":
                    index += 1
                continue
            if nxt == "*":
                index += 2
                while index + 1 < length and not (text[index] == "*" and text[index + 1] == "/"):
                    if text[index] in "\r\n":
                        result.append(text[index])
                    index += 1
                index += 2
                continue

        if ch == ",":
            lookahead = index + 1
            while lookahead < length and text[lookahead].isspace():
                lookahead += 1
            if lookahead < length and text[lookahead] in "}]":
                index += 1
                continue

        result.append(ch)
        index += 1

    sanitized = "".join(result)
    return remove_trailing_commas(sanitized)


def remove_trailing_commas(text: str) -> str:
    """Remove commas that appear immediately before a closing bracket/brace.

    Args:
        text: JSON text that may contain trailing commas.

    Returns:
        JSON string with trailing commas removed while preserving whitespace.

    References:
        - Regular expressions: https://docs.python.org/3/howto/regex.html
    """

    return TRAILING_COMMA_PATTERN.sub(lambda match: match.group("ws"), text)


def sanitize_jsonc_file(source_path: Path, dest_path: Path) -> None:
    """Read JSONC from `source_path` and write sanitized JSON to `dest_path`.

    Args:
        source_path: Path to the JSONC input file.
        dest_path: Output path for comment-free JSON.

    Raises:
        RuntimeError: If the input cannot be read, parsed, or written.

    References:
        - pathlib.Path API: https://docs.python.org/3/library/pathlib.html
        - json.loads documentation: https://docs.python.org/3/library/json.html
    """

    try:
        raw_text = source_path.read_text(encoding="utf-8")
    except OSError as exc:
        msg = f"Failed to read {source_path}: {exc}"
        LOGGER.error(msg)
        raise RuntimeError(msg) from exc

    clean_text = sanitize_jsonc_text(raw_text)

    try:
        json.loads(clean_text)
    except json.JSONDecodeError as exc:
        msg = f"Sanitized JSON is invalid: {exc}"
        LOGGER.error(msg)
        raise RuntimeError(msg) from exc

    try:
        dest_path.write_text(clean_text, encoding="utf-8")
    except OSError as exc:
        msg = f"Failed to write {dest_path}: {exc}"
        LOGGER.error(msg)
        raise RuntimeError(msg) from exc


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Build and parse command-line arguments for the sanitizer CLI.

    Args:
        argv: Optional list of raw argument strings.

    Returns:
        Parsed arguments containing input/output paths and debug flag.

    References:
        - argparse tutorial: https://docs.python.org/3/library/argparse.html
    """

    parser = argparse.ArgumentParser(description="Strip comments from JSONC files")
    parser.add_argument("source", type=Path, help="Path to the JSONC source file")
    parser.add_argument("dest", type=Path, help="Destination path for sanitized JSON")
    parser.add_argument("--debug", action="store_true", help="Enable verbose logging output")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    """Entry point for the CLI driver.

    Args:
        argv: Optional argument vector (defaults to sys.argv[1:]).

    Returns:
        Zero on success, non-zero when sanitization fails.

    References:
        - sys.exit semantics: https://docs.python.org/3/library/sys.html#sys.exit
    """

    args = parse_args(argv)
    configure_logging(debug=args.debug)
    LOGGER.info("Sanitizing JSONC file: %%s", args.source)

    try:
        sanitize_jsonc_file(args.source, args.dest)
    except RuntimeError:
        return 1

    LOGGER.info("Wrote sanitized JSON to %%s", args.dest)
    return 0


if __name__ == "__main__":
    sys.exit(main())
