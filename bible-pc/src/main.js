const path = require('path');
const { app, BrowserWindow, shell } = require('electron');

const APP_URL = 'https://junha2010.github.io/bible/';
const APP_HOST = 'junha2010.github.io';
const APP_PATH_PREFIX = '/bible';
const APP_ICON = path.join(__dirname, '..', 'build', 'icon.png');
const DESIGN_WIDTH = 1180;
const DESIGN_HEIGHT = 760;
const MIN_ZOOM = 0.84;
const RESPONSIVE_CSS = `
  :root {
    --reader-side-gutter: clamp(1.25rem, 7vw, 6.75rem);
  }

  .content {
    width: min(1180px, calc(100vw - (var(--reader-side-gutter) * 2))) !important;
    max-width: none !important;
    padding-inline: clamp(1rem, 2vw, 1.75rem) !important;
  }

  body.compare-mode .content {
    width: auto !important;
  }

  @media (max-width: 760px), (max-height: 640px) {
    .content {
      margin-bottom: 7rem !important;
      padding-bottom: calc(5.8rem + env(safe-area-inset-bottom)) !important;
    }

    .chapter-nav-bar {
      position: fixed !important;
      left: clamp(0.85rem, 3vw, 1.5rem) !important;
      right: clamp(0.85rem, 3vw, 1.5rem) !important;
      bottom: calc(0.95rem + env(safe-area-inset-bottom)) !important;
      z-index: 40 !important;
      display: grid !important;
      grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
      gap: 0.7rem !important;
      height: auto !important;
      margin-top: 0 !important;
      pointer-events: none !important;
    }

    body.compare-mode .chapter-nav-bar {
      left: clamp(0.85rem, 3vw, 1.5rem) !important;
      right: clamp(0.85rem, 3vw, 1.5rem) !important;
      bottom: calc(0.95rem + env(safe-area-inset-bottom)) !important;
    }

    .nav-btn {
      position: static !important;
      top: auto !important;
      width: 100% !important;
      height: 3.25rem !important;
      border-radius: 1rem !important;
      font-size: 1.04rem !important;
      z-index: auto !important;
      box-shadow: 0 10px 28px rgba(15, 23, 42, 0.16) !important;
      background: color-mix(in srgb, var(--surface) 70%, transparent) !important;
      pointer-events: auto !important;
      touch-action: manipulation !important;
      transform: none !important;
    }

    body.dark-mode .nav-btn {
      background: color-mix(in srgb, var(--surface) 82%, transparent) !important;
    }

    .nav-btn:active {
      transform: scale(0.975) !important;
    }

    .prev-btn,
    .next-btn {
      left: auto !important;
      right: auto !important;
    }

    .nav-btn-label {
      display: inline !important;
    }
  }
`;

function isBibleAppUrl(rawUrl) {
  try {
    const url = new URL(rawUrl);
    return (
      (url.protocol === 'https:' || url.protocol === 'http:') &&
      url.hostname.toLowerCase() === APP_HOST &&
      url.pathname.startsWith(APP_PATH_PREFIX)
    );
  } catch {
    return false;
  }
}

async function openExternal(rawUrl) {
  try {
    await shell.openExternal(rawUrl);
  } catch {
    // Ignore failed handoff attempts so a bad external link cannot crash the app.
  }
}

function getResponsiveZoom(win) {
  const bounds = win.getContentBounds();
  const widthScale = bounds.width / DESIGN_WIDTH;
  const heightScale = bounds.height / DESIGN_HEIGHT;
  return Math.min(1, Math.max(MIN_ZOOM, Math.min(widthScale, heightScale)));
}

function applyResponsiveZoom(win) {
  if (win.isDestroyed()) {
    return;
  }

  win.webContents.setZoomFactor(getResponsiveZoom(win));
}

function queueResponsiveZoom(win) {
  clearTimeout(win.responsiveZoomTimer);
  win.responsiveZoomTimer = setTimeout(() => applyResponsiveZoom(win), 80);
}

async function applyResponsiveCss(win) {
  try {
    await win.webContents.insertCSS(RESPONSIVE_CSS, { cssOrigin: 'author' });
  } catch {
    // The page can still use its own responsive CSS if injection is unavailable.
  }
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1180,
    height: 820,
    minWidth: 360,
    minHeight: 560,
    title: 'Bible Viewer',
    icon: APP_ICON,
    autoHideMenuBar: true,
    backgroundColor: '#ffffff',
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  win.on('resize', () => queueResponsiveZoom(win));
  win.webContents.on('did-finish-load', () => {
    applyResponsiveCss(win);
    applyResponsiveZoom(win);
  });

  win.webContents.setWindowOpenHandler(({ url }) => {
    if (isBibleAppUrl(url)) {
      return { action: 'allow' };
    }

    openExternal(url);
    return { action: 'deny' };
  });

  win.webContents.on('will-navigate', (event, url) => {
    if (isBibleAppUrl(url)) {
      return;
    }

    event.preventDefault();
    openExternal(url);
  });

  win.loadURL(APP_URL);
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
