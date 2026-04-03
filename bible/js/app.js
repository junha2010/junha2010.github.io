const bookEl = document.querySelector('#book');
const chapterEl = document.querySelector('#chapter');
const versesEl = document.querySelector('#verses');
const loadBtn = document.querySelector('#load');

let bibleData = {};

function setBookOptions() {
    bookEl.innerHTML = '';

    Object.keys(bibleData).forEach((bookName) => {
        const option = document.createElement('option');
        option.value = bookName;
        option.textContent = bookName;
        bookEl.append(option);
    });

    const selectedBook = bookEl.value;
    updateChapterBounds(selectedBook);
}

function updateChapterBounds(bookName) {
    const chapters = bibleData[bookName] ? Object.keys(bibleData[bookName]).map(Number) : [];
    const maxChapter = chapters.length ? Math.max(...chapters) : 1;

    chapterEl.max = maxChapter;
    chapterEl.value = Math.min(Math.max(Number(chapterEl.value), 1), maxChapter);
}

function renderVerses() {
    const bookName = bookEl.value;
    const chapter = Number(chapterEl.value);

    if (!bibleData[bookName] || !bibleData[bookName][chapter]) {
        versesEl.innerHTML = '<p class="hint">No verses available for this selection.</p>';
        return;
    }

    versesEl.innerHTML = '';

    const chapterHeading = document.createElement('h2');
    chapterHeading.className = 'chapter-heading';
    chapterHeading.textContent = `Chapter ${chapter}`;
    versesEl.append(chapterHeading);

    bibleData[bookName][chapter].forEach((verseText, idx) => {
        const p = document.createElement('p');
        p.className = 'verse';
        p.innerHTML = `<span class="ref">${bookName} ${chapter}:${idx + 1}</span> ${verseText}`;
        versesEl.append(p);
    });
}

async function loadBibleData() {
    try {
        const response = await fetch('data/verses.json');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        bibleData = await response.json();
        setBookOptions();
        renderVerses();
    } catch (error) {
        versesEl.innerHTML = `<p class="hint">Unable to load Bible data: ${error.message}</p>`;
    }
}

bookEl.addEventListener('change', () => {
    updateChapterBounds(bookEl.value);
    renderVerses();
});

loadBtn.addEventListener('click', renderVerses);

loadBibleData();
