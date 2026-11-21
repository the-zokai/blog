// Busca client-side sem dependências: pontua título, categorias, tags, descrição e texto.
(function () {
  var input = document.getElementById('search-input');
  var out = document.getElementById('search-results');
  var status = document.getElementById('search-status');
  var docs = [];

  function norm(s) { return (s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, ''); }
  function esc(s) { return s.replace(/[&<>"']/g, function (c) { return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }

  function score(d, terms) {
    var total = 0;
    for (var i = 0; i < terms.length; i++) {
      var t = terms[i], s = 0;
      if (d._title.indexOf(t) > -1) s += 10;
      if (d._cats.indexOf(t) > -1) s += 6;
      if (d._desc.indexOf(t) > -1) s += 4;
      if (d._body.indexOf(t) > -1) s += 1;
      if (!s) return 0;           // todos os termos precisam casar
      total += s;
    }
    return total;
  }

  function snippet(d, terms) {
    var body = d.content || d.description, nb = norm(body), pos = -1;
    for (var i = 0; i < terms.length && pos < 0; i++) pos = nb.indexOf(terms[i]);
    var start = Math.max(0, pos - 60), txt = body.substr(start, 180);
    txt = esc(txt);
    terms.forEach(function (t) {
      if (t.length > 1) txt = txt.replace(new RegExp('(' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'ig'), '<mark>$1</mark>');
    });
    return (start > 0 ? '…' : '') + txt + '…';
  }

  function render(q) {
    var terms = norm(q).split(/\s+/).filter(Boolean);
    if (!terms.length) { out.innerHTML = ''; status.textContent = docs.length + ' posts indexados.'; return; }
    var res = docs.map(function (d) { return { d: d, s: score(d, terms) }; })
      .filter(function (r) { return r.s > 0; })
      .sort(function (a, b) { return b.s - a.s; });
    status.textContent = res.length + (res.length === 1 ? ' resultado' : ' resultados') + ' para “' + q + '”';
    out.innerHTML = res.map(function (r) {
      var d = r.d;
      return '<article class="card"><div class="card-meta"><time>' + esc(d.date) + '</time></div>' +
        '<h3 class="card-title"><a href="' + esc(d.url) + '">' + esc(d.title) + '</a></h3>' +
        '<p class="card-excerpt">' + snippet(d, terms) + '</p>' +
        '<div class="chips">' + d.categories.map(function (c) { return '<span class="chip">' + esc(c) + '</span>'; }).join('') + '</div></article>';
    }).join('');
  }

  fetch(window.ZOKAI_SEARCH_URL).then(function (r) { return r.json(); }).then(function (data) {
    docs = data.map(function (d) {
      d._title = norm(d.title);
      d._cats = norm(d.categories.concat(d.tags).join(' '));
      d._desc = norm(d.description);
      d._body = norm(d.content);
      return d;
    });
    var q = new URLSearchParams(location.search).get('q') || '';
    input.value = q;
    render(q);
  }).catch(function () { status.textContent = 'Não consegui carregar o índice de busca.'; });

  input.addEventListener('input', function () {
    render(input.value);
    history.replaceState(null, '', input.value ? '?q=' + encodeURIComponent(input.value) : location.pathname);
  });
})();
