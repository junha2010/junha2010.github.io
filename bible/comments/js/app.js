const menuToggle = document.getElementById('menuToggle');
const menuClose = document.getElementById('menuClose');
const verseMenu = document.getElementById('verseMenu');
const verseList = document.getElementById('verseList');
const chapterEl = document.getElementById('chapter');

menuToggle.addEventListener('click', () => {
  verseMenu.classList.add('open');
  verseMenu.setAttribute('aria-hidden', 'false');
});

menuClose.addEventListener('click', () => {
  verseMenu.classList.remove('open');
  verseMenu.setAttribute('aria-hidden', 'true');
});

async function render() {
  try {
    const res = await fetch('data/verses.json');
    if (!res.ok) throw new Error('Could not load Genesis data');
    const data = await res.json();
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
