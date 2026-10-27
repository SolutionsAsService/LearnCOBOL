# CARRY-FORWARD — durable facts measured during this run

Read this before Step 1 of any later run on this project. These are facts about
the medium, established by measurement, that a later run would otherwise
rediscover the hard way. Amendments to the *process* live in DESIGN-LOG.md;
facts about the *medium* live here.

| Fact | Measurement that established it | Move it changed |
|---|---|---|
| `ch` in a custom property resolves against the font of the element that **spends** it, not the one that declares it. `:root { --code-col: 80ch }` gave 600px inside a 0.8rem monospace block and 750px on a 1rem ruler. | headless Chrome, `getBoundingClientRect`: ruler 750px vs code 600px, delta 150px | M4 — `.field` now sets the code's font-size, so ruler and code agree at 600px |
| A percentage column (`--col: calc(100% / 80)`) is only true in the box it was declared for. Percentages made the column-72 band land ~224px right of character 72. | same run: band at 540px vs glyph-72 probe at 540px after the fix, delta 0px (was 224px) | M4 — `--col` became `calc(var(--code-col) / 80)`, an absolute 1ch |
| `ch` counts the "0" advance, which is wider than the average character in a proportional face. Bringhurst's 66ch set 70–73 real characters here. | 517.5px column / 7.76px average character = 66.7 at 60ch | M2 — `--measure` calibrated from 66ch to 60ch |
| A declaration on `body` never overrides a rule on `p`, whatever the specificity: inherited values lose to any directly matching rule. This is why the old light mode sat at 2.17:1. | computed contrast `#B0B0B0` on `#FFFFFF` = 2.17:1 while `body.light-mode` set black | M1 — every role bound to a token, 16/16 pairs measured |
| A file ending in a newline splits into a trailing empty string, so `split('\n')` counts one phantom line per file. | 32 files: script said 1,996, `wc -l` said 1,964 | M3 — trailing empty line dropped; per-program rows corrected by one |
| jsdom has no `window.matchMedia`. An unguarded call in init throws, and every listener attached after it is never bound — the filter looked broken when the theme toggle was the actual fault. | render harness: 2 `TypeError: window.matchMedia is not a function`, filter returned 32 of 32 for "payroll" | M1 — guarded with `window.matchMedia &&` |
| `repeating-linear-gradient` percentage stops resolve against the element's own box, so a tick pattern written in percentages silently rescales with the box. Absolute lengths do not. | the ruler's ticks before the fix | M4 |
