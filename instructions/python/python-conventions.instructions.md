````instructions
---
applyTo: "**/*.py"
---

# Python Development Conventions

**Applies to**: All Python files (`**/*.py`) in this repository

This document establishes conventions for developing Python code in this repository. These conventions ensure consistent code quality, maintainability, and debugging capabilities.

---

## ⚡ Quick Compliance Checklist

When writing or modifying **ANY** Python code in this repository, ensure:

- ✅ **Type hints used** - All function parameters and return values annotated
- ✅ **Docstrings present** - All modules, classes, and functions documented
- ✅ **Logging configured** - Use Python `logging` module, not `print()` statements
- ✅ **Debug flag controlled** - Use log levels (DEBUG, INFO, WARNING, ERROR) appropriately
- ✅ **PEP 8 compliant** - Follow Python style guide for formatting
- ✅ **Error handling complete** - Use try/except with specific exceptions
- ✅ **Constants uppercase** - Use `UPPER_SNAKE_CASE` for constants
- ✅ **Imports organized** - Group stdlib, third-party, and local imports

## File Structure

### Required Files

- **`module_name.py`**: Main Python module
- **`README.md`**: Project documentation and usage instructions
- **`requirements.txt`**: Python dependencies (if applicable)
- **`tests/`**: Test files using pytest or unittest

### Directory Layout

```
project_name/
├── module_name.py
├── README.md
├── requirements.txt
├── tests/
│   ├── __init__.py
│   └── test_module_name.py
├── logs/              # Git-ignored log files
│   └── app.log
└── reference/         # Optional: reference implementations or examples
```

## Module Header

### Required Documentation

All Python modules must include a module-level docstring at the top of the file:

```python
"""Module Name - Brief Description

PURPOSE:
    Detailed explanation of what this module does and how it improves functionality.
    Describe the problem it solves and the value it provides.

USAGE:
    Basic usage examples showing how to import and use the module:
    
    >>> from module_name import main_function
    >>> result = main_function(arg1, arg2)
    >>> print(result)

KEY DEPENDENCIES:
    - requests: HTTP library for API calls
    - pandas: Data manipulation and analysis
    - typing: Type hint support

COMPATIBILITY:
    Python 3.9+
    Tested on: Python 3.11 on macOS, Linux, Windows

Author: Your Name
Date: YYYY-MM-DD
"""

from __future__ import annotations

import logging
from typing import Optional, Union
```

**Header docstring guidelines**:

- **PURPOSE**: Explain the "why" - what problem does this solve?
- **USAGE**: Provide quick examples for common use cases
- **KEY DEPENDENCIES**: List critical external libraries with brief descriptions
- **COMPATIBILITY**: Document Python version requirements and tested environments

## Code Style

### PEP 8 Compliance

Follow [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/):

- **Indentation**: 4 spaces (never tabs)
- **Line length**: Maximum 79 characters for code, 72 for docstrings
- **Blank lines**: 2 before top-level definitions, 1 between methods
- **Imports**: One per line, grouped and sorted
- **Whitespace**: Follow PEP 8 guidelines for operators and commas

Use tools like `black`, `flake8`, or `ruff` for automatic formatting:

```bash
# Format code with black
black module_name.py

# Check style with flake8
flake8 module_name.py

# Lint and format with ruff
ruff check --fix module_name.py
```

### Naming Conventions

Follow PEP 8 naming conventions:

- **Modules**: `lowercase_with_underscores.py`
- **Classes**: `PascalCase` (e.g., `DataProcessor`, `HttpClient`)
- **Functions**: `lowercase_with_underscores` (e.g., `process_data`, `validate_input`)
- **Variables**: `lowercase_with_underscores` (e.g., `user_name`, `total_count`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRIES`, `DEFAULT_TIMEOUT`)
- **Private**: Prefix with single underscore (e.g., `_internal_function`)

### Type Hints

Use type hints for all function signatures and class attributes:

```python
from typing import Optional, List, Dict, Union, Tuple

def process_user_data(
    user_id: int,
    metadata: Dict[str, str],
    options: Optional[List[str]] = None
) -> Tuple[bool, str]:
    """
    Process user data with optional configuration.
    
    Args:
        user_id: Unique identifier for the user
        metadata: Key-value pairs of user metadata
        options: Optional list of processing options
    
    Returns:
        Tuple of (success: bool, message: str)
    """
    options = options or []
    # Implementation
    return True, "Processing complete"
```

**Modern type hints (Python 3.10+):**

```python
def process_data(
    items: list[str],           # Instead of List[str]
    config: dict[str, int],     # Instead of Dict[str, int]
    optional: str | None = None # Instead of Optional[str]
) -> tuple[bool, str]:          # Instead of Tuple[bool, str]
    """Process data with modern type hints."""
    pass
```

### Code Organization

Structure your Python modules in logical sections:

```python
"""Module docstring"""

# ============================================================================
# IMPORTS
# ============================================================================

# Standard library imports
import logging
import sys
from pathlib import Path
from typing import Optional

# Third-party imports
import requests
from pandas import DataFrame

# Local application imports
from .utils import validate_input
from .config import Settings

# ============================================================================
# CONSTANTS & CONFIGURATION
# ============================================================================

LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

logger = logging.getLogger(__name__)

# ============================================================================
# TYPE DEFINITIONS
# ============================================================================

ConfigDict = dict[str, str | int | bool]

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def _internal_helper(value: str) -> str:
    """Private helper function."""
    return value.strip()

# ============================================================================
# PUBLIC API
# ============================================================================

def public_function(arg: str) -> str:
    """Public function exposed to users."""
    return _internal_helper(arg)

# ============================================================================
# CLASSES
# ============================================================================

class DataProcessor:
    """Main data processor class."""
    
    def __init__(self, config: ConfigDict) -> None:
        self.config = config
    
    def process(self) -> None:
        """Process data."""
        pass

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format=LOG_FORMAT)
    logger.info("Module executed directly")
```

## Logging System

### Logger Configuration

Use Python's `logging` module instead of `print()` statements:

```python
import logging
from pathlib import Path

# Configure logging
LOG_DIR = Path("logs")
LOG_DIR.mkdir(exist_ok=True)

LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
LOG_FILE = LOG_DIR / "app.log"

# Basic configuration
logging.basicConfig(
    level=logging.INFO,
    format=LOG_FORMAT,
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()  # Also log to console
    ]
)

# Create module logger
logger = logging.getLogger(__name__)
```

### Log Levels

Use appropriate log levels:

```python
logger.debug("Detailed information for diagnosing problems")
logger.info("General informational messages")
logger.warning("Warning messages for non-critical issues")
logger.error("Error messages for serious problems")
logger.critical("Critical messages for very serious errors")
```

### Logging Best Practices

```python
def process_file(file_path: Path) -> bool:
    """Process a file with comprehensive logging."""
    logger.debug(f"Starting to process file: {file_path}")
    
    if not file_path.exists():
        logger.error(f"File not found: {file_path}")
        return False
    
    try:
        logger.info(f"Processing file: {file_path.name}")
        with file_path.open() as f:
            data = f.read()
        
        logger.debug(f"Read {len(data)} bytes from {file_path.name}")
        
        # Process data
        result = transform(data)
        logger.info(f"Successfully processed {file_path.name}")
        
        return True
        
    except Exception as e:
        logger.exception(f"Failed to process {file_path}: {e}")
        return False
```

**Logging guidelines:**

1. **Use logger.exception()** in except blocks to include stack traces
2. **Include context** in log messages (variable values, file names)
3. **Avoid logging in loops** unless using DEBUG level
4. **Log function entry/exit** only at DEBUG level for tracing
5. **Use f-strings** for log message formatting

### Debug Mode

Control logging verbosity with environment variables or configuration:

```python
import os
import logging

def setup_logging(debug: bool = False) -> None:
    """Configure logging based on debug flag."""
    level = logging.DEBUG if debug else logging.INFO
    
    logging.basicConfig(
        level=level,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )

# Usage
DEBUG = os.getenv("DEBUG", "false").lower() == "true"
setup_logging(debug=DEBUG)
```

## Comments and Documentation

### Docstrings

Use docstrings for all public modules, classes, and functions:

```python
def calculate_total(
    items: list[dict[str, float]],
    tax_rate: float = 0.0,
    discount: float = 0.0
) -> float:
    """
    Calculate total price including tax and discount.
    
    Args:
        items: List of item dictionaries with 'price' key
        tax_rate: Tax rate as decimal (0.08 for 8%)
        discount: Discount as decimal (0.10 for 10% off)
    
    Returns:
        Total price after tax and discount
    
    Raises:
        ValueError: If tax_rate or discount is negative
        KeyError: If items don't contain 'price' key
    
    Example:
        >>> items = [{"price": 10.0}, {"price": 20.0}]
        >>> calculate_total(items, tax_rate=0.08)
        32.4
    """
    if tax_rate < 0 or discount < 0:
        raise ValueError("Tax rate and discount must be non-negative")
    
    subtotal = sum(item["price"] for item in items)
    taxed = subtotal * (1 + tax_rate)
    total = taxed * (1 - discount)
    
    return total
```

### Docstring Formats

Choose a consistent docstring format:

**Google Style** (recommended for readability):
```python
def function(arg1: str, arg2: int) -> bool:
    """Summary line.
    
    Extended description.
    
    Args:
        arg1: Description of arg1
        arg2: Description of arg2
    
    Returns:
        Description of return value
    
    Raises:
        ValueError: Description of when raised
    """
```

**NumPy Style** (common in scientific computing):
```python
def function(arg1: str, arg2: int) -> bool:
    """
    Summary line.
    
    Extended description.
    
    Parameters
    ----------
    arg1 : str
        Description of arg1
    arg2 : int
        Description of arg2
    
    Returns
    -------
    bool
        Description of return value
    
    Raises
    ------
    ValueError
        Description of when raised
    """
```

### Inline Comments

Use inline comments to explain complex logic:

```python
# Calculate weighted average with numpy for performance
# Using axis=1 to average across rows, weights normalized
weighted_avg = np.average(
    data,
    axis=1,
    weights=weights / weights.sum()  # Normalize weights to sum to 1
)
```

## Error Handling

### Specific Exceptions

Catch specific exceptions rather than bare `except:`:

```python
# ✅ Good: Specific exception handling
try:
    file_data = Path(file_path).read_text()
except FileNotFoundError:
    logger.error(f"File not found: {file_path}")
    return None
except PermissionError:
    logger.error(f"Permission denied: {file_path}")
    return None
except Exception as e:
    logger.exception(f"Unexpected error reading {file_path}: {e}")
    raise

# ❌ Bad: Bare except catches everything
try:
    file_data = Path(file_path).read_text()
except:
    return None
```

### Custom Exceptions

Create custom exceptions for domain-specific errors:

```python
class ValidationError(Exception):
    """Raised when input validation fails."""
    pass

class ConfigurationError(Exception):
    """Raised when configuration is invalid."""
    pass

def validate_config(config: dict) -> None:
    """Validate configuration dictionary."""
    if "api_key" not in config:
        raise ConfigurationError("Missing required 'api_key' in config")
    
    if not config["api_key"]:
        raise ValidationError("api_key cannot be empty")
```

### Context Managers

Use context managers for resource management:

```python
from pathlib import Path
from contextlib import contextmanager

# ✅ Good: Automatic cleanup with context manager
def process_file(file_path: Path) -> str:
    with file_path.open() as f:
        return f.read()

# Custom context manager
@contextmanager
def temporary_setting(config: dict, key: str, value: any):
    """Temporarily change a config value."""
    old_value = config.get(key)
    config[key] = value
    try:
        yield
    finally:
        config[key] = old_value
```

## Testing

### Test Structure

Use pytest for testing:

```python
# tests/test_module.py
import pytest
from module_name import calculate_total

def test_calculate_total_no_tax():
    """Test basic total calculation without tax."""
    items = [{"price": 10.0}, {"price": 20.0}]
    result = calculate_total(items)
    assert result == 30.0

def test_calculate_total_with_tax():
    """Test total calculation with tax."""
    items = [{"price": 10.0}]
    result = calculate_total(items, tax_rate=0.1)
    assert result == 11.0

def test_calculate_total_negative_tax_raises():
    """Test that negative tax rate raises ValueError."""
    items = [{"price": 10.0}]
    with pytest.raises(ValueError):
        calculate_total(items, tax_rate=-0.1)

@pytest.fixture
def sample_items():
    """Fixture providing sample item data."""
    return [
        {"price": 10.0},
        {"price": 20.0},
        {"price": 15.0}
    ]

def test_with_fixture(sample_items):
    """Test using fixture data."""
    result = calculate_total(sample_items)
    assert result == 45.0
```

### Test Organization

```
tests/
├── __init__.py
├── conftest.py           # Shared fixtures
├── test_module1.py
├── test_module2.py
└── integration/
    ├── __init__.py
    └── test_integration.py
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=module_name

# Run specific test file
pytest tests/test_module.py

# Run specific test
pytest tests/test_module.py::test_function_name

# Verbose output
pytest -v

# Show print statements
pytest -s
```

## Performance Considerations

### List Comprehensions

Use list comprehensions for cleaner, faster code:

```python
# ✅ Good: List comprehension
squares = [x**2 for x in range(10)]

# ❌ Bad: Loop with append
squares = []
for x in range(10):
    squares.append(x**2)
```

### Generator Expressions

Use generators for memory efficiency with large datasets:

```python
# Generator expression (memory efficient)
sum_of_squares = sum(x**2 for x in range(1000000))

# List comprehension (loads all into memory)
sum_of_squares = sum([x**2 for x in range(1000000)])
```

### Built-in Functions

Prefer built-in functions and libraries:

```python
# ✅ Good: Built-in functions
max_value = max(numbers)
total = sum(numbers)

# ❌ Bad: Manual implementation
max_value = numbers[0]
for n in numbers:
    if n > max_value:
        max_value = n
```

## Data Classes

Use dataclasses for simple data containers:

```python
from dataclasses import dataclass, field
from typing import List

@dataclass
class User:
    """User data container."""
    
    name: str
    email: str
    age: int
    tags: List[str] = field(default_factory=list)
    
    def __post_init__(self):
        """Validate data after initialization."""
        if self.age < 0:
            raise ValueError("Age must be non-negative")
        
        if "@" not in self.email:
            raise ValueError("Invalid email format")

# Usage
user = User(name="John", email="john@example.com", age=30)
```

## Async Programming

Use `async`/`await` for I/O-bound operations:

```python
import asyncio
import aiohttp
from typing import List

async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    """Fetch content from URL asynchronously."""
    logger.debug(f"Fetching {url}")
    async with session.get(url) as response:
        return await response.text()

async def fetch_multiple(urls: List[str]) -> List[str]:
    """Fetch multiple URLs concurrently."""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
        return results

# Usage
urls = ["https://example.com", "https://example.org"]
results = asyncio.run(fetch_multiple(urls))
```

## Configuration Management

### Environment Variables

Use environment variables for configuration:

```python
import os
from pathlib import Path
from typing import Optional

class Config:
    """Application configuration."""
    
    # Required settings
    API_KEY: str = os.environ["API_KEY"]
    
    # Optional with defaults
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    MAX_RETRIES: int = int(os.getenv("MAX_RETRIES", "3"))
    
    # Path handling
    DATA_DIR: Path = Path(os.getenv("DATA_DIR", "data"))
    
    @classmethod
    def validate(cls) -> None:
        """Validate configuration."""
        if not cls.API_KEY:
            raise ValueError("API_KEY environment variable is required")
        
        cls.DATA_DIR.mkdir(parents=True, exist_ok=True)
```

### Config Files

Use config files for complex configuration:

```python
import json
from pathlib import Path
from typing import Dict, Any

def load_config(config_path: Path) -> Dict[str, Any]:
    """Load configuration from JSON file."""
    if not config_path.exists():
        logger.warning(f"Config file not found: {config_path}")
        return {}
    
    try:
        with config_path.open() as f:
            config = json.load(f)
        logger.info(f"Loaded config from {config_path}")
        return config
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in {config_path}: {e}")
        raise
```

## Security Best Practices

1. **Never hardcode credentials**: Use environment variables or secret managers
2. **Validate all inputs**: Check types, ranges, and formats
3. **Use parameterized queries**: Prevent SQL injection
4. **Sanitize file paths**: Use `Path.resolve()` to prevent directory traversal
5. **Keep dependencies updated**: Regularly update packages for security fixes

```python
from pathlib import Path

def safe_read_file(base_dir: Path, user_path: str) -> str:
    """Safely read file preventing directory traversal."""
    # Resolve both paths to absolute
    base = base_dir.resolve()
    target = (base / user_path).resolve()
    
    # Ensure target is within base directory
    if not target.is_relative_to(base):
        raise ValueError("Access denied: path outside base directory")
    
    return target.read_text()
```

## Version Control

### .gitignore

Standard Python `.gitignore`:

```
# Byte-compiled files
__pycache__/
*.py[cod]
*$py.class

# Distribution / packaging
dist/
build/
*.egg-info/

# Virtual environments
venv/
env/
.venv/

# IDE
.vscode/
.idea/
*.swp

# Testing
.pytest_cache/
.coverage
htmlcov/

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db
```

### Commit Messages

Use conventional commits format:

```
feat: add user authentication module
fix: resolve memory leak in data processor
refactor: simplify configuration loading
docs: update README with usage examples
test: add unit tests for validation
chore: update dependencies
```

## Example Template

Complete Python module template following all conventions:

```python
"""
Module Name - Brief Description

PURPOSE:
    Explain what this module does and the problem it solves.

USAGE:
    >>> from module_name import main_function
    >>> result = main_function(arg1, arg2)

KEY DEPENDENCIES:
    - logging: Standard library logging
    - pathlib: Path manipulation

COMPATIBILITY:
    Python 3.9+

Author: Your Name
Date: 2024-01-01
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Optional

# ============================================================================
# CONSTANTS & CONFIGURATION
# ============================================================================

LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
DEFAULT_TIMEOUT = 30

logger = logging.getLogger(__name__)

# ============================================================================
# TYPE DEFINITIONS
# ============================================================================

ConfigDict = dict[str, str | int]

# ============================================================================
# PUBLIC API
# ============================================================================

def main_function(
    arg1: str,
    arg2: int,
    optional: Optional[str] = None
) -> tuple[bool, str]:
    """
    Main function description.
    
    Args:
        arg1: Description of arg1
        arg2: Description of arg2
        optional: Optional parameter description
    
    Returns:
        Tuple of (success, message)
    
    Raises:
        ValueError: If arg2 is negative
    
    Example:
        >>> main_function("test", 42)
        (True, "Success")
    """
    logger.debug(f"main_function called with arg1={arg1}, arg2={arg2}")
    
    if arg2 < 0:
        raise ValueError("arg2 must be non-negative")
    
    try:
        # Implementation
        result = f"Processed {arg1} with value {arg2}"
        logger.info(f"Successfully processed: {result}")
        return True, result
        
    except Exception as e:
        logger.exception(f"Failed to process: {e}")
        return False, str(e)

# ============================================================================
# MAIN EXECUTION
# ============================================================================

def setup_logging(debug: bool = False) -> None:
    """Configure logging."""
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(level=level, format=LOG_FORMAT)

if __name__ == "__main__":
    setup_logging(debug=True)
    logger.info("Module executed directly")
    
    # Example usage
    success, message = main_function("example", 42)
    print(f"Result: {success} - {message}")
```

## Additional Resources

- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 257 - Docstring Conventions](https://peps.python.org/pep-0257/)
- [PEP 484 - Type Hints](https://peps.python.org/pep-0484/)
- [Python Logging HOWTO](https://docs.python.org/3/howto/logging.html)
- [pytest Documentation](https://docs.pytest.org/)
- [Python Best Practices](https://docs.python-guide.org/)

````
