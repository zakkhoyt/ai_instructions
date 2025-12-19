---
applyTo: "**/*"
---

# AI Agent Chat Response Conventions

**IMPORTANT**: These conventions define how AI agents should format responses in chat to maximize efficiency when users copy information to their markdown notes.

---

## ⚡ Quick Compliance Checklist

When responding to user questions in chat, ensure:

- ✅ **Markdown source format** - Present information as markdown source code, not rendered markdown (see [Markdown Source Format](#markdown-source-format))
- ✅ **Reference links included** - Always include reference links in markdown source format (see [Reference Links](#reference-links))
- ✅ **Copy-friendly code** - Use markdown code fences for all code snippets (see [Code Snippets](#code-snippets))
- ✅ **URLs as markdown links** - Present URLs in markdown link syntax (see [URLs and Links](#urls-and-links))

**→ If unsure about any item, refer to the detailed sections below.**

---

## Table of Contents

1. [Markdown Source Format](#markdown-source-format)
2. [Reference Links](#reference-links)
3. [Code Snippets](#code-snippets)
4. [URLs and Links](#urls-and-links)

---

## Markdown Source Format

**CRITICAL**: The user maintains detailed notes in markdown files and frequently copies information from chat sessions into these notes. All responses should be formatted as markdown source code, NOT rendered markdown.

### What This Means

**Markdown source** refers to the raw markdown syntax that produces formatted text, not the formatted result.

✅ **Good (markdown source):**
```markdown
## Heading

This is **bold text** and this is *italic text*.

- List item 1
- List item 2

[Link text](https://example.com)

```code
example
```
```

❌ **Bad (rendered markdown):**
```
Heading (as formatted heading)
This is bold text and this is italic text. (with actual formatting applied)
• List item 1 (with bullet rendering)
• List item 2
Link text (as clickable hyperlink)
```

### When to Use Markdown Source

Use markdown source format when:
- Providing lists or structured information
- Sharing code examples
- Including URLs or links
- Creating headings or sections
- Any content the user might want to copy to their notes

### Example Response Pattern

When user asks: "How do I configure git?"

✅ **Good response:**
```markdown
## Git Configuration

Configure git with these commands:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Reference:**
- [Git Configuration Documentation](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup)
```

---

## Reference Links

**CRITICAL**: Always include reference links when responding to questions. Present all links in markdown source format.

### Link Format

Use the standard markdown link syntax:

```markdown
[Link Text](https://url.com)
```

### When to Include References

Include reference links when:
- Citing documentation
- Referencing external resources
- Providing sources for information
- Linking to related topics
- Sharing tutorials or guides

### Example Patterns

✅ **Good (with references):**
```markdown
## Answer

Here's how to use the `grep` command:

```bash
grep "pattern" file.txt
```

**References:**
- [grep Manual](https://man7.org/linux/man-pages/man1/grep.1.html)
- [grep Tutorial](https://www.gnu.org/software/grep/manual/grep.html)
```

❌ **Bad (missing references):**
```
Here's how to use grep: grep "pattern" file.txt
```

### Multiple References

When providing multiple references, use a list:

```markdown
**References:**
- [Primary Documentation](https://example.com/docs)
- [Tutorial](https://example.com/tutorial)
- [Stack Overflow Discussion](https://stackoverflow.com/questions/12345)
```

---

## Code Snippets

**CRITICAL**: All code examples must be presented in markdown code fences with appropriate language identifiers.

### Code Fence Format

Use triple backticks with language identifier:

````markdown
```language
code here
```
````

### Supported Languages

Common language identifiers:
- `bash` or `zsh` for shell commands
- `python` for Python code
- `swift` for Swift code
- `javascript` for JavaScript code
- `json` for JSON data
- `markdown` for markdown examples

### Example Patterns

✅ **Good (with code fences):**
````markdown
Run this command:

```zsh
echo "Hello World"
```

For Python:

```python
def hello():
    print("Hello World")
```
````

❌ **Bad (no code fences):**
```
Run: echo "Hello World"
```

### Inline Code

For short code references within sentences, use single backticks:

```markdown
Use the `grep` command to search files.
```

---

## URLs and Links

**CRITICAL**: All URLs must be presented as markdown links, not bare URLs.

### Link Format

Always use markdown link syntax:

```markdown
[Descriptive Text](https://url.com)
```

### Examples

✅ **Good (markdown links):**
```markdown
- [GitHub Documentation](https://docs.github.com)
- [VS Code API](https://code.visualstudio.com/api)
- [Swift Language Guide](https://docs.swift.org/swift-book/)
```

❌ **Bad (bare URLs):**
```
- https://docs.github.com
- https://code.visualstudio.com/api
- https://docs.swift.org/swift-book/
```

### Link Text Guidelines

Use descriptive link text that indicates the destination:

✅ **Good:**
```markdown
[Python Official Documentation](https://docs.python.org)
```

❌ **Bad:**
```markdown
[Click here](https://docs.python.org)
```

### Image Links

For images, use markdown image syntax:

```markdown
![Alt text](https://example.com/image.png)
```

---

## Complete Response Example

Here's a complete example demonstrating all conventions:

### User Question
"How do I create a Python virtual environment?"

### Agent Response

````markdown
## Creating a Python Virtual Environment

### Steps

1. Navigate to your project directory:
```bash
cd /path/to/project
```

2. Create the virtual environment:
```bash
python3 -m venv venv
```

3. Activate the virtual environment:
```bash
source venv/bin/activate
```

4. Install packages:
```bash
pip install -r requirements.txt
```

### Verification

Verify the virtual environment is active by checking the Python path:

```bash
which python
# Should output: /path/to/project/venv/bin/python
```

### Deactivation

To deactivate the virtual environment:

```bash
deactivate
```

**References:**
- [Python venv Documentation](https://docs.python.org/3/library/venv.html)
- [Virtual Environments Tutorial](https://realpython.com/python-virtual-environments-a-primer/)
- [pip Documentation](https://pip.pypa.io/en/stable/)
````

---

## Summary: Response Format Rules

1. **Use markdown source** - Present all information as raw markdown syntax
2. **Include references** - Always provide reference links in markdown format
3. **Use code fences** - Wrap all code examples in markdown code fences
4. **Format URLs as links** - Use `[text](url)` syntax, never bare URLs

Following these conventions ensures:
- **Easy copying** - Users can copy/paste directly into their markdown notes
- **Proper formatting** - Content maintains structure when copied
- **Complete information** - References are always included
- **Consistency** - All responses follow the same pattern

---

## References

- [Markdown Guide](https://www.markdownguide.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
- [Markdown Syntax Documentation](https://daringfireball.net/projects/markdown/syntax)
