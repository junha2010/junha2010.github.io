# Program Handoff Notes

Last updated: 2026-04-08

Important limitation:
- This file is not a literal export of every conversation from the past 4-5 days.
- I do not have direct access to all past chats outside the current conversation context.
- This document is built from:
  - the current conversation
  - the current repository state
  - recent git history from the last ~5 days
- So this should be treated as a high-quality working memory / AI handoff file, not a perfect transcript.

---

## 1. Project Overview

This repository is a personal website with many HTML experiments and mini-projects, but the main actively evolving feature is the Bible reader under:

- `bible/index.html`

This Bible project has grown into a fairly advanced single-page reader with:

- multiple Bible translations
- compare mode
- reading mode
- mobile and desktop specific UI behaviors
- location popups with maps/images
- word meaning popup
- verse action menu
- developer mode / debug tooling
- strong focus on mobile usability

There are also some side pages recently touched:

- `index.html` (site homepage / page directory)
- `newtab/index.html`
- `about.html` and related pages

But the most important ongoing work is the Bible project.

---

## 2. What Has Been Built In The Bible Project So Far

Based on current code and recent commits, the Bible reader now includes:

### Core reader
- Bible chapter/verse reading UI
- top status / navigation controls
- verse highlighting and verse tracking
- chapter prev / next navigation
- book/chapter/verse navigation menu

### Bible versions
- NIV
- KJV
- LXX / Septuagint

### Translation switching
- user can switch Bible versions
- compare mode supports primary/secondary translations
- LXX is treated specially because it only has Old Testament
- there is mapping logic between canonical names and LXX source book names

### Compare mode
- two-pane compare mode
- independent primary / secondary version selectors
- optional scroll sync
- mobile compare layout support
- fallback logic when a selected book/chapter is not available in the compared translation

### Reading mode
- verse view
- reading mode with more flowing inline chapter text

### Location system
- underlined location links in verses
- location popup modal
- location descriptions
- related verse references
- map/image gallery for locations
- local bundled map/image manifest

### Word meaning system
- clickable word popup
- Korean meaning display
- local word meanings data

### Verse action menu
- right click support on desktop
- long press support on mobile
- verse preview
- copy verse
- email verse
- open the selected verse in another translation

### Settings
- reading mode toggle
- chapter tap behavior toggle
- theme toggle
- text scale slider + presets
- explanation tooltips with `!` icons

### Developer mode
- hidden developer mode / easter egg behavior
- dev HUD
- reader state inspection
- verse inspector
- interaction log
- theme lab
- type lab
- random verse jump
- search / quick jump
- x-ray / debug tooling

### Mobile-specific behavior
- mobile long press
- mobile haptic feedback
- mobile layout tuning
- mobile compare mode handling
- bottom action-sheet style verse menu
- hiding/revealing some UI chrome on scroll

### Other reader constraints
- copy/select/context menu has been intentionally restricted in many places
- zoom was disabled at one point
- there is lots of attention to animation, motion, and polished UI transitions

---

## 3. What We Worked On In This Current Conversation

These items definitely happened in this conversation and should be preserved as intent:

### A. Compare mode prev/next should go back to verse 1
User request:
- in compare mode, when pressing Prev or Next, the new chapter should go back up to verse 1

What was done:
- compare mode chapter navigation now resets both compare panes to the top of the chapter
- reset logic was strengthened to avoid old compare-sync logic restoring the previous scroll position
- then changed from jump-to-top to smooth scroll-to-top because the user wanted it to "smoothly go up to verse 1"

Current intent:
- compare mode chapter navigation should animate smoothly to the top / verse 1
- do not preserve old scroll position across chapter changes in compare mode

### B. Mobile long press should feel more like iPhone
User request:
- make long press better on mobile
- when a verse is long pressed it should shrink a bit, then get bigger and pop up like iPhone long press feedback

What was done:
- added arming state during long press
- added active popped state after the hold succeeds
- added a short delay so the animation is visible before the verse action menu opens
- reduced long press delay from 450ms to 300ms after user asked for shorter hold time

Current intent:
- long press should feel tactile and premium
- slight shrink first
- then pop/lift
- then open verse menu
- should be quick, around 300ms

### C. Settings explanations should be easier to understand
User request:
- add `!` in a circle at the top right of each settings item
- desktop: show explanation on hover
- mobile: show explanation only when clicked

What was done:
- added help buttons and tooltip bubbles for settings rows
- desktop supports hover/focus
- mobile supports click/tap to open
- clicking outside closes them
- Escape closes them too

Current intent:
- settings should be self-explanatory
- explanations should not clutter the main layout
- mobile and desktop behaviors should differ appropriately

### D. Homepage `index.html` looked broken
User reported:
- homepage looked like raw / wrong styling

What was done:
- `index.html` was moved onto its own dedicated stylesheet
- new stylesheet created: `css/index-home.css`
- homepage favicon changed to a real existing asset
- stray extra `<a></a>` removed from the bottom of the HTML

Current intent:
- homepage should be self-contained
- do not rely on shared CSS meant for older unrelated pages
- homepage is a directory page listing all HTML pages

---

## 4. Important Recent Git History Themes

Recent commits strongly suggest the following areas were actively worked on:

- dev mode additions and refinements
- mobile haptic feedback
- mobile UI fixes
- compare mode improvements
- LXX loading / cleanup
- settings transitions
- reading mode
- dark mode
- text scale
- location links and map/image handling
- right click on PC for verse menu
- long press on mobile for verse menu
- disabling copy/select/context menu
- homepage CSS connection issue
- settings explanation tooltips

This means future AI should assume:
- the Bible reader is actively iterated and polished
- preserving interaction quality matters a lot
- small UX bugs matter, especially on mobile

---

## 5. How The Bible Project Is Coded

### Main architecture
The Bible reader is mostly a single large HTML file:

- `bible/index.html`

This file contains:

- a very large inline `<style>` block
- the full HTML structure
- a very large inline `<script>` block

This means:
- much of the app is intentionally centralized
- future AI should not assume it is a modular React/Vue app
- many related UI states live together in one place

### Data sources
The project uses local bundled data rather than relying only on remote APIs.

Examples:
- `bible/data/verses.js`
- `bible/data/verses-kjv.js`
- `bible/data/verses-lxx.js`
- `bible/data/locations.json`
- `bible/data/location-media.json`
- `bible/data/word-meanings.json`

There are also source directories like:
- `Bible-niv-main`
- `Bible-kjv-main`
- `Bible-lxx-pdf-main`

### Translation model
The reader uses a translation config object with IDs like:
- `niv`
- `kjv`
- `lxx`

There is canonical-name mapping for LXX books because source names differ from standard Protestant naming.

Important example:
- `1 Samuel` may map to `Kings I`
- similar mappings exist for many LXX books

Future AI should be very careful when switching translations:
- do not compare raw book names only
- use canonical mapping helpers

### State model
There is a large `state` object in `bible/index.html`.

It tracks things like:
- current translation
- current book / chapter / verses
- compare mode status
- compare scroll sync
- reading mode
- chapter tap mode
- theme mode
- text scale
- location data
- word meanings
- mobile long press status
- verse action menu selection
- dev mode state
- dev tools state

Future AI should respect this existing pattern instead of introducing a separate competing state layer.

### UI rendering
Rendering is done by imperative DOM updates.

Examples:
- menu content is built dynamically
- verse lists are rendered into containers
- compare pane content is rendered manually
- settings and picker states are handled with class toggles and DOM attributes

### Behavior style
The project strongly prefers:
- direct DOM logic
- explicit event listeners
- lots of small helper functions
- class-based visual state changes
- animations and transitions

---

## 6. UI / UX Preferences The User Seems To Like

This section is important for future AI.

### Personal preference snapshot
This is the shortest practical summary of the user's own taste:

- the user does not like plain, dead, generic UI
- the user likes UI that feels alive, premium, and responsive
- the user especially cares about touch feel on mobile
- the user likes Apple/iPhone-like interaction quality for long press and motion
- the user notices small awkward details and wants them polished
- the user wants settings and controls to be understandable without guessing
- the user prefers desktop and mobile to each get the interaction style that fits them best, instead of forcing the same behavior everywhere
- the user likes motion, but not meaningless motion; animation should improve feel and clarity
- the user wants compare mode, verse menu behavior, and scrolling behavior to feel carefully tuned, not merely functional

### General design preference
The user likes UI that feels:
- polished
- animated
- interactive
- a little dramatic
- tactile on mobile
- not plain

The user notices when something feels awkward or unfinished.

### Motion preference
The user repeatedly asked for:
- smoother transitions
- better motion
- iPhone-like feedback
- nicer compare-mode movement
- polished settings behavior

So future AI should:
- prefer tasteful animation over abrupt changes
- use subtle scale, lift, fade, slide, blur, or transform transitions where useful
- avoid making things feel stiff or static

### Mobile preference
Mobile experience is extremely important.

The user clearly cares about:
- long press feel
- haptic feedback
- compare mode usability on small screens
- button placement
- chrome hiding/showing
- touch interactions being natural

Future AI should prioritize mobile even for features that also exist on desktop.

### Desktop preference
Desktop should still feel good, especially:
- right click support
- hover states
- compare layout
- better menu behavior

But when desktop and mobile differ, the user often wants:
- hover on desktop
- tap / long press on mobile

### Settings preference
The user wants settings to be:
- understandable
- discoverable
- not confusing

That is why help tooltips were requested.

### Visual personality
The Bible reader does not try to look extremely minimal.
It uses:
- accent colors
- shadows
- rounded cards
- transitions
- animated menus
- distinct states between OT and NT

Future AI should preserve that richer feeling.

### Things future AI should not accidentally do
- do not flatten the UI into a generic template
- do not remove motion just to simplify the code
- do not make mobile interactions feel like desktop clicks
- do not make settings harder to understand
- do not preserve technically correct but awkward behavior if it feels bad in actual use

---

## 7. Specific Mobile vs Desktop Behavior Rules

Future AI should remember these patterns:

### On desktop
- hover can reveal information
- right click can open verse actions
- compare mode can use a wider side-by-side layout
- tooltips can appear on hover/focus

### On mobile
- hover does not exist, so click/tap must be explicit
- long press is important
- action menus can feel like bottom sheets
- compare mode needs more careful scroll and layout handling
- chrome and sticky controls can interfere with reading, so motion and spacing matter

### Good example from this conversation
Settings help tooltips:
- desktop: hover/focus
- mobile: click to open, click elsewhere to close

That is exactly the kind of adaptive interaction the user wants.

---

## 8. Fine Detail Behavior To Preserve

### Compare mode
- when changing chapter with Prev/Next in compare mode, go to verse 1 / top
- do not preserve old scroll position
- should animate smoothly upward
- pending compare-sync logic must not undo the top reset

### Long press
- fast enough to feel responsive
- current target delay is about 300ms
- verse should visually react during the hold
- pop should happen before menu opens

### Settings help icons
- should be in the top-right area of each settings row
- desktop hover should work
- mobile click should work
- tapping elsewhere should close help

### Homepage
- homepage should stay on dedicated CSS
- do not accidentally reconnect it to old shared `css/style.css`
- it is intended to be a nice page directory

---

## 9. Important Files Future AI Should Read First

If a future AI continues this project, it should read these first:

### Bible core
- `bible/index.html`

### Bible data / support
- `bible/data/locations.json`
- `bible/data/location-media.json`
- `bible/data/word-meanings.json`
- `bible/data/verses.js`
- `bible/data/verses-kjv.js`
- `bible/data/verses-lxx.js`

### Homepage
- `index.html`
- `css/index-home.css`
- `js/index.js`

### Other related pages recently touched
- `newtab/index.html`
- `newtab/newtab.css`
- `newtab/newtab.js`

---

## 10. What Future AI Should Be Careful About

### 1. Do not break mobile while fixing desktop
This project has many special-case mobile behaviors.
Always think about:
- touch
- long press
- compare pane scrolling
- bottom sheet behavior
- viewport issues

### 2. Do not break translation/book mapping
LXX book naming is tricky.
Always use existing mapping helpers.

### 3. Do not remove animations carelessly
The user likes polished motion and improved feel.
Static replacements may be technically correct but still feel wrong.

### 4. Do not over-simplify the Bible UI
This is not meant to be a plain bare reader.
It is supposed to feel feature-rich and carefully tuned.

### 5. Be honest about uncertainty
If future AI is asked about older chats, it should say:
- exact past conversation text may not be available
- but repo state and this file can be used as working memory

---

## 11. Suggested Prompt For Future AI

If a future AI needs to continue this project, a good user prompt could be:

"Read `program.md` and `bible/index.html` first, then continue the Bible project without breaking the current mobile and compare-mode behavior."

Or:

"Use `program.md` as project memory. Preserve the UI style, mobile long-press feel, compare-mode behavior, and settings help behavior."

---

## 12. Short Summary In Korean

Note:
- If the Korean text below looks broken in some terminals, that is likely a terminal encoding display issue.
- The intent of this section is still the same: it is a short Korean summary for future handoff use.

지금까지 이 성경 프로젝트에서 한 핵심 작업은 대략 이런 방향이다:

- 여러 성경 번역본(NIV, KJV, LXX) 지원
- 비교 모드 추가 및 개선
- 읽기 모드 추가
- 위치 이름 클릭 시 지도/이미지 팝업
- 단어 뜻 팝업
- 모바일 롱프레스와 햅틱
- PC 우클릭 verse menu
- 설정창 개선
- 다크모드 / 글자 크기 / 모바일 UI 개선
- dev mode / debug tools 추가
- 전체적으로 모바일과 인터랙션 감각을 많이 다듬는 방향

사용자가 좋아하는 스타일은:

- 그냥 평범한 UI보다 좀 더 살아있는 UI
- 애니메이션이 자연스러운 것
- 모바일에서 아이폰처럼 반응이 좋은 것
- 설정이 직관적인 것
- compare mode, verse menu, long press 같은 세세한 경험이 좋은 것

즉, 앞으로도 이 프로젝트를 수정할 때는:

- 모바일 경험을 아주 중요하게 보고
- compare mode를 망가뜨리지 말고
- 인터랙션을 딱딱하게 만들지 말고
- 필요한 설명은 툴팁처럼 친절하게 넣는 방향

---

## 13. Final Note

This file should be updated again whenever:
- a new major Bible feature is added
- mobile interaction changes significantly
- compare mode logic changes
- homepage or main navigation philosophy changes
- the user's design preference becomes clearer
