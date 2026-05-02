const { app, BrowserWindow, shell } = require('electron');

const APP_URL = 'https://junha2010.github.io/bible/';
const APP_HOST = 'junha2010.github.io';
const APP_PATH_PREFIX = '/bible';

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

function createWindow() {
  const win = new BrowserWindow({
    width: 1180,
    height: 820,
    minWidth: 360,
    minHeight: 560,
    title: 'Bible Viewer',
    autoHideMenuBar: true,
    backgroundColor: '#ffffff',
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
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
