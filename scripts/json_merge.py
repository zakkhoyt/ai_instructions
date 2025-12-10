#!/usr/bin/env python3
"""JSON Merge Utility - Apply template data onto an existing JSON document.

PURPOSE:
    Safely compose VS Code templates with workspace or user settings files by
    performing a deep merge on JSON structures. Dictionaries merge recursively
    while arrays and primitives are replaced by template values.

USAGE:
    >>> from pathlib import Path
    >>> from json_merge import merge_files
    >>> merge_files(Path("dest.json"), Path("template.json"), Path("output.json"))

KEY DEPENDENCIES:
    - json: Parses and serializes JSON documents with indentation control
    - logging: Provides structured diagnostics for CLI consumers
    - strip_jsonc: Reuses the local sanitizer to accept JSONC inputs

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
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any, Sequence

from strip_jsonc import sanitize_jsonc_text

LOGGER = logging.getLogger(__name__)
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
JSONValue = dict[str, Any] | list[Any] | str | int | float | bool | None


def configure_logging(debug: bool = False) -> None:
    """Configure root logging handlers.

    Args:
        debug: When True, emit DEBUG statements; otherwise INFO.

    References:
        - Python logging HOWTO: https://docs.python.org/3/howto/logging.html
    """

    logging.basicConfig(level=logging.DEBUG if debug else logging.INFO, format=LOG_FORMAT)


def load_jsonc(path: Path) -> JSONValue:
    """Load JSON content from `path`, accepting JSONC input.

    Args:
        path: File to read.

    Returns:
        Parsed Python data structure representing the JSON document.

    Raises:
        RuntimeError: If the file cannot be read or parsed.

    References:
        - pathlib.Path#read_text: https://docs.python.org/3/library/pathlib.html
        - json library: https://docs.python.org/3/library/json.html
    """

    try:
        raw_text = path.read_text(encoding="utf-8")
    except OSError as exc:
        msg = f"Failed to read {path}: {exc}"
        LOGGER.error(msg)
        raise RuntimeError(msg) from exc

    sanitized = sanitize_jsonc_text(raw_text)

    try:
        return json.loads(sanitized)
    except json.JSONDecodeError as exc:
        msg = f"Invalid JSON after sanitizing {path}: {exc}"
        LOGGER.error(msg)
        raise RuntimeError(msg) from exc


def merge_values(existing: JSONValue, template: JSONValue) -> JSONValue:
    """Deep-merge dictionaries and replace other JSON node types.

    Args:
        existing: Destination data structure.
        template: Template data to overlay atop `existing`.

    Returns:
        A new data structure representing `existing` merged with `template`.

    References:
        - JSON data model: https://www.json.org/json-en.html
    """

    if isinstance(existing, dict) and isinstance(template, dict):
        merged: dict[str, JSONValue] = deepcopy(existing)
        for key, value in template.items():
            if key in merged:
                merged[key] = merge_values(merged[key], value)
            else:
                merged[key] = deepcopy(value)
        return merged

    return deepcopy(template)


def write_json(data: JSONValue, path: Path, indent: int = 2) -> None:
    """Write JSON data to disk with the given indentation.

    Args:
        data: Parsed JSON content.
        path: Output file path.
        indent: Number of spaces to use for indentation.

    References:
        - json.dump: https://docs.python.org/3/library/json.html#json.dump
    """

    try:
        with path.open("w", encoding="utf-8") as handle:
            json.dump(data, handle, indent=indent)
            handle.write("\n")
    except OSError as exc:
        msg = f"Failed to write {path}: {exc}"
        LOGGER.error(msg)
        raise RuntimeError(msg) from exc


def merge_files(destination: Path, template: Path, output: Path, indent: int = 2) -> None:
    """Merge JSON files and persist the merged output.

    Args:
        destination: Path to the base JSON/JSONC document.
        template: Path to the template JSON/JSONC document.
        output: File path where the merged content will be written.
        indent: Indentation width for serialization.

    References:
        - pathlib.Path: https://docs.python.org/3/library/pathlib.html
    """

    dest_data = load_jsonc(destination)
    template_data = load_jsonc(template)
    merged = merge_values(dest_data, template_data)
    write_json(merged, output, indent=indent)


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for the merge utility.

    Args:
        argv: Optional sequence of CLI args.

    Returns:
        Namespace with destination, template, output, indent, and debug flags.

    References:
        - argparse module: https://docs.python.org/3/library/argparse.html
    """

    parser = argparse.ArgumentParser(description="Merge JSON/JSONC documents")
    parser.add_argument("--destination", required=True, type=Path, help="Existing JSON/JSONC file")
    parser.add_argument("--template", required=True, type=Path, help="Template JSON/JSONC file")
    parser.add_argument("--output", required=True, type=Path, help="Path for merged output")
    parser.add_argument("--indent", type=int, default=2, help="Output indentation (default: 2)")
    parser.add_argument("--debug", action="store_true", help="Enable verbose logging")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    """Run the merge utility CLI.

    Args:
        argv: Optional argument vector.

    Returns:
        Process exit status code (0 on success).

    References:
        - sys.exit: https://docs.python.org/3/library/sys.html#sys.exit
    """

    args = parse_args(argv)
    configure_logging(debug=args.debug)
    LOGGER.info("Merging template %%s into %%s", args.template, args.destination)

    try:
        merge_files(args.destination, args.template, args.output, indent=args.indent)
    except RuntimeError:
        return 1

    LOGGER.info("Wrote merged JSON to %%s", args.output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
