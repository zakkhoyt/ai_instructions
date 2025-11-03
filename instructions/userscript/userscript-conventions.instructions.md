---
applyTo: "**/*.user.js"
---

# ViolentMonkey Userscript Development Conventions

**Applies to**: All ViolentMonkey userscript files (`**/*.user.js`) in this repository

---

## ⚡ Quick Compliance Checklist

When writing or modifying **ANY** ViolentMonkey userscript in this repository, ensure:

- ✅ **Logging functions used** - Use existing `log()`, `logFunctionBegin()`, `logFunctionEnd()` functions
- ✅ **isDebug flag controlled** - Set `isDebug = true` to enable logs; `false` disables all trace logs
- ✅ **Function documentation complete** - Each function has JSDoc comments with purpose and parameters
- ✅ **Type annotations present** - Include type information in JSDoc and inline comments
- ✅ **References documented** - Include MDN, spec, or ViolentMonkey API references
- ✅ **Console logs properly prefixed** - All logs include `logBase` prefix through logging functions
- ✅ **Metadata block valid** - ViolentMonkey metadata block (`// ==UserScript==` ... `// ==/UserScript==`) is properly formatted
- ✅ **Browser console logs saved** - Test output captured in `.gitignored/logs/$scriptname.log` for AI agent review

---

## Table of Contents

1. [Script Structure and Metadata](#script-structure-and-metadata)
2. [Logging Architecture](#logging-architecture)
3. [Function Documentation](#function-documentation)
4. [Type Annotations](#type-annotations)
5. [References and Documentation](#references-and-documentation)
6. [Console Log Management](#console-log-management)
7. [Best Practices](#best-practices)

---

## Script Structure and Metadata

### ViolentMonkey Metadata Block

All userscripts must include a properly formatted metadata block at the top:

```javascript
// ==UserScript==
// @name         Script Display Name
// @namespace    https://github.com/zakkhoyt/greasemonkey/script_name
// @version      1.0.0
// @description  Brief description of what the script does
// @author       Your Name
// @match        *://*/*
// @grant        GM_setClipboard
// @grant        GM_registerMenuCommand
// @run-at       document-idle
// @noframes
// ==/UserScript==
```

**Metadata Fields (in order)**:
- `@name` - Display name shown in ViolentMonkey UI
- `@namespace` - Unique identifier (use GitHub URL convention)
- `@version` - Semantic version (major.minor.patch)
- `@description` - One-line description of functionality
- `@author` - Creator name or team
- `@match` - URL patterns where script runs (`*://*/*` for all sites)
- `@grant` - API permissions required (see [ViolentMonkey @grant documentation](https://violentmonkey.github.io/api/metadata-block/#grant))
- `@run-at` - When script executes (`document-idle` is recommended - after DOM ready but before all resources)
- `@noframes` - Prevents script from running in iframes/frames (improves performance)

**References**:
- [ViolentMonkey Metadata Block Documentation](https://violentmonkey.github.io/api/metadata-block/)
- [ViolentMonkey @match Patterns](https://violentmonkey.github.io/api/matching/)

### Header Comment Block

After the metadata block, include a comprehensive header comment:

```javascript
/*
 * Script Name - Brief Description
 * 
 * PURPOSE:
 * Detailed explanation of what this script does and how it improves the user experience
 * 
 * WORKFLOW:
 * 1. User performs action (e.g., clicks element with Alt key)
 * 2. Script detects condition and processes data
 * 3. Result is generated and provided to user
 * 
 * KEY APIS:
 * - API Name: https://reference.link
 * - Another API: https://reference.link
 * 
 * BROWSER COMPATIBILITY:
 * Tested on: Firefox 144.0.2 with ViolentMonkey 2.31.0 on macOS
 */
```

---

## Logging Architecture

### Core Logging Functions

All userscripts must implement a consistent logging architecture using these functions:

```javascript
/**
 * Simple logging wrapper with consistent prefix
 * @param {string} message - The message to log
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/Console/log
 */
function log(message) {
    if (isDebug) {
        console.log(`${logBase}: ${message}`);
    }
}

/**
 * Logs a function's entry point for tracing execution flow
 * @param {string} functionName - Name of the function being entered
 */
function logFunctionBegin(functionName) {
    if (isDebug) {
        console.log(`${logBase}: begin ${functionName}`);
    }
}

/**
 * Logs a function's exit point for tracing execution flow
 * @param {string} functionName - Name of the function being exited
 */
function logFunctionEnd(functionName) {
    if (isDebug) {
        console.log(`${logBase}: end ${functionName}`);
    }
}

/**
 * Logs a warning message with consistent prefix
 * @param {string} message - The warning message to log
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/Console/warn
 */
function logWarn(message) {
    console.warn(`${logBase}: ${message}`);
}

/**
 * Logs an error message with consistent prefix
 * @param {string} message - The error message to log
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/Console/error
 */
function logError(message) {
    console.error(`${logBase}: ${message}`);
}
```

### Using the Logging Functions

**Rule 1: Always use `logFunctionBegin()` and `logFunctionEnd()`**

```javascript
function processData(input) {
    logFunctionBegin('processData');
    
    log(`Processing input: "${input}"`);
    
    const result = input.toUpperCase();
    log(`Did process input, result: "${result}"`);
    
    logFunctionEnd('processData');
    return result;
}
```

**Rule 2: Log intent before operations**

```javascript
log('Will validate URL');
const isValid = validateUrl(url);
log(`Did validate URL: ${isValid}`);
```

**Rule 3: Use `logWarn()` and `logError()` for non-debug messages**

```javascript
logWarn('Missing optional parameter');
logError('Failed to extract URL - all strategies exhausted');
```

### Controlling Logging with isDebug Flag

```javascript
// At top of script, in CONFIGURATION section
const isDebug = true;  // Set to true to enable trace logging
```

**Behavior**:
- `isDebug = true`: All `log()`, `logFunctionBegin()`, `logFunctionEnd()` calls produce output
- `isDebug = false`: Trace logging is silent; only `logWarn()` and `logError()` produce output

**When to use each setting**:
- During development and debugging: `isDebug = true`
- Before committing to repository: `isDebug = false`
- When investigating user-reported issues: `isDebug = true`

---

## Function Documentation

### JSDoc Comments

**REQUIRED**: Every function must have a JSDoc comment block documenting its purpose and parameters.

**Minimum structure**:

```javascript
/**
 * Brief one-line description of what function does
 * @param {type} paramName - Description of parameter
 * @returns {type} Description of return value
 * Reference: https://reference.url
 */
function functionName(paramName) {
    // implementation
}
```

**Complete example**:

```javascript
/**
 * Extracts URL from an anchor element using multiple fallback strategies
 * Handles relative URLs, missing hrefs, and site-specific patterns
 * @param {HTMLElement} anchor - The anchor element (or closest anchor)
 * @param {MouseEvent|KeyboardEvent} event - The triggering event (for additional context)
 * @returns {string|null} Absolute URL or null if extraction fails
 * 
 * Strategies attempted in order:
 * 1. Standard anchor.href (browser auto-resolves relative URLs)
 * 2. Manual resolution with URL API
 * 3. Walk up DOM tree to find parent anchor
 * 4. Amazon-specific: Extract ASIN from data-asin attribute
 * 5. Fallback to current page URL
 * 
 * Type returned: string (absolute URL) | null (extraction failed)
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/HTMLAnchorElement/href
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/URL
 */
function extractUrlFromAnchor(anchor, event) {
    // implementation
}
```

### Inline Comments for Complex Logic

For non-obvious code sections, include comments explaining the "why" rather than the "what":

```javascript
// Always declare and initialize in single statement
// Separate declaration/initialization can leak to stdout
const result = command.trim() || null;

// Use capture phase to intercept before target element handlers
document.addEventListener('click', handleClick, true);

// Browser auto-resolves relative URLs in the href property
// This is preferred to manual URL() constructor
if (anchor && anchor.href) {
    return anchor.href;
}
```

---

## Type Annotations

### Parameter and Return Types

Always include type information in JSDoc and inline comments:

```javascript
/**
 * Creates markdown-formatted link: [title](url)
 * @param {string} title - The link text/title
 * @param {string} url - The URL to link to
 * @returns {string} Markdown-formatted link
 */
function createMarkdown(title, url) {
    // Type: string (template literal result)
    const markdown = `[${title}](${url})`;
    return markdown;
}
```

### Variable Type Comments

For variables with complex types, include type comments:

```javascript
// Type: HTMLDivElement
// Reference: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement
let currentMenu = null;

// Type: Set<string> (stores key names like 'Alt', 'z', 'Z')
// Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set
const pressedKeys = new Set();

// Type: Array<{url: string, anchor: HTMLElement|null}>
let altZClickBuffer = [];

// Type: Function | null
let menuClickHandler = null;
```

### Union Types

Use pipe `|` notation for values that can be multiple types:

```javascript
// Type: string | null
const selectedText = getSelectedText();

// Type: HTMLElement | null
const anchor = event.target.closest('a');

// Type: number (pixel coordinate, initially 0)
let mouseX = 0;
```

---

## References and Documentation

### MDN Documentation

Prefer Mozilla Developer Network (MDN) documentation where available:

```javascript
/**
 * Gets currently selected text from the page (if any)
 * Uses the Selection API to read user's text highlight
 * @returns {string|null} Selected text or null if nothing selected
 * 
 * JavaScript string type: Immutable sequence of UTF-16 code units
 * Selection API: Represents text selection on page
 * Type returned: string (when selection exists) | null (when no selection)
 * Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/Window/getSelection
 */
function getSelectedText() {
    const selection = window.getSelection().toString().trim();
    return selection || null;
}
```

### ViolentMonkey API Documentation

For ViolentMonkey-specific APIs, link to the official documentation:

```javascript
/**
 * Copies markdown link to system clipboard using ViolentMonkey API
 * @param {string} markdown - The markdown string to copy
 * 
 * VIOLENTMONKEY API: GM_setClipboard
 * - Privileged API requiring @grant GM_setClipboard in metadata block
 * - Writes text to system clipboard (works across all platforms)
 * - Signature: GM_setClipboard(data: string, type?: string)
 * - Type parameter defaults to 'text/plain'
 * 
 * Reference: https://violentmonkey.github.io/api/gm/#gm_setclipboard
 */
function copyToClipboard(markdown) {
    GM_setClipboard(markdown, 'text/plain');
}
```

### Reference Placement

Always include reference links in comments:

- **In JSDoc**: Add `Reference:` lines at the end of the comment block
- **In inline comments**: Add reference as part of the explanation
- **In code**: Use actual API calls with comments explaining what they do

```javascript
// Reference: https://developer.mozilla.org/en-US/docs/Web/API/Element/closest
const anchor = event.target.closest('a');

// Reference: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/style
element.style.cssText = `color: red; font-size: 14px;`;
```

---

## Console Log Management

### Saving Console Logs for AI Agent Review

The AI agent cannot access browser console output directly. To enable debugging:

1. **Open Browser Console**
   - Firefox: `F12` or `Cmd+Option+K`
   - Chrome: `F12` or `Cmd+Option+J`

2. **Enable Script Logging**
   - In your script, set `isDebug = true` to see trace logs
   - Run the script to populate console with logs

3. **Export Console Messages**
   - Right-click in console
   - Select "Save all Messages to File"
   - Choose location below

4. **Save to Proper Location**
   - Create directory if needed: `.gitignored/logs/`
   - Filename format: `$scriptname.log`
   - Example: `.gitignored/logs/markdown_linker.log`

5. **Share with AI Agent**
   - Commit the log file to repository
   - AI agent will automatically review logs after running tests
   - Include the log file path in your request

### Log File Format

The saved log file should contain console messages in timestamp format:

```
[timestamp] markdown_linker: begin handleClick
[timestamp] markdown_linker: Will check if Alt+Z keys are pressed (auto-infer mode)
[timestamp] markdown_linker: Is auto-infer mode (Alt+Z+Click): true
[timestamp] markdown_linker: Will show click feedback animation
[timestamp] markdown_linker: Did show click feedback animation
[timestamp] markdown_linker: end handleClick
```

### Log File Lifecycle

- **During development**: Keep `isDebug = true` to capture all logs
- **Before submission**: Change to `isDebug = false` and clear test logs
- **When investigating issues**: Re-enable `isDebug = true` and save fresh logs
- **Do not commit test logs**: `.gitignored/logs/` directory should be in `.gitignore`

---

## Best Practices

### Event Handling

When using event listeners, always:

1. Use capture phase for priority interception
2. Include reference to MDN documentation
3. Log when handlers fire and what they detect

```javascript
/**
 * Handles left-click events with Alt modifier
 * Intercepts clicks on anchors or page to show markdown menu
 * @param {MouseEvent} event - The click event
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/Element/click_event
 */
function handleClick(event) {
    logFunctionBegin('handleClick');
    
    log('Click event received');
    log(`Alt key pressed: ${event.altKey}`);
    
    if (!event.altKey) {
        log('Alt key not pressed, returning');
        logFunctionEnd('handleClick');
        return;
    }
    
    // Prevent default and stop propagation
    // Reference: https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault
    event.preventDefault();
    event.stopPropagation();
    
    // ... rest of implementation
    
    logFunctionEnd('handleClick');
}

// Use capture phase (third parameter = true) to intercept before target handlers
// Reference: https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Building_blocks/Events#event_bubbling_and_capture
document.addEventListener('click', handleClick, true);
```

### DOM Element Creation

When creating dynamic elements:

1. Use `document.createElement()` with type comments
2. Use `style.cssText` for multiple CSS properties
3. Clean up elements with `remove()` when done
4. Include references to MDN documentation

```javascript
/**
 * Displays temporary success notification to user
 * @param {string} message - The message to display
 * Reference: https://developer.mozilla.org/en-US/docs/Web/API/Document/createElement
 */
function showNotification(message) {
    logFunctionBegin('showNotification');
    
    // Type: HTMLDivElement
    // Reference: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement
    const notification = document.createElement('div');
    
    // textContent is safe from XSS attacks (doesn't interpret HTML)
    // Type: string
    // Reference: https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent
    notification.textContent = message;
    
    // Reference: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/style
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #4CAF50;
        color: white;
        z-index: 999999;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        log('Will remove notification');
        // Reference: https://developer.mozilla.org/en-US/docs/Web/API/Element/remove
        notification.remove();
    }, 3000);
    
    logFunctionEnd('showNotification');
}
```

### Error Handling

For operations that can fail:

1. Use try/catch for known error conditions
2. Log the error with context
3. Provide user feedback when appropriate

```javascript
/**
 * Copies markdown link to system clipboard
 */
function copyToClipboard(markdown) {
    logFunctionBegin('copyToClipboard');
    
    try {
        GM_setClipboard(markdown, 'text/plain');
        log('Did copy to clipboard successfully');
        showNotification('Markdown link copied to clipboard!');
    } catch (error) {
        // Type: Error object
        // Reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error
        logError(`Failed to copy to clipboard: ${error.message}`);
        showNotification('Failed to copy to clipboard - check console for errors');
    }
    
    logFunctionEnd('copyToClipboard');
}
```

### CSS Animations

When adding CSS animations:

1. Define animations in `@keyframes` blocks
2. Use template literals for variable CSS
3. Include animation timing and easing
4. Document animation behavior in comments

```javascript
// Add CSS keyframe animations
// Must be injected into document <head> to apply to dynamically created elements
// Reference: https://developer.mozilla.org/en-US/docs/Web/CSS/@keyframes
const style = document.createElement('style');

style.textContent = `
    @keyframes mdLinkerClickPulse {
        0% { 
            transform: scale(1);
            opacity: 1;
            box-shadow: 0 0 0 0 rgba(76, 175, 80, 0.7);
        }
        100% { 
            transform: scale(1.4);
            opacity: 0;
            box-shadow: 0 0 0 20px rgba(76, 175, 80, 0);
        }
    }
`;

document.head.appendChild(style);
```

---

## Summary

Following these conventions ensures:

- **Maintainability**: Consistent code structure makes updates easier
- **Debuggability**: Comprehensive logging enables quick problem diagnosis
- **Readability**: Clear documentation helps new developers understand code
- **Reliability**: Proper error handling and type information prevent bugs
- **Collaboration**: AI agents can understand and improve code more effectively

When in doubt, refer to:
- [MDN Web Docs](https://developer.mozilla.org/)
- [ViolentMonkey Documentation](https://violentmonkey.github.io/)
- Existing scripts in this repository as examples
