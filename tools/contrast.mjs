// Prints WCAG 2.x contrast ratios for every colour pair the site uses.
// Every contrast figure quoted in DESIGN-LOG.md is reproducible by running:
//   node tools/contrast.mjs
// Add a pair to PAIRS when you add a token; a pair that is not here cannot be
// claimed in the log.

const HEX = (h) => {
  const n = h.replace('#', '');
  return [0, 2, 4].map((i) => parseInt(n.slice(i, i + 2), 16) / 255);
};
const LIN = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const LUM = (h) => {
  const [r, g, b] = HEX(h).map(LIN);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const RATIO = (a, b) => {
  const [x, y] = [LUM(a), LUM(b)].sort((m, n) => n - m);
  return (x + 0.05) / (y + 0.05);
};

// [label, foreground, background, minimum required]
const PAIRS = [
  ['light: body ink on paper', '#1B1814', '#F0E9DC', 4.5],
  ['light: muted ink on paper', '#564F42', '#F0E9DC', 4.5],
  ['light: accent on paper', '#A8321A', '#F0E9DC', 4.5],
  ['light: ink on card raised', '#1B1814', '#F7F2E8', 4.5],
  ['light: ink on ignored zone', '#1B1814', '#DCD2C0', 4.5],
  ['light: code ink on code field', '#242019', '#E8E0CF', 4.5],
  ['light: code dim (past col 72)', '#6B6355', '#DCD2C0', 3.0],
  ['dark: body ink on paper', '#EDE6D6', '#14120E', 4.5],
  ['dark: muted ink on paper', '#A9A294', '#14120E', 4.5],
  ['dark: accent on paper', '#EE7A54', '#14120E', 4.5],
  ['dark: ink on card raised', '#EDE6D6', '#1D1A14', 4.5],
  ['dark: ink on ignored zone', '#EDE6D6', '#2C2820', 4.5],
  ['dark: code ink on code field', '#E6DECC', '#1A1712', 4.5],
  ['dark: code dim (past col 72)', '#8C8577', '#2C2820', 3.0],
  ['light: focus ring on paper', '#A8321A', '#F0E9DC', 3.0],
  ['dark: focus ring on paper', '#EE7A54', '#14120E', 3.0],
];

let fails = 0;
for (const [label, fg, bg, min] of PAIRS) {
  const r = RATIO(fg, bg);
  const ok = r >= min;
  if (!ok) fails += 1;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${r.toFixed(2)}:1  (min ${min})  ${label}  ${fg} on ${bg}`);
}
console.log(fails === 0 ? 'all pairs pass' : `${fails} pair(s) below threshold`);
