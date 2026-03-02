#!/usr/bin/env node
/**
 * render-mermaid.js — Beautiful Mermaid CLI wrapper
 *
 * Usage:
 *   node render-mermaid.js input.mmd --theme tokyo-night --output output.svg
 *   node render-mermaid.js input.mmd --theme dracula --output output.png
 *
 * Available themes:
 *   tokyo-night, dracula, nord, catppuccin-mocha, github-dark,
 *   one-dark-pro, gruvbox-dark, rose-pine, synthwave-84,
 *   solarized-dark, ayu-dark, material, night-owl, poimandres, vitesse-dark
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const args = process.argv.slice(2);

if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
  console.log(`
Usage: node render-mermaid.js <input.mmd> [options]

Options:
  --theme <name>    Theme name (default: tokyo-night)
  --output <path>   Output file path (default: <input>.svg)
  --format <fmt>    Output format: svg, png (default: svg)
  -h, --help        Show this help

Themes:
  tokyo-night, dracula, nord, catppuccin-mocha, github-dark,
  one-dark-pro, gruvbox-dark, rose-pine, synthwave-84,
  solarized-dark, ayu-dark, material, night-owl, poimandres, vitesse-dark
`);
  process.exit(0);
}

const inputFile = args[0];
let theme = 'tokyo-night';
let outputFile = null;
let format = 'svg';

for (let i = 1; i < args.length; i++) {
  if (args[i] === '--theme' && args[i + 1]) {
    theme = args[++i];
  } else if (args[i] === '--output' && args[i + 1]) {
    outputFile = args[++i];
  } else if (args[i] === '--format' && args[i + 1]) {
    format = args[++i];
  }
}

if (!outputFile) {
  const ext = format === 'png' ? '.png' : '.svg';
  outputFile = inputFile.replace(/\.(mmd|mermaid|md)$/, ext);
  if (outputFile === inputFile) {
    outputFile = inputFile + ext;
  }
}

if (!fs.existsSync(inputFile)) {
  console.error(`Error: Input file not found: ${inputFile}`);
  process.exit(1);
}

const bmPath = path.join(
  process.env.HOME,
  '.local/share/npm-global/node_modules/.bin/beautiful-mermaid'
);
const bmModulePath = path.join(
  process.env.HOME,
  '.local/share/npm-global/node_modules/beautiful-mermaid'
);

if (!fs.existsSync(bmModulePath)) {
  console.error('Error: beautiful-mermaid not found. Install with:');
  console.error('  npm install beautiful-mermaid --prefix ~/.local/share/npm-global');
  process.exit(1);
}

try {
  const cmd = `npx --prefix ~/.local/share/npm-global beautiful-mermaid render "${inputFile}" --theme ${theme} --output "${outputFile}"`;
  console.log(`Rendering: ${inputFile} -> ${outputFile} (theme: ${theme})`);
  execSync(cmd, { stdio: 'inherit' });
  console.log(`Done: ${outputFile}`);
} catch (err) {
  console.error(`Render failed. Trying direct module invocation...`);
  try {
    const cmd2 = `node "${bmModulePath}/dist/cli.js" render "${inputFile}" --theme ${theme} --output "${outputFile}"`;
    execSync(cmd2, { stdio: 'inherit' });
    console.log(`Done: ${outputFile}`);
  } catch (err2) {
    console.error(`Both render methods failed: ${err2.message}`);
    process.exit(1);
  }
}
