# LearnCOBOL

Thirty-two COBOL sample programs, and a site that reads all of them.

The programs are small and self-contained — payroll, loans, inventory, tax, stock
valuation, aquaculture, crop rotation. Each does one job, in the kind of business
processing the language was written for. The site puts every one of them on the
page with its real source and a measured account of how it works.

## Repository structure

```
programs/            the 32 .cbl sources
tools/
  index-programs.mjs  regenerates programs.js from the sources
  program-notes.json  authored one-line summary, category and teaching point
  contrast.mjs        re-measures every colour pair against WCAG
docs/
  DESIGN-LOG.md       design decisions, critique rounds and measurements
  CARRY-FORWARD.md    facts a later run should not have to rediscover
index.html            the site: app shell, no build step
styles.css
script.js
programs.js           generated — do not edit by hand
```

## Site

A static application shell: a sidebar holding every program in the corpus, and one
routed view. Open a program to read its whole source laid out on the 80-column
card, with what it does, the paragraphs it is built from, the verbs it uses and
the divisions it declares. Anything past column 72 is struck through, because in
fixed format the compiler never reads it.

Open `index.html` directly, or read it at
https://solutionsasservice.github.io/LearnCOBOL/

Every figure on the site — program count, line count, byte count, how many files
run past column 72 — is measured from the sources, not typed into the markup.

## Regenerating the catalogue

After adding or changing any `.cbl` file:

```bash
node tools/index-programs.mjs   # rewrites programs.js from the sources
node tools/contrast.mjs         # re-measures every colour pair against WCAG
```

## Running a program

These are fixed-format sources, so [GnuCOBOL](https://gnucobol.sourceforge.io/)
compiles them as they stand:

```bash
cobc -x programs/PayrollProcessing.cbl
./PayrollProcessing

# or build a module and run it through cobcrun
cobc -m programs/PayrollProcessing.cbl
cobcrun PayrollProcessing

# -free switches off the 80-column rules, if you write your own
cobc -x -free MyProgram.cbl
```

Installing GnuCOBOL: the installer from its [official
page](https://gnucobol.sourceforge.io/) on Windows; `sudo apt-get install
gnucobol` on Debian or Ubuntu; `brew install gnucobol` on macOS.

## Learning resources

- [GnuCOBOL Programmer's Guide](https://gnucobol.sourceforge.io/)
- [The Open Mainframe Project COBOL training course](https://www.openmainframeproject.org/projects/coboltrainingcourse)

## Contributing

Contributions are welcome — add a program to `programs/`, add its note to
`tools/program-notes.json`, and regenerate with `node tools/index-programs.mjs`.

## License

MIT — see [LICENSE](LICENSE).
