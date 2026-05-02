const pagePaths = [
    "./about.html",
    "./about/index.html",
    "./ag.html",
    "./ale.html",
    "./alfsc.html",
    "./ba.html",
    "./bible/comments/index.html",
    "./bible/index.html",
    "./bible/wikipedia-list-of-biblical-places.html",
    "./brainwash/index.html",
    "./cake.html",
    "./camaera.html",
    "./cl.html",
    "./clicker/index.html",
    "./clicker/secclicker/index.html",
    "./clicker/thirdclicker/index.html",
    "./clock.html",
    "./coloring.html",
    "./Crosses.html",
    "./csseffect.html",
    "./d.html",
    "./darkmode.html",
    "./dbhe.html",
    "./dd.html",
    "./dice.html",
    "./family.html",
    "./family/family.html",
    "./family/home.html",
    "./home.html",
    "./home/index.html",
    "./home2.html",
    "./idle.html",
    "./in.html",
    "./index.html",
    "./index2.html",
    "./MagicNavigationMenu.html",
    "./math/index.html",
    "./math/intro.html",
    "./members/index.html",
    "./minesweeper/index.html",
    "./mmg.html",
    "./moonlight.html",
    "./moving.html",
    "./newtab/index.html",
    "./ng.html",
    "./periodic_table/index.html",
    "./projects.html",
    "./RGB.html",
    "./s.html",
    "./sc.html",
    "./search.html",
    "./simple.html",
    "./SimpleMagicNavigation.html",
    "./slowmotion.html",
    "./snake.html",
    "./space.html",
    "./sport.html",
    "./test.html",
    "./test/bar/index.html",
    "./test/betting game/index.html",
    "./test/cursor/index.html",
    "./test/design/box/index.html",
    "./test/download/index.html",
    "./test/download/minecraft.html",
    "./test/index.html",
    "./test/mouse/index.html",
    "./test/mousehover/index.html",
    "./test/mousetrail/index.html",
    "./test/popup/index.html",
    "./test/size/index.html",
    "./test/slot/index.html",
    "./test/study/index.html",
    "./test/vertecal/index.html",
    "./video.html",
    "./word.html",
    "./ww.html",
    "./x3d.html"
];

function formatTitle(path) {
    const cleanPath = path.replace(/^\.\//, "");
    const segments = cleanPath.split("/");
    const lastSegment = segments[segments.length - 1];

    if (lastSegment.toLowerCase() === "index.html") {
        return segments.length === 1 ? "Home" : segments[segments.length - 2];
    }

    return lastSegment.replace(/\.html$/i, "");
}

function createPageCard(path) {
    const link = document.createElement("a");
    const title = document.createElement("span");
    const pagePath = document.createElement("small");

    link.className = "page-card";
    link.href = path;

    title.className = "page-card__title";
    title.textContent = formatTitle(path);

    pagePath.className = "page-card__path";
    pagePath.textContent = path.replace(/^\.\//, "");

    link.append(title, pagePath);
    return link;
}

function renderPageLinks() {
    const grid = document.getElementById("link-grid");

    if (!grid) {
        return;
    }

    const cards = pagePaths.map(createPageCard);
    grid.append(...cards);
}

renderPageLinks();
