# Unicode Arrow Glyphs vs Emoji

## The Problem

Some Unicode characters have **two visual representations**:
1. **Text style** - Simple, monochrome glyph (what fonts like Helvetica provide)
2. **Emoji style** - Colorful, rounded emoji version

By default, many rendering systems choose the emoji version, which looks out of place in technical documentation.

## The Solution: Variation Selectors

Unicode provides **Variation Selectors** to explicitly request one style or another:

- **U+FE0E (VS15)** - Force text/glyph presentation: `︎` (invisible character)
- **U+FE0F (VS16)** - Force emoji presentation: `️` (invisible character)

## How to Use

Add the variation selector immediately after the character:

```markdown
# Without variation selector (may render as emoji):
↕ ↔ ↑ ↓ ← →

# With VS15 (forces text/glyph style):
↕︎ ↔︎ ↑︎ ↓︎ ←︎ →︎
```

In your editor, you won't see the variation selector (it's invisible), but the rendering engine will use it to choose the correct style.

## Which Characters Need This?

Not all Unicode characters have dual presentation. To find out:

### 1. Check the Unicode Standard
- **Emoji specification**: [Unicode TR51](https://www.unicode.org/reports/tr51/)
- **Emoji data file**: https://unicode.org/Public/emoji/latest/emoji-data.txt
- Look for characters with `Emoji_Presentation` property

### 2. Common Characters That Need VS15 in Technical Docs

**Arrows:**
- `↕︎` U+2195 (up-down arrow)
- `↔︎` U+2194 (left-right arrow)
- `↖︎` `↗︎` `↘︎` `↙︎` (diagonal arrows)
- `↑︎` `↓︎` `←︎` `→︎` (directional arrows)
- `⬆︎` `⬇︎` `⬅︎` `➡︎` (heavy arrows)

**Symbols:**
- `☀︎` `☁︎` `☂︎` (weather)
- `★︎` `☆︎` (stars)
- `✓︎` `✗︎` (check marks)
- `☎︎` `✉︎` (communication)

### 3. Quick Test Method

To check if a character needs a variation selector:

1. Type the character in different contexts (markdown, HTML, your editor)
2. If it sometimes appears as a colorful emoji and sometimes as a simple glyph, it has dual presentation
3. Add VS15 (`U+FE0E`) to force text style

### 4. Programmatic Check

You can check the Unicode emoji data file:

```bash
# Download the emoji data
curl https://unicode.org/Public/emoji/latest/emoji-data.txt > emoji-data.txt

# Check if a character (e.g., U+2195) has Emoji_Presentation
grep "2195" emoji-data.txt
```

If you see `Emoji_Presentation`, the character may render as emoji by default.

## Tools and Resources

**Official Unicode Documentation:**
- [Unicode Technical Standard #51 - Emoji](https://www.unicode.org/reports/tr51/)
- [Emoji Variation Sequences](https://www.unicode.org/reports/tr51/#Emoji_Variation_Sequences)
- [Variation Selectors FAQ](https://www.unicode.org/faq/vs.html)

**Online Tools:**
- [Unicode Character Inspector](https://unicode-explorer.com/)
- [Emojipedia](https://emojipedia.org/) - Shows both text and emoji versions
- [FileFormat.info](https://www.fileformat.info/info/unicode/) - Detailed character info

**Editor Support:**
- Most modern editors show variation selectors as invisible
- Some editors have "show invisibles" mode that reveals them
- To type VS15: Copy from this doc or use hex input (depends on OS/editor)

## Implementation in This Project

All arrow characters in our reference tables use VS15 to ensure consistent text rendering:

```markdown
| select  | ^B 0-9 | — | ^B ↑︎↓︎←︎→︎ | select |
| split ↕︎ | ^B "   | — | —         | split ↕︎ |
| split ↔︎ | ^B %   | — | —         | split ↔︎ |
```

This ensures documentation renders correctly in:
- GitHub Markdown
- Web browsers
- Terminal pagers
- PDF exports
- Any system that respects Unicode variation selectors
