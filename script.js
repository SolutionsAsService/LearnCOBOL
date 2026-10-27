/* LearnCOBOL — SolutionsAsService
   Vanilla, no dependencies. The page works without this file except for the
   catalogue, which degrades to the notice in <noscript>. */

(function () {
  'use strict';

  var programs = window.PROGRAMS || [];
  var totals = window.PROGRAM_TOTALS || {};

  /* ------------------------------------------------------------- helpers */

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    if (attrs) {
      Object.keys(attrs).forEach(function (k) {
        if (k === 'text') node.textContent = attrs[k];
        else if (k === 'class') node.className = attrs[k];
        else node.setAttribute(k, attrs[k]);
      });
    }
    (children || []).forEach(function (c) { node.appendChild(c); });
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

  /* --------------------------------------------------------------- stats */

  /* The headline figures are printed in the HTML so they survive without
     JavaScript; this reconciles them against the generated data, so a stale
     number in the markup cannot outlive a change to the sources. */
  function reconcile() {
    var shown = {
      programs: num(totals.programs),
      lines: num(totals.lines),
      bytes: num(totals.bytes),
      filesPastColumn72: totals.filesPastColumn72 + ' of ' + totals.programs,
      linesPastColumn72: num(totals.linesPastColumn72),
      range: totals.shortest + '–' + totals.longest,
      linesCounted: num(totals.linesCounted),
      startColumn1: num(totals.startColumn1),
      startColumn5: num(totals.startColumn5),
      startColumn8: num(totals.startColumn8),
      areaA: num(totals.areaA),
    };
    Object.keys(shown).forEach(function (key) {
      var nodes = document.querySelectorAll('[data-stat="' + key + '"]');
      Array.prototype.forEach.call(nodes, function (node) {
        if (node.textContent.trim() !== shown[key]) node.textContent = shown[key];
      });
    });
  }

  /* ------------------------------------------------- column 72 multiple */

  function renderMultiple() {
    var host = document.getElementById('multiple');
    if (!host) return;
    host.textContent = '';
    programs.forEach(function (p) {
      host.appendChild(el('li', { 'data-past': p.past72 > 0 ? 'true' : 'false' }));
    });
  }

  /* ------------------------------------------------------------- sample */

  function renderSample() {
    var host = document.getElementById('sample');
    if (!host) return;
    var pick = programs.filter(function (p) { return p.file === 'PayrollProcessing.cbl'; })[0]
      || programs[0];
    if (!pick) return;
    renderCode(host, pick.excerpt);
  }

  /* The break, shown where the rule is taught: a real line, with everything
     past column 72 struck through. */
  function renderOverflow() {
    var host = document.getElementById('overflow-sample');
    if (!host) return;
    var pick = programs
      .filter(function (p) { return p.longLines && p.longLines.length > 0; })
      .sort(function (a, b) { return b.past72 - a.past72 || a.file.localeCompare(b.file); })[0];
    if (!pick) return;
    renderCode(host, pick.longLines);
    var name = document.getElementById('overflow-name');
    if (name) name.textContent = pick.file;
  }

  /* ----------------------------------------------------------- catalogue */

  var state = { q: '', category: 'All' };

  function matches(p) {
    if (state.category !== 'All' && p.category !== state.category) return false;
    if (!state.q) return true;
    var haystack = [p.file, p.programId, p.summary, p.category, p.teaches, p.divisions.join(' ')]
      .join(' ').toLowerCase();
    return haystack.indexOf(state.q.toLowerCase()) !== -1;
  }

  function programNode(p) {
    var id = p.programId || '(no PROGRAM-ID)';
    // A stub gets its own row type rather than a row of zeroes.
    var figures = p.stub
      ? ['empty stub', num(p.bytes) + ' bytes', p.category]
      : [
          p.lines + ' lines',
          num(p.bytes) + ' bytes',
          p.divisions.length + ' divisions',
          p.paragraphs + ' paragraphs',
          p.fileControls + ' FD/SELECT',
          p.category,
        ];

    var button = el('button', {
      class: 'program__id',
      type: 'button',
      'aria-expanded': 'false',
      text: id,
    });

    /* Same labelled shell as the static code blocks: a scroll region the
       keyboard cannot reach is out of reach. */
    var detail = el('div', { class: 'program__detail' }, [
      el('pre', {
        class: 'mono',
        tabindex: '0',
        role: 'group',
        'aria-label': p.file + ' — first lines',
      }),
      el('p', {}, [
        el('a', { href: p.url, text: p.file }),
        document.createTextNode(' — full source on GitHub.'),
      ]),
    ]);
    detail.hidden = true;
    var pre = detail.querySelector('pre');
    if (p.excerpt.length) {
      var code = el('code', {});
      renderCode(code, p.excerpt);
      pre.appendChild(code);
    } else {
      pre.appendChild(document.createTextNode('(this file is empty — there is nothing to show)'));
    }

    button.addEventListener('click', function () {
      var open = button.getAttribute('aria-expanded') === 'true';
      button.setAttribute('aria-expanded', open ? 'false' : 'true');
      detail.hidden = open;
    });

    var children = [
      el('div', { class: 'program__row' }, [
        button,
        el('div', { class: 'program__figures' }, figures.map(function (f) {
          return el('span', { text: f });
        })),
      ]),
    ];

    if (p.summary) children.push(el('p', { class: 'program__summary', text: p.summary + '.' }));
    if (p.teaches && p.teaches !== 'none') {
      children.push(el('p', { class: 'program__teaches', text: 'Teaches: ' + p.teaches }));
    }
    children.push(detail);

    return el('li', { class: 'program' }, children);
  }

  function renderList() {
    var host = document.getElementById('list');
    var count = document.getElementById('count');
    if (!host) return;
    var shown = programs.filter(matches);
    host.textContent = '';
    shown.forEach(function (p) { host.appendChild(programNode(p)); });
    if (count) count.textContent = 'Showing ' + shown.length + ' of ' + programs.length;
  }

  function renderCategories() {
    var host = document.getElementById('categories');
    if (!host || !totals.categories) return;
    var names = ['All'].concat(Object.keys(totals.categories).sort(function (a, b) {
      return totals.categories[b] - totals.categories[a] || a.localeCompare(b);
    }));

    host.textContent = '';
    names.forEach(function (name) {
      var label = name === 'All'
        ? 'All ' + totals.programs
        : name + ' ' + totals.categories[name];
      var chip = el('button', {
        type: 'button',
        'aria-pressed': state.category === name ? 'true' : 'false',
        text: label,
      });
      chip.addEventListener('click', function () {
        state.category = name;
        Array.prototype.forEach.call(host.querySelectorAll('button'), function (b) {
          b.setAttribute('aria-pressed', b === chip ? 'true' : 'false');
        });
        renderList();
      });
      host.appendChild(chip);
    });
  }

  /* --------------------------------------------------------------- theme */

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
    function paint() {
      var theme = currentTheme();
      button.textContent = theme === 'dark' ? 'Dark mode' : 'Light mode';
      button.setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
    }

    button.addEventListener('click', function () {
      var next = currentTheme() === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) { /* private mode */ }
      paint();
    });

    paint();
  }

  /* ----------------------------------------------------------------- go */

  function init() {
    reconcile();
    renderMultiple();
    renderOverflow();
    renderSample();
    renderCategories();
    renderList();
    initTheme();

    var q = document.getElementById('q');
    if (q) {
      q.addEventListener('input', function () {
        state.q = q.value.trim();
        renderList();
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
