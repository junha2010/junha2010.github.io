const menuToggle = document.getElementById('menuToggle');
const menuClose = document.getElementById('menuClose');
const verseMenu = document.getElementById('verseMenu');
const verseList = document.getElementById('verseList');
const chapterEl = document.getElementById('chapter');
const LOCAL_BUNDLE = '../data/verses.js';
const LOCAL_JSON = '../data/verses.json';

menuToggle.addEventListener('click', () => {
  verseMenu.classList.add('open');
  verseMenu.setAttribute('aria-hidden', 'false');
});

menuClose.addEventListener('click', () => {
  verseMenu.classList.remove('open');
  verseMenu.setAttribute('aria-hidden', 'true');
});

function loadScript(src) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = src;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error(`Could not load ${src}`));
    document.head.appendChild(script);
  });
}

async function loadGenesisData() {
  if (window.BIBLE_DATA) {
    return window.BIBLE_DATA;
  }

  if (window.location.protocol === 'file:') {
    await loadScript(LOCAL_BUNDLE);
    return window.BIBLE_DATA || null;
  }

  const res = await fetch(LOCAL_JSON);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return await res.json();
}

async function render() {
  try {
    const data = await loadGenesisData();
    if (!data) throw new Error('Could not load Genesis data');
    const verses = data.Genesis['1'];
    if (!Array.isArray(verses)) throw new Error('Genesis 1 not found');

    verseList.innerHTML = '';
    chapterEl.innerHTML = '';

    verses.forEach((text, idx) => {
      const number = idx + 1;

      const item = document.createElement('li');
      const button = document.createElement('button');
      button.textContent = `${number}. ${text.slice(0, 38)}...`;
      button.onclick = () => {
        document.getElementById(`verse-${number}`).scrollIntoView({ behavior: 'smooth', block: 'start' });
        if (window.innerWidth < 900) {
          verseMenu.classList.remove('open');
          verseMenu.setAttribute('aria-hidden', 'true');
        }
      };
      item.appendChild(button);
      verseList.appendChild(item);

      const block = document.createElement('article');
      block.id = `verse-${number}`;
      block.className = 'verse-block';
      const heading = document.createElement('h3');
      heading.textContent = `Genesis 1:${number}`;
      const para = document.createElement('p');
      para.textContent = text;
      block.append(heading, para);
      chapterEl.appendChild(block);
    });
  } catch (err) {
    chapterEl.innerHTML = `<p style="color:#ff9090;">${err.message}</p>`;
  }
}

render();
