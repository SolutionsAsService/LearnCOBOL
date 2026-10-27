// Regenerates programs.js from the .cbl sources in this repository plus the
// hand-checked notes in tools/program-notes.json.
//
//   node tools/index-programs.mjs
//
// The site displays figures produced here; every figure printed on the page is
// reproducible by re-running this file. program-notes.json is authored, not
// generated: it holds the one-line summary, category and teaching point for
// each program, and this script only joins it to the measured facts.

import { readdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const REPO = 'https://github.com/SolutionsAsService/LearnCOBOL/blob/main';

const notes = new Map(
  JSON.parse(await readFile(join(root, 'tools', 'program-notes.json'), 'utf8')).map((n) => [n.file, n]),
);

const files = (await readdir(root)).filter((f) => f.endsWith('.cbl')).sort();

const programs = [];
/* Where the code actually begins, counted over the whole corpus: the fixed
   format wants headers in Area A (column 8), so this measures the distance
   between the 1960 rule and the files as they are. */
const startCounts = {};
let countedLines = 0;
for (const file of files) {
  const src = await readFile(join(root, file), 'utf8');

  // A file that ends in a newline splits into a final empty string. Dropping it
  // makes `lines` agree with `wc -l`, which is the instrument a reader owns.
  const lines = src.split('\n').map((l) => l.replace(/\r$/, ''));
  if (lines[lines.length - 1] === '') lines.pop();

  for (const l of lines) {
    if (l.trim() === '') continue;
    const col = l.match(/^[ \t]*/)[0].length + 1;
    startCounts[col] = (startCounts[col] ?? 0) + 1;
    countedLines += 1;
  }

  // Divisions are indented in several files, so leading space is allowed; the
  // clause must still be the first thing on its line.
  const divisions = [...src.matchAll(/^[ \t]*([A-Z][A-Z-]*)[ \t]+DIVISION\./gim)].map((m) =>
    m[1].toUpperCase(),
  );

  /* The excerpt starts at the PROCEDURE DIVISION: opening a program should show
     executable statements, not the letterhead. Placeholder author lines are
     scaffolding, not COBOL, and are dropped. */
  const proc = lines.findIndex((l) => /^[ \t]*PROCEDURE[ \t]+DIVISION/i.test(l));
  const body = lines
    .slice(proc === -1 ? 0 : proc)
    .filter((l) => l.trim() !== '' && !/AUTHOR\.\s*Your Name\.?/i.test(l));

  const programId = /PROGRAM-ID\.\s*([A-Za-z0-9-]+)/i.exec(src)?.[1] ?? null;
  const paragraphs = [...src.matchAll(/^[A-Z][A-Z0-9-]*\.\s*$/gm)].length;
  const fileControls = [...src.matchAll(/^\s*SELECT\s+[A-Za-z0-9-]+\s+ASSIGN/gim)].length;
  const hasScreen = /SCREEN SECTION\./i.test(src);
  const maxColumns = lines.length ? Math.max(...lines.map((l) => l.length)) : 0;
  const past72 = lines.filter((l) => l.length > 72).length;
  const note = notes.get(file) ?? {};

  // A file with no divisions and no code is a stub, and gets its own row type
  // on the page rather than a row of zeroes.
  const stub = divisions.length === 0 || body.length === 0;

  programs.push({
    file,
    programId,
    // The empty file has no program-id; the page must say so, not guess.
    nameIsFilename: programId === null,
    bytes: Buffer.byteLength(src, 'utf8'),
    lines: lines.length,
    codeLines: body.length,
    divisions,
    paragraphs,
    fileControls,
    hasScreen,
    maxColumns,
    past72,
    stub,
    summary: note.summary ?? null,
    category: note.category ?? 'Other',
    teaches: note.teaches ?? null,
    excerpt: body.slice(0, 10),
    // The lines that run past the last code column, shown struck through on
    // the page where the 80-column rule is explained.
    longLines: lines.filter((l) => l.length > 72).slice(0, 3),
    url: `${REPO}/${file}`,
  });
}

const byCategory = {};
for (const p of programs) byCategory[p.category] = (byCategory[p.category] ?? 0) + 1;

const real = programs.filter((p) => !p.stub);
const totals = {
  programs: programs.length,
  stubs: programs.length - real.length,
  lines: programs.reduce((n, p) => n + p.lines, 0),
  codeLines: programs.reduce((n, p) => n + p.codeLines, 0),
  bytes: programs.reduce((n, p) => n + p.bytes, 0),
  filesPastColumn72: programs.filter((p) => p.past72 > 0).length,
  linesPastColumn72: programs.reduce((n, p) => n + p.past72, 0),
  withScreenSection: programs.filter((p) => p.hasScreen).length,
  shortest: Math.min(...real.map((p) => p.lines)),
  longest: Math.max(...real.map((p) => p.lines)),
  linesCounted: countedLines,
  startColumn1: startCounts[1] ?? 0,
  startColumn5: startCounts[5] ?? 0,
  startColumn8: startCounts[8] ?? 0,
  // Lines beginning anywhere in Area A, columns 8 to 11: not just column 8,
  // which is the strictest reading of the rule.
  areaA: [8, 9, 10, 11].reduce((n, c) => n + (startCounts[c] ?? 0), 0),
  startColumn12: startCounts[12] ?? 0,
  startColumns: Object.fromEntries(Object.entries(startCounts).sort((a, b) => a[0] - b[0])),
  categories: byCategory,
};

const out = `/* Generated by tools/index-programs.mjs - do not edit by hand.
   Regenerate after adding or changing any .cbl file: node tools/index-programs.mjs */\nwindow.PROGRAMS = ${JSON.stringify(programs, null, 2)};\nwindow.PROGRAM_TOTALS = ${JSON.stringify(totals, null, 2)};\n`;

await writeFile(join(root, 'programs.js'), out, 'utf8');
console.log(
  `${totals.programs} programs (${totals.stubs} stub), ${totals.lines} lines, ${totals.bytes} bytes; ` +
    `${totals.filesPastColumn72} files and ${totals.linesPastColumn72} lines past column 72; ` +
    `${totals.shortest}-${totals.longest} lines per program.`,
);
console.log(
  `start columns over ${totals.linesCounted} non-blank lines: ` +
    `${totals.startColumn5} at 5, ${totals.startColumn1} at 1, ` +
    `${totals.areaA} in Area A (8-11), ${totals.startColumn8} exactly at 8.`,
);
for (const p of programs) {
  if (!notes.has(p.file)) console.log(`  note missing: ${p.file}`);
}
