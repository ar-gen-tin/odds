# odds — SVG Assets

## Files

| File | Usage | Size |
|------|-------|------|
| `odds-icon-6c-color.svg` | APP icon (full color, #6C cyber style) | 512x512 |
| `odds-icon-6c-mono-dark.svg` | Mono icon for dark backgrounds | 512x512 |
| `odds-icon-6c-mono-light.svg` | Mono icon for light backgrounds | 512x512 |
| `odds-menubar-template.svg` | macOS menubar template (1x) | 18x18 |
| `odds-menubar-template@2x.svg` | macOS menubar template (2x) | 36x36 |
| `odds-logo-full.svg` | Full logo: icon + "odds" text | 200x48 |

## Colors

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#05050A` | Icon background |
| Border glow | `#B8FF57` @ 20% | Subtle border |
| Lime (up) | `#B8FF57` | Bright cells, positive |
| Orange (accent) | `#FF6B2C` | Accent cells |
| Pink (down) | `#FF3B5C` | Center cell, negative |
| Dim cell fill | `#B8FF57` @ 8% | Inactive cells |
| Dim cell stroke | `#B8FF57` @ 10% | Inactive cell border |

## Pattern

3x3 matrix, diagonal glow pattern:
```
[lime]  [dim]   [orange]
[dim]   [pink]  [dim]
[orange][dim]   [lime]
```

## Converting to PNG

```bash
# Requires librsvg (brew install librsvg)
rsvg-convert -w 1024 -h 1024 odds-icon-6c-color.svg > icon_1024.png
rsvg-convert -w 256 -h 256 odds-icon-6c-color.svg > icon_256.png
rsvg-convert -w 18 -h 18 odds-menubar-template.svg > menubar_icon.png
```

## Converting to ICNs

```bash
mkdir odds.iconset
rsvg-convert -w 16 odds-icon-6c-color.svg > odds.iconset/icon_16x16.png
rsvg-convert -w 32 odds-icon-6c-color.svg > odds.iconset/icon_16x16@2x.png
# ... (all sizes)
iconutil -c icns odds.iconset -o AppIcon.icns
```
