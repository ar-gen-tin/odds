<div align="center">

# odds

**A terminal-styled prediction market tracker living in your macOS menu bar**

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-black?logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-brightgreen)](https://github.com/ar-gen-tin/odds/releases)

</div>

---

## What is odds?

odds is a macOS menu bar app that tracks prediction markets from [Polymarket](https://polymarket.com) in real time. It renders live odds, price changes, and sparkline trends in a compact terminal-aesthetic panel — always one click away from your menu bar.

- **Live data** — polls Polymarket API with configurable refresh intervals
- **Watchlist** — save markets you care about, persisted across launches
- **Search** — find any Polymarket event and add it to your feed
- **Terminal UI** — monospace typography, dot leaders, ASCII sparklines, orange accent

> Track the odds from your menu bar.

---

## Features

### Live Market Feed

Real-time prediction market data with probability, daily change, and trend sparklines:

| Column | Description |
|--------|-------------|
| IDX | Row index |
| MARKET | Event name with dot leader |
| PROB | Current probability (cents / dollar / percent) |
| Delta | 24h price change |
| TREND | Unicode block sparkline (▁▂▃▅▆▇) |

### Tab Filtering

| Tab | Content |
|-----|---------|
| ALL | Watchlist + trending (deduplicated) |
| TRENDING | Top markets by 24h volume |
| POLITICS | Political events |
| CRYPTO | Cryptocurrency markets |
| WATCH | Your saved markets |

### Search & Add

- `Cmd+F` or click the search icon to open search
- Debounced API search (300ms) with live results
- `[+ ADD]` button with immediate `[check]` confirmation
- ESC to dismiss

### Expandable Market Detail

Click any row to expand:
- Wide sparkline (25-character interpolated)
- VOL / 24H / PRICE stats with color-coded delta
- `[OPEN_ON_POLY]` — opens Polymarket in browser
- `[+ WATCHLIST]` / `[check WATCHLIST]` — add/remove with confirmation flash

### Settings (Terminal Style)

```
DISPLAY
├─ PRICE_FORMAT    [72c] [$0.72] [72%]
├─ SPARKLINES      [ON] [OFF]
├─ REFRESH_RATE    [10s] [30s] [60s]

LANGUAGE
├─ LOCALE          [EN] [Chinese] [Japanese]

DATA
├─ SOURCE          POLYMARKET
├─ STATUS          CONNECTED    (live status)
├─ LAST_SYNC       14:32:01 UTC
```

### Footer Ticker

Scrolling ticker tape with edge-fade masks — top 8 markets with name, price, and delta arrows.

### Onboarding

Boot-sequence animation with terminal-style progress:
```
> SYS_INIT............OK
> API_CONNECT.........OK
> FEED_SUBSCRIBE......PENDING
> MARKETS_LOADED......0
```

---

## Design

| Element | Spec |
|---------|------|
| Font | IBM Plex Mono (Regular / Medium / SemiBold) |
| Background | Navy-tinted near-black (`#0A0A0F`) |
| Accent | Orange (`#FF6B2C`) |
| Positive | Aurora lime (`#B8FF57`) |
| Negative | Hot pink (`#FF3B5C`) |
| Panel | 380 x 620 px |
| Row height | 36 px |

---

## Project Statistics

| Metric | Value |
|--------|-------|
| **Language** | Swift 5.9 (100%) |
| **Source Files** | 22 Swift files |
| **Lines of Code** | ~2,400 |
| **Modules** | Models (1) / Services (3) / Theme (2) / Utilities (4) / Views (12) |
| **i18n** | EN / Chinese / Japanese |
| **Min Deployment** | macOS 14.0 Sonoma |

---

## Requirements

| Item | Requirement |
|------|-------------|
| **OS** | macOS 14.0 (Sonoma) or later |
| **Build** | Swift 5.9+ / Xcode 15+ |

---

## Installation

### Option 1: DMG (Recommended)

Download the latest `.dmg` from [Releases](https://github.com/ar-gen-tin/odds/releases) and drag to Applications.

### Option 2: Build from Source

```bash
git clone https://github.com/ar-gen-tin/odds.git
cd odds/Odds
swift build -c release
```

The binary is at `.build/release/Odds`.

To create an `.app` bundle, copy the built binary into the included `odds.app/Contents/MacOS/`.

---

## Architecture

```
Polymarket API (HTTPS)
    |
PolymarketAPI (URLSession, JSON parsing)
    |
MarketStore (@Published, Combine timer)
    |--- watchlist: [Market]    (persisted via UserDefaults + Codable)
    |--- trending: [Market]     (refreshed on interval)
    |--- watchlistIDs: Set<String>
    |
SettingsStore (@Published + UserDefaults)
    |--- language / priceFormat / refreshInterval / showSparklines
    |
PanelView (SwiftUI)
    |--- StatusBarView      (brand + live indicator + search/settings)
    |--- TabBarView         (ALL | TRENDING | POLITICS | CRYPTO | WATCH)
    |--- ColumnHeaderView   (IDX | MARKET | PROB | Delta | TREND)
    |--- MarketRowView      (dot leader + sparkline + expand/add)
    |--- ExpandedAreaView   (detail stats + action buttons)
    |--- SearchBarView      (auto-focus + debounce + typing indicator)
    |--- FooterTickerView   (scrolling ticker with edge fade)
    |--- SettingsView       (terminal tree UI)
    |--- OnboardingView     (boot sequence animation)
```

### Project Structure

```
Odds/
├── Package.swift
└── Sources/
    ├── OddsApp.swift              # @main entry, MenuBarExtra
    ├── Models/
    |   └── Market.swift           # Market struct, PriceTrend enum
    ├── Services/
    |   ├── MarketStore.swift      # Data store, watchlist, API polling
    |   ├── PolymarketAPI.swift    # API client, search, parsing
    |   └── SettingsStore.swift    # User preferences
    ├── Theme/
    |   ├── OddsTheme.swift        # Colors, layout constants
    |   └── OddsFonts.swift        # IBM Plex Mono font registration
    ├── Utilities/
    |   ├── EdgeBorder.swift       # Edge-specific border modifier
    |   ├── Formatters.swift       # Shared Fmt helpers
    |   ├── Localization.swift     # L10n trilingual string system
    |   └── MockData.swift         # Fallback data
    └── Views/
        ├── PanelView.swift        # Main container
        ├── StatusBarView.swift    # Top bar with live pulse
        ├── TabBarView.swift       # Category tabs
        ├── ColumnHeaderView.swift # Table header
        ├── MarketRowView.swift    # Market row with dot leader
        ├── ExpandedAreaView.swift # Expanded detail + action buttons
        ├── SearchBarView.swift    # Search input
        ├── FooterTickerView.swift # Scrolling ticker
        ├── SectionDividerView.swift
        ├── SettingsView.swift     # Settings panel
        └── OnboardingView.swift   # First-run setup
```

---

## Roadmap

- [x] v0.1.0 — Core: live feed, watchlist, search, tabs, settings, 3-language i18n
- [ ] v0.2.0 — Keyboard navigation, market categories, price alerts
- [ ] v0.3.0 — Portfolio tracking, P&L calculation
- [ ] v1.0.0 — Launch at login, auto-update, notarized DMG

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

<div align="center">

**Track the odds from your menu bar.**

[Download](https://github.com/ar-gen-tin/odds/releases)

</div>
