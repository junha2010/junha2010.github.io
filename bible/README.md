# Bible Project

## What This Project Is

This folder contains a static Bible reader built with plain HTML, CSS, and JavaScript.

There is:

- no framework
- no package manager
- no backend
- no build tool required just to run the reader

The main app lives in [index.html](./index.html). Most of the active UI, styling, and logic are in that single file.

## Main Goal

This project is meant to feel like a polished Bible reading app, not a developer demo. The experience should stay clean, readable, fast, and consistent across desktop and mobile.

The app currently supports:

- `NIV`
- `KJV`
- `LXX`

The LXX data is Old Testament only.

## Core Product Behavior

The reader is designed around these main flows:

- reading a chapter verse-by-verse
- opening the Bible menu and jumping to a book, chapter, or verse
- switching Bible versions
- using compare mode to read two versions side by side
- tapping a word or place to open a dictionary or map popup
- opening a verse action popup by long-press on mobile or right-click on desktop
- copying or emailing a verse through the custom verse popup

## UI Style To Preserve

This section is important. Future edits should keep this visual direction unless there is a strong reason to change it.

### Overall feel

- Rounded UI, not boxy UI
- Soft cards and soft borders
- Clean white/light surfaces in light mode
- Matching dark mode, not a broken inversion
- Calm, minimal, modern interface
- Reading-first layout with generous whitespace

### Things that should stay visually consistent

- rounded buttons
- rounded dropdowns / pickers
- rounded popups and panels
- subtle shadows, not heavy harsh shadows
- soft borders, not dark thick outlines
- smooth spacing and breathing room
- simple, polished motion

### Things to avoid

- default browser-looking controls when a custom control already exists
- square or sharp-cornered UI that clashes with the rest of the app
- flashy animations
- cluttered toolbars
- developer-looking debug UI
- sudden layout jumps

## Theme Rules

The reader supports both light mode and dark mode.

Future UI work should make sure:

- both modes stay readable
- popups and overlays look intentional in both modes
- custom controls do not fall back to ugly native-looking states in dark mode
- verse accents still communicate Old Testament vs New Testament clearly

## Testament Styling

The reading view uses different accent colors by testament.

- Old Testament uses the blue accent family
- New Testament uses the red accent family

This color distinction should stay consistent in:

- verse markers
- active chapter buttons
- other testament-sensitive UI states

## Mobile UX Rules

Mobile behavior matters a lot in this project.

Future edits should preserve these priorities:

- the app must feel good on phones, not like a desktop page squeezed down
- long press should work reliably on a verse
- normal tap should stay separate from long press
- dictionary and map popups should open on tap, not on long press
- scrolling should never accidentally trigger the long-press verse menu
- fixed or sticky navigation should not cover important content
- footer credits should remain readable on mobile

## Desktop UX Rules

Desktop should feel natural too.

- right-click on a verse should open the custom verse menu
- the native browser context menu should stay blocked in the reading UI
- compare mode should remain usable and balanced
- desktop interactions should not break mobile behavior

## Verse Popup Rules

The custom verse popup is an important part of the app now.

It should keep these behaviors:

- opens from mobile long press or desktop right-click
- shows the selected verse reference
- includes a custom version picker
- previews the selected verse in another translation inside the popup
- does not switch the whole reader just because the popup preview version changes
- uses round action buttons
- supports copy and email actions
- closes when clicking outside or pressing `Escape`

## Bible Menu Rules

The Bible menu is a major navigation feature.

It should keep these behaviors:

- easy movement between books, chapters, and verses
- back navigation should remember scroll position so the user returns to where they were
- jumping to the last verses of a chapter should not scroll so far that the credits dominate the screen
- mobile and desktop should behave consistently

## Compare Mode Rules

Compare mode is a major feature and should be protected when making layout changes.

Expected behavior:

- primary and secondary panes both keep full borders
- the primary Bible remains readable and independent
- the secondary Bible should show a clear message if a chosen version does not contain that book
- when `LXX` is selected for a New Testament passage, the UI should explain that LXX only has the Old Testament
- compare mode should work on both desktop and mobile

## Copy Protection / Reader Control

This project intentionally limits normal copy behavior in the page.

Current direction:

- text selection is restricted
- native copy/cut/context menu behavior is blocked in the reading interface
- custom verse actions are used instead

If this behavior is changed later, it should be changed carefully because it affects both mobile and desktop interactions.

## Data Sources

### NIV

- Source folder: [Bible-niv-main](./Bible-niv-main)
- Bundled data: [data/verses.json](./data/verses.json) and [data/verses.js](./data/verses.js)

### KJV

- Source folder: [Bible-kjv-main](./Bible-kjv-main)
- Bundled data: [data/verses-kjv.json](./data/verses-kjv.json) and [data/verses-kjv.js](./data/verses-kjv.js)

### LXX

- Source source: bundled public-domain Brenton USFM data in [brenton-source](./brenton-source)
- Imported / converted local set: [Bible-lxx-pdf-main](./Bible-lxx-pdf-main)
- Bundled data: [data/verses-lxx.json](./data/verses-lxx.json) and [data/verses-lxx.js](./data/verses-lxx.js)

Important note:

- `LXX` in this app is Old Testament only
- book names should follow the original source naming used by the imported LXX source data

## Other Content Bundles

This project also includes local supporting content for Bible study features.

- dictionary files in [dictionary](./dictionary)
- map and location media in [img/location](./img/location)
- generated location/media manifests in [data](./data)

## Main File Structure

- [index.html](./index.html): main reader, active UI, active logic
- [README.md](./README.md): this project guide
- [data](./data): bundled browser-ready verse and location data
- [Bible-niv-main](./Bible-niv-main): NIV source data
- [Bible-kjv-main](./Bible-kjv-main): KJV source data
- [Bible-lxx-pdf-main](./Bible-lxx-pdf-main): local imported LXX data used by the reader
- [brenton-source](./brenton-source): Brenton source used for LXX import
- [img/location](./img/location): local maps and location images
- [dictionary](./dictionary): local dictionary content
- [css](./css): older / alternate split-file styling
- [js](./js): older / alternate split-file logic

## Architecture Notes

The current app is intentionally simple.

- HTML structure is in `index.html`
- CSS is mostly inline in the `<style>` block
- JavaScript is mostly inline in the `<script>` block

This is the canonical implementation right now.

The split-file assets in [css](./css) and [js](./js) are not the main version of the app.

## Runtime Behavior

When the page runs, it:

1. loads available Bible bundles
2. initializes the current translation and reading state
3. renders the active chapter
4. supports menu-driven navigation between books, chapters, and verses
5. supports compare mode
6. supports dictionary and map popups
7. supports verse popup actions for copy / email / translation preview

## Important JavaScript Areas In `index.html`

These areas are worth protecting when editing:

- translation definitions and translation option rendering
- state management for current translation, chapter, compare mode, and theme
- LXX source/canonical name mapping
- menu rendering and navigation state
- verse rendering
- compare mode synchronization
- mobile long-press handling
- desktop right-click verse menu handling
- dictionary and location modal logic
- copy protection logic

## Scripts

This folder includes several maintenance scripts used to build or refresh local data.

Examples:

- [build_full_bundle.ps1](./build_full_bundle.ps1)
- [import_brenton_lxx.ps1](./import_brenton_lxx.ps1)
- [clean_lxx_json.ps1](./clean_lxx_json.ps1)
- [build_locations_index.ps1](./build_locations_index.ps1)
- [build_location_media_manifest.ps1](./build_location_media_manifest.ps1)
- [build_word_dictionary.ps1](./build_word_dictionary.ps1)

These scripts are project maintenance tools. The app itself is still just a static front end.

## Running The Project

You can open [index.html](./index.html) directly in a browser.

No server is strictly required because local browser bundles are checked in.

If you want the app to behave more like a normal website while developing, you can also serve the repo locally with any small static server.

## Maintenance Guidelines

When making future changes:

- prefer preserving the existing reading experience over large rewrites
- keep mobile behavior in sync with desktop behavior
- test light mode and dark mode
- test compare mode after layout changes
- test the Bible menu after navigation changes
- test long press and right click after interaction changes
- test LXX edge cases, especially New Testament restrictions
- avoid changing source book names unless the source data itself changes

## Known Project Priorities

These priorities should guide future work:

- polished UX over flashy complexity
- consistent rounded visual language
- accurate Bible data presentation
- clear LXX limitations
- strong mobile usability
- custom in-app actions instead of default browser copy behavior

## If You Edit This Project Later

Please treat this as a reading product, not just a page of text.

If you add features, they should feel like they belong with the existing app. If you restyle something, it should still match the calm rounded design already established here.
