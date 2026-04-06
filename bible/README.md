# Bible Viewer

## Overview

This repository is a small static Bible viewer built with plain HTML, CSS, and JavaScript. There is no build step, package manager, or backend.

The main page opens directly from [`index.html`](./index.html). When you open it from disk, it falls back to the bundled offline data in [`data/verses.js`](./data/verses.js) and [`data/verses-kjv.js`](./data/verses-kjv.js); when you serve the repo over HTTP, it uses the full `Bible-niv-main` and `Bible-kjv-main` folder data.

## Current Content

The checked-in content currently includes the full 66-book Bible data set in canonical order for both NIV and KJV.

## How It Works

The root page contains the full UI and logic in one file:

- markup in [`index.html`](./index.html)
- styles in an inline `<style>` block
- application logic in an inline `<script>` block

At runtime the page:

1. Reads Bible data from [`data/verses.js`](./data/verses.js) and [`data/verses-kjv.js`](./data/verses-kjv.js) when opened from disk
2. Loads the full `Bible-niv-main` or `Bible-kjv-main` chapter data when served over HTTP
3. Loads `Genesis 1` by default
4. Renders each verse into a card in the main content area
5. Provides a menu for books, chapters, and verses
6. Provides previous and next chapter buttons
7. Lets the reader switch between NIV and KJV in the top bar

## Data Files

### `data/verses.json` and `data/verses-kjv.json`

This is the structured source data for the verses. It is a nested JSON object:

```json
{
  "Genesis": {
    "1": ["Verse 1 text", "Verse 2 text"],
    "2": ["Verse 1 text", "Verse 2 text"]
  }
}
```

### `data/verses.js` and `data/verses-kjv.js`

These files wrap the same content in JavaScript so the page can open directly from disk with `file://`. They expose the data as:

```js
window.BIBLE_DATA_BUNDLES = {
  niv: { ... },
  kjv: { ... }
}
```

## Repository Layout

- [`index.html`](./index.html): Main viewer and active entry point
- [`Bible-niv-main`](./Bible-niv-main): Full NIV source files by book
- [`Bible-kjv-main`](./Bible-kjv-main): Full KJV source files by book
- [`data/verses.json`](./data/verses.json): NIV verse source data in JSON format
- [`data/verses.js`](./data/verses.js): NIV browser-ready data bundle for offline use
- [`data/verses-kjv.json`](./data/verses-kjv.json): KJV verse source data in JSON format
- [`data/verses-kjv.js`](./data/verses-kjv.js): KJV browser-ready data bundle for offline use
- [`js/app.js`](./js/app.js): Older split-file viewer logic
- [`css/style.css`](./css/style.css): Styles for the split-file viewer
- [`fetch_genesis2.py`](./fetch_genesis2.py): One-off script used to append Genesis 2 to the JSON data
- [`check_genesis.py`](./check_genesis.py): Small sanity script that prints Genesis chapter coverage

## Running

Open [`index.html`](./index.html) directly in your browser. No local server is required.

If you want to regenerate the offline NIV JSON and JavaScript bundle from the `Bible-niv-main` source files, run `powershell -ExecutionPolicy Bypass -File .\build_full_bundle.ps1` from the [`bible`](./) folder.

To regenerate the KJV bundle, run `powershell -ExecutionPolicy Bypass -File .\build_full_bundle.ps1 -SourceDir 'Bible-kjv-main' -JsonOut 'data\verses-kjv.json' -JsOut 'data\verses-kjv.js' -BundleKey 'kjv' -LegacyGlobalName 'BIBLE_DATA_KJV'`.

## Notes

- The root page is the canonical implementation.
- The split-file `js/` and `css/` files are legacy or alternate implementation files.
- The code is intentionally simple and does not use a framework.
- There is no automated test suite or CI configuration in the repository.

## Current State

The project is working as a lightweight Bible reader. The main thing to keep in sync is the verse content between each source folder and its paired offline bundle for both translations.
