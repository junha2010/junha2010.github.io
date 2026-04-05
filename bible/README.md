# Bible Viewer

## Overview

This repository is a small static Bible viewer built with plain HTML, CSS, and JavaScript. There is no build step, package manager, or backend.

The main page opens directly from [`index.html`](./index.html). When you open it from disk, it falls back to the bundled offline data in [`data/verses.js`](./data/verses.js); when you serve the repo over HTTP, it uses the full `Bible-niv-main` folder data.

## Current Content

The checked-in content currently includes the full 66-book Bible data set in canonical order.

## How It Works

The root page contains the full UI and logic in one file:

- markup in [`index.html`](./index.html)
- styles in an inline `<style>` block
- application logic in an inline `<script>` block

At runtime the page:

1. Reads Bible data from [`data/verses.js`](./data/verses.js) when opened from disk
2. Loads the full `Bible-niv-main` chapter data when served over HTTP
3. Loads `Genesis 1` by default
4. Renders each verse into a card in the main content area
5. Provides a menu for books, chapters, and verses
6. Provides previous and next chapter buttons

## Data Files

### `data/verses.json`

This is the structured source data for the verses. It is a nested JSON object:

```json
{
  "Genesis": {
    "1": ["Verse 1 text", "Verse 2 text"],
    "2": ["Verse 1 text", "Verse 2 text"]
  }
}
```

### `data/verses.js`

This file wraps the same content in JavaScript so the page can open directly from disk with `file://`. It exposes the data as:

```js
window.BIBLE_DATA = { ... }
```

## Repository Layout

- [`index.html`](./index.html): Main viewer and active entry point
- [`data/verses.json`](./data/verses.json): Verse source data in JSON format
- [`data/verses.js`](./data/verses.js): Browser-ready data bundle for offline use
- [`js/app.js`](./js/app.js): Older split-file viewer logic
- [`css/style.css`](./css/style.css): Styles for the split-file viewer
- [`fetch_genesis2.py`](./fetch_genesis2.py): One-off script used to append Genesis 2 to the JSON data
- [`check_genesis.py`](./check_genesis.py): Small sanity script that prints Genesis chapter coverage

## Running

Open [`index.html`](./index.html) directly in your browser. No local server is required.

If you want to regenerate the offline JSON and JavaScript bundles from the `Bible-niv-main` source files, run `powershell -ExecutionPolicy Bypass -File .\build_full_bundle.ps1` from the [`bible`](./) folder.

## Notes

- The root page is the canonical implementation.
- The split-file `js/` and `css/` files are legacy or alternate implementation files.
- The code is intentionally simple and does not use a framework.
- There is no automated test suite or CI configuration in the repository.

## Current State

The project is working as a lightweight Bible reader. The main thing to keep in sync is the verse content between [`data/verses.json`](./data/verses.json) and [`data/verses.js`](./data/verses.js), and the full `Bible-niv-main` folder if you update the main viewer data set.
