/* LearnCOBOL — SolutionsAsService
   Vanilla, no dependencies, no build step. An application shell: the sidebar
   holds every program in the corpus, and one view is routed into <main>.

   Every figure printed here comes from programs.js, which is generated from the
   .cbl sources by `node tools/index-programs.mjs`. Nothing is hand-typed twice:
   where the markup used to carry a number, that number is now recomputed. */

(function () {
  'use strict';

  var programs = window.PROGRAMS || [];
  var totals = window.PROGRAM_TOTALS || {};
  var view = document.getElementById('view');

  /* ------------------------------------------------------------- helpers */

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    if (attrs) {
      Object.keys(attrs).forEach(function (k) {
        if (k === 'text') node.textContent = attrs[k];
        else if (k === 'html') node.innerHTML = attrs[k];
        else if (k === 'class') node.className = attrs[k];
        else node.setAttribute(k, attrs[k]);
      });
    }
    (children || []).forEach(function (c) {
      if (c) node.appendChild(c);
    });
    return node;
  }

  var num = function (n) { return Number(n).toLocaleString('en-US'); };

  /* A line past column 72: the part the compiler reads, then the part it does
     not, struck through. This is the whole point of the fixed format, so it is
     shown rather than described. */
  function codeLine(text) {
    var frag = document.createDocumentFragment();
    if (text.length > 72) {
      frag.appendChild(document.createTextNode(text.slice(0, 72)));
      frag.appendChild(el('span', { class: 'past72', text: text.slice(72) }));
    } else {
      frag.appendChild(document.createTextNode(text));
    }
    return frag;
  }

  function renderCode(target, lines) {
    target.textContent = '';
    lines.forEach(function (line, i) {
      if (i > 0) target.appendChild(document.createTextNode('\n'));
      target.appendChild(codeLine(line));
    });
  }

  /* The 80-column scale. A real instrument, not a texture: it teaches the fixed
     format and lays out the code beneath it. */
  function ruler() {
    var ticks = [1, 8, 12, 24, 36, 48, 60, 72];
    var wrap = el('div', { class: 'field' });
    var r = el('div', {
      class: 'ruler',
      role: 'img',
      'aria-label': 'Punch-card column scale, 1 to 80. Columns 1 to 6 sequence, 7 indicator, 8 to 11 Area A, 12 to 72 Area B, 73 to 80 ignored by the compiler.',
    }, [
      el('div', { class: 'ruler__ticks' }),
      el('div', { class: 'ruler__zone ruler__zone--a' }),
      el('div', { class: 'ruler__zone ruler__zone--x' }),
    ]);
    ticks.forEach(function (c) {
      r.appendChild(el('span', { class: 'ruler__num', style: '--c: ' + c, text: String(c) }));
    });
    r.appendChild(el('span', { class: 'ruler__num ruler__num--end', style: '--c: 81', text: '80' }));
    wrap.appendChild(r);
    return wrap;
  }

  function codeBlock(lines, label) {
    var code = el('code', {});
    renderCode(code, lines);
    return el('div', { class: 'code' }, [
      el('div', { class: 'code__inner' }, [
        el('pre', { tabindex: '0', role: 'group', 'aria-label': label }, [code]),
      ]),
    ]);
  }

  function find(file) {
    for (var i = 0; i < programs.length; i++) {
      if (programs[i].file === file) return programs[i];
    }
    return null;
  }

  /* --------------------------------------------------------------- sidebar */

  var state = { q: '' };

  function matches(p) {
    if (!state.q) return true;
    var hay = [p.file, p.programId, p.summary, p.category, p.teaches,
      (p.paragraphNames || []).join(' ')].join(' ').toLowerCase();
    return hay.indexOf(state.q) !== -1;
  }

  function renderSidebar() {
    var host = document.getElementById('groups');
    if (!host) return;
    host.textContent = '';

    var names = Object.keys(totals.categories || {}).sort(function (a, b) {
      return totals.categories[b] - totals.categories[a] || a.localeCompare(b);
    });

    names.forEach(function (name) {
      var inGroup = programs.filter(function (p) {
        return p.category === name && matches(p);
      });
      if (!inGroup.length) return;

      var list = el('ul', { class: 'group__list' });
      inGroup.forEach(function (p) {
        list.appendChild(el('li', {}, [
          el('a', { href: '#/p/' + encodeURIComponent(p.file), 'data-file': p.file, text: p.programId || p.file }),
        ]));
      });

      host.appendChild(el('div', { class: 'group' }, [
        el('div', { class: 'group__name' }, [
          el('span', { text: name }),
          el('span', { text: String(inGroup.length) }),
        ]),
        list,
      ]));
    });

    if (!host.children.length) {
      host.appendChild(el('p', { class: 'empty', text: 'No program matches that filter.' }));
    }
    markCurrent();
  }

  function markCurrent() {
    var file = currentFile();
    var links = document.querySelectorAll('.group__list a');
    Array.prototype.forEach.call(links, function (a) {
      if (file && a.getAttribute('data-file') === file) a.setAttribute('aria-current', 'page');
      else a.removeAttribute('aria-current');
    });
    var nav = document.querySelectorAll('.sidebar__nav a');
    var routeName = currentRoute().name;
    Array.prototype.forEach.call(nav, function (a) {
      if (!file && a.getAttribute('data-nav') === routeName) a.setAttribute('aria-current', 'page');
      else a.removeAttribute('aria-current');
    });
  }

  /* -------------------------------------------------------------- routing */

  function currentRoute() {
    var hash = window.location.hash || '#/';
    var m = /^#\/p\/(.+)$/.exec(hash);
    if (m) return { name: 'program', file: decodeURIComponent(m[1]) };
    if (hash === '#/card') return { name: 'card', file: null };
    if (hash === '#/divisions') return { name: 'divisions', file: null };
    if (hash === '#/run') return { name: 'run', file: null };
    return { name: 'overview', file: null };
  }

  function currentFile() {
    return currentRoute().file;
  }

  /* ------------------------------------------------------------- overview */

  function statList(items) {
    var dl = el('dl', { class: 'stats' });
    items.forEach(function (it) {
      dl.appendChild(el('div', {}, [
        el('dt', { text: it[0] }),
        el('dd', { text: it[1] }),
      ]));
    });
    return dl;
  }

  function overview() {
    var frag = document.createDocumentFragment();

    frag.appendChild(el('p', { class: 'view__eyebrow', text: 'A reading room, not a terminal' }));
    frag.appendChild(el('h1', { text: 'Learn COBOL by reading COBOL' }));
    frag.appendChild(el('p', {
      class: 'lede',
      text: 'Every program here is a real file in this repository. The counts, the sizes and ' +
            'the lines shown are measured from the source and regenerated whenever a file changes.',
    }));

    frag.appendChild(statList([
      ['Programs', num(totals.programs)],
      ['Lines', num(totals.lines)],
      ['Bytes', num(totals.bytes)],
      ['Past column 72', totals.filesPastColumn72 + ' of ' + totals.programs + ' files'],
    ]));
    frag.appendChild(el('p', {
      class: 'caption',
      text: 'Produced by node tools/index-programs.mjs from the .cbl files, so a stale number ' +
            'cannot survive on the page.',
    }));

    /* 01 What this is */
    frag.appendChild(el('h2', { class: 'section-heading', id: 'what', text: '01 — What this is' }));
    frag.appendChild(el('p', {
      html: 'COBOL — Common Business-Oriented Language — was designed by the ' +
            '<a href="https://en.wikipedia.org/wiki/COBOL">CODASYL committee</a> and first ' +
            'specified in 1960; the current standard is ISO/IEC 1989. It was written to read ' +
            'like English business prose rather than like mathematics.',
    }));
    frag.appendChild(el('p', {
      text: 'The programs here are small and self-contained: payroll, loans, inventory, tax, ' +
            'stock valuation, aquaculture, crop rotation. They run from ' + totals.shortest + '–' +
            totals.longest + ' lines each and do one job apiece — the kind of work the ' +
            'language was written for.',
    }));

    /* 02 The card */
    frag.appendChild(el('h2', { class: 'section-heading', id: 'card', text: '02 — The 80-column card' }));
    frag.appendChild(el('p', {
      class: 'caption',
      text: 'COBOL’s fixed source format is a punch card turned into a rule. The column a ' +
            'character sits in decides whether the compiler reads it at all.',
    }));
    frag.appendChild(ruler());

    var zoneList = el('ul', { class: 'divisions' });
    [
      ['1–6 Sequence', 'Optional line numbers. The compiler ignores them; they existed so a dropped deck of cards could be sorted back into order.'],
      ['7 Indicator', '* in this column makes the whole line a comment. - continues a literal from the line above.'],
      ['8–11 Area A', 'Division, section and paragraph headers, and 01-level records, must begin here.'],
      ['12–72 Area B', 'Everything else — statements, clauses, subordinate data items. This is where the program lives.'],
    ].forEach(function (z) {
      zoneList.appendChild(el('li', {}, [
        el('h3', { text: z[0] }),
        el('p', { text: z[1] }),
      ]));
    });
    frag.appendChild(zoneList);

    frag.appendChild(el('p', {
      text: 'Columns 73 to 80 are not code. In fixed format the compiler never reads them, ' +
            'which is why a line can look complete and still be truncated. In this repository ' +
            totals.filesPastColumn72 + ' of ' + totals.programs + ' files contain ' +
            num(totals.linesPastColumn72) + ' such lines; wherever one appears on this site, ' +
            'its tail is struck through.',
    }));
    frag.appendChild(el('p', {
      text: 'The instrument is 1960; these files are not. Across the ' +
            num(totals.linesCounted) + ' non-blank lines in the corpus, ' +
            num(totals.startColumn5) + ' begin at column 5, ' + num(totals.startColumn1) +
            ' at column 1, and only ' + num(totals.areaA) + ' begin anywhere in Area A ' +
            '(columns 8–11) — just ' + num(totals.startColumn8) + ' of them exactly at ' +
            'column 8, where division headers are supposed to start. This code is indented ' +
            'the way modern code is indented, and GnuCOBOL compiles it either way.',
    }));

    var overflow = programs
      .filter(function (p) { return p.longLines && p.longLines.length; })
      .sort(function (a, b) { return b.past72 - a.past72 || a.file.localeCompare(b.file); })[0];
    if (overflow) {
      frag.appendChild(el('p', {
        class: 'caption',
        text: 'A real line from ' + overflow.file + ', with the tail the compiler never reads struck through.',
      }));
      frag.appendChild(codeBlock(overflow.longLines, overflow.file + ' — lines past column 72'));
    }

    /* 03 The four divisions */
    frag.appendChild(el('h2', { class: 'section-heading', id: 'divisions', text: '03 — The four divisions' }));
    frag.appendChild(el('p', {
      class: 'caption',
      text: 'Every COBOL program is these four, in this order. Nothing else is allowed at the top level.',
    }));

    var divList = el('ul', { class: 'divisions' });
    [
      ['Identification', 'Names the program. PROGRAM-ID is the only clause that is always required.'],
      ['Environment', 'Declares the machine: which files map to which external names, via SELECT … ASSIGN.'],
      ['Data', 'Declares every field before it is used, with a picture: PIC 9(5)V99 is five digits, an implied decimal point, two more digits.'],
      ['Procedure', 'The executable part: named paragraphs, performed in sequence or in loops. No anonymous blocks, no nesting by indentation alone.'],
    ].forEach(function (d) {
      divList.appendChild(el('li', {}, [el('h3', { text: d[0] }), el('p', { text: d[1] })]));
    });
    frag.appendChild(divList);

    var sample = find('PayrollProcessing.cbl') || programs[0];
    if (sample) {
      frag.appendChild(el('p', {
        class: 'caption',
        text: sample.file + ', from the PROCEDURE DIVISION. The band at the left is Area A; ' +
              'the band at the right is the part of the line the compiler discards.',
      }));
      frag.appendChild(codeBlock(sample.excerpt, sample.file + ' — PROCEDURE DIVISION'));
    }

    /* 04 All the programs */
    frag.appendChild(el('h2', { class: 'section-heading', id: 'programs', text: '04 — All ' + totals.programs + ' programs' }));
    frag.appendChild(el('p', {
      class: 'caption',
      text: 'Every file in the corpus. Open one to read the whole source with what it does and ' +
            'how it works; follow the filename for the raw file.',
    }));
    frag.appendChild(cardGrid(programs.filter(matches)));

    /* 05 Run one */
    frag.appendChild(el('h2', { class: 'section-heading', id: 'run', text: '05 — Run one' }));
    frag.appendChild(el('p', {
      class: 'caption',
      html: 'These are fixed-format sources, so <a href="https://gnucobol.sourceforge.io/">GnuCOBOL</a> compiles them as they stand.',
    }));
    frag.appendChild(codeBlock([
      '# compile to a standalone executable',
      'cobc -x PayrollProcessing.cbl',
      './PayrollProcessing',
      '',
      '# or build a module and run it through cobcrun',
      'cobc -m PayrollProcessing.cbl',
      'cobcrun PayrollProcessing',
      '',
      '# free-format sources, if you write your own',
      'cobc -x -free MyProgram.cbl',
    ], 'GnuCOBOL commands'));
    frag.appendChild(el('p', {
      text: 'cobc is the GnuCOBOL compiler. -x produces an executable, -m a loadable module, ' +
            'and -free switches off the 80-column rules described above — which is the fastest ' +
            'way to see what the card was doing for you.',
    }));

    return frag;
  }

  function cardGrid(list) {
    var ul = el('ul', { class: 'cards' });
    if (!list.length) {
      return el('p', { class: 'empty', text: 'No program matches that filter.' });
    }
    list.forEach(function (p) {
      var figures = p.stub
        ? ['empty stub', num(p.bytes) + ' bytes', p.category]
        : [p.lines + ' lines', num(p.bytes) + ' bytes', p.paragraphs + ' paragraphs',
           p.fileControls + ' FD/SELECT', p.category];
      var a = el('a', { href: '#/p/' + encodeURIComponent(p.file) }, [
        el('h3', { text: p.programId || p.file }),
        el('p', { text: p.summary ? p.summary + '.' : '' }),
        el('div', { class: 'figures' }, figures.map(function (f) {
          return el('span', { text: f });
        })),
      ]);
      ul.appendChild(el('li', {}, [a]));
    });
    return ul;
  }

  /* -------------------------------------------------------- program view */

  function programView(p) {
    var frag = document.createDocumentFragment();
    var id = p.programId || '(no PROGRAM-ID)';

    frag.appendChild(el('p', {
      class: 'view__eyebrow',
      html: '<a href="#/">All programs</a> · ' + p.category,
    }));
    frag.appendChild(el('h1', { text: id }));

    frag.appendChild(statList(p.stub
      ? [['Status', 'empty stub'], ['Bytes', num(p.bytes)], ['Category', p.category]]
      : [
          ['Lines', String(p.lines)],
          ['Bytes', num(p.bytes)],
          ['Divisions', String(p.divisions.length)],
          ['Paragraphs', String(p.paragraphs)],
          ['FD/SELECT', String(p.fileControls)],
          ['Past column 72', String(p.past72)],
        ]));

    /* How it works: the curated reading of the program, beside the measured
       facts that support it. Both come from the same generated record. */
    frag.appendChild(el('h2', { class: 'section-heading', text: 'How it works' }));

    var works = el('div', { class: 'works' });

    works.appendChild(el('section', {}, [
      el('h3', { text: 'What it does' }),
      el('p', { text: p.summary ? p.summary + '.' : 'No summary recorded.' }),
      el('p', { text: 'Teaches: ' + (p.teaches || 'none') }),
    ]));

    var verbList = el('ul', { class: 'chips' });
    var verbs = Object.keys(p.verbs || {}).sort(function (a, b) {
      return (p.verbs[b] - p.verbs[a]) || a.localeCompare(b);
    });
    if (verbs.length) {
      verbs.slice(0, 14).forEach(function (v) {
        verbList.appendChild(el('li', {
          html: '<b>' + v + '</b> ×' + p.verbs[v],
        }));
      });
    } else {
      verbList.appendChild(el('li', { text: 'no statements matched' }));
    }

    works.appendChild(el('section', {}, [
      el('h3', { text: 'Verbs it uses' }),
      el('p', { text: 'Statements beginning with each verb, counted from the source.' }),
      verbList,
    ]));

    var paraList = el('ul', { class: 'paragraphs' });
    if ((p.paragraphNames || []).length) {
      p.paragraphNames.forEach(function (n) {
        paraList.appendChild(el('li', { text: n }));
      });
    } else {
      paraList.appendChild(el('li', { text: 'none' }));
    }

    works.appendChild(el('section', {}, [
      el('h3', { text: 'Its paragraphs' }),
      el('p', { text: 'Named paragraphs, in the order they appear — the units a PERFORM addresses.' }),
      paraList,
    ]));

    var divList = el('ul', { class: 'chips' });
    (p.divisions || []).forEach(function (d) {
      divList.appendChild(el('li', { text: d }));
    });
    if (!p.divisions.length) divList.appendChild(el('li', { text: 'none' }));

    works.appendChild(el('section', {}, [
      el('h3', { text: 'Its divisions' }),
      el('p', { text: 'Present in this file, in source order.' }),
      divList,
    ]));

    frag.appendChild(works);

    /* The source, whole. */
    frag.appendChild(el('h2', { class: 'section-heading', text: 'The source' }));
    frag.appendChild(ruler());

    if (p.source && p.source.length) {
      frag.appendChild(codeBlock(p.source, p.file + ' — full source'));
    } else {
      frag.appendChild(el('p', { class: 'empty', text: 'This file is empty — there is nothing to show.' }));
    }

    frag.appendChild(el('p', {
      class: 'caption',
      html: '<a href="' + p.url + '">' + p.path + '</a> — the raw file in this repository.',
    }));

    /* Pager: the corpus in order. */
    var i = programs.indexOf(p);
    var prev = programs[i - 1];
    var next = programs[i + 1];
    var pager = el('div', { class: 'pager' });
    if (prev) {
      pager.appendChild(el('a', { href: '#/p/' + encodeURIComponent(prev.file), text: '← ' + (prev.programId || prev.file) }));
    }
    if (next) {
      pager.appendChild(el('a', { href: '#/p/' + encodeURIComponent(next.file), text: (next.programId || next.file) + ' →' }));
    }
    if (pager.children.length) frag.appendChild(pager);

    return frag;
  }

  /* ---------------------------------------------------------------- paint */

  function paint() {
    var route = currentRoute();
    view.textContent = '';

    if (route.name === 'program') {
      var p = find(route.file);
      if (p) {
        view.appendChild(programView(p));
        document.title = (p.programId || p.file) + ' — LearnCOBOL';
      } else {
        view.appendChild(el('p', { class: 'empty', text: 'No such program: ' + route.file }));
      }
    } else {
      view.appendChild(overview());
      document.title = 'LearnCOBOL — 32 COBOL programs, read line by line';
      if (route.name !== 'overview') {
        var target = document.getElementById(route.name);
        if (target) target.scrollIntoView();
      }
    }

    markCurrent();
  }

  /* ----------------------------------------------------------------- theme */

  function currentTheme() {
    var set = document.documentElement.getAttribute('data-theme');
    if (set === 'light' || set === 'dark') return set;
    var dark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    return dark ? 'dark' : 'light';
  }

  function initTheme() {
    var button = document.getElementById('theme-toggle');
    if (!button) return;

    /* The visible text is the accessible name: no aria-label is set, so a
       speech user can say what they see. aria-pressed then reads as state. */
    function paintButton() {
      var theme = currentTheme();
      button.textContent = theme === 'dark' ? 'Dark mode' : 'Light mode';
      button.setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
    }

    button.addEventListener('click', function () {
      var next = currentTheme() === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) { /* private mode */ }
      paintButton();
    });

    paintButton();
  }

  /* ------------------------------------------------------------------- go */

  function init() {
    renderSidebar();
    initTheme();
    paint();

    window.addEventListener('hashchange', paint);

    var q = document.getElementById('search');
    if (q) {
      q.addEventListener('input', function () {
        state.q = q.value.trim();
        renderSidebar();
        if (currentRoute().name !== 'program') paint();
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
