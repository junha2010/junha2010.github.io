import { copyFileSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const builtHtmlPath = resolve('dist/dev.html');
const html = readFileSync(builtHtmlPath, 'utf8')
  .replace(/\.\/assets\//g, './dist/assets/')
  .replace(/\.\/img\//g, './img/');

writeFileSync(resolve('index.html'), html, 'utf8');
copyFileSync(builtHtmlPath, resolve('dist/index.html'));