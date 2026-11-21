(function () {
  var root = document.documentElement;

  // ----- tema claro/escuro -----
  var btn = document.getElementById('theme-toggle');
  if (btn) btn.addEventListener('click', function () {
    var cur = root.dataset.theme ||
      (matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
    var next = cur === 'light' ? 'dark' : 'light';
    root.dataset.theme = next;
    try { localStorage.setItem('zokai-theme', next); } catch (e) {}
  });

  // ----- atalho "/" abre a busca -----
  document.addEventListener('keydown', function (e) {
    if (e.key === '/' && !/^(INPUT|TEXTAREA)$/.test(document.activeElement.tagName)) {
      e.preventDefault();
      var input = document.getElementById('search-input');
      if (input) input.focus(); else location.href = document.querySelector('[aria-label="Buscar"]').href;
    }
  });

  // ----- ordenação na lista de posts -----
  var list = document.getElementById('sortable');
  if (list) {
    var sorters = {
      'date-desc': function (a, b) { return b.dataset.date - a.dataset.date; },
      'date-asc':  function (a, b) { return a.dataset.date - b.dataset.date; },
      'views':     function (a, b) { return (b.dataset.views - a.dataset.views) || (b.dataset.date - a.dataset.date); },
      'title':     function (a, b) { return a.dataset.title.localeCompare(b.dataset.title, 'pt-BR'); }
    };
    document.querySelectorAll('[data-sort]').forEach(function (b) {
      b.addEventListener('click', function () {
        document.querySelectorAll('[data-sort]').forEach(function (x) { x.classList.toggle('is-active', x === b); });
        Array.prototype.slice.call(list.children).sort(sorters[b.dataset.sort])
          .forEach(function (el) { list.appendChild(el); });
      });
    });
  }

  // ----- post: TOC, progresso, copiar código/link -----
  var content = document.getElementById('post-content');
  if (content) {
    var heads = content.querySelectorAll('h2, h3');
    var toc = document.getElementById('toc'), ul = document.getElementById('toc-list');
    if (heads.length > 2 && toc) {
      heads.forEach(function (h) {
        var li = document.createElement('li'), a = document.createElement('a');
        a.href = '#' + h.id; a.textContent = h.textContent;
        if (h.tagName === 'H3') li.className = 'l3';
        li.appendChild(a); ul.appendChild(li);
      });
      toc.hidden = false;
      if ('IntersectionObserver' in window) {
        var io = new IntersectionObserver(function (es) {
          es.forEach(function (en) {
            if (en.isIntersecting) {
              ul.querySelectorAll('a').forEach(function (a) { a.classList.toggle('is-active', a.hash === '#' + en.target.id); });
            }
          });
        }, { rootMargin: '-80px 0px -70% 0px' });
        heads.forEach(function (h) { io.observe(h); });
      }
    }
    var bar = document.getElementById('progress');
    if (bar) addEventListener('scroll', function () {
      var h = document.documentElement;
      bar.style.width = Math.min(100, (h.scrollTop / (h.scrollHeight - h.clientHeight || 1)) * 100) + '%';
    }, { passive: true });

    content.querySelectorAll('pre').forEach(function (pre) {
      var b = document.createElement('button');
      b.type = 'button'; b.className = 'copy-code'; b.textContent = 'copiar';
      b.addEventListener('click', function () {
        navigator.clipboard.writeText(pre.innerText.replace(/copiar$/, '').trim()).then(function () {
          b.textContent = 'copiado!'; setTimeout(function () { b.textContent = 'copiar'; }, 1500);
        });
      });
      pre.appendChild(b);
    });
  }
  var copy = document.getElementById('copy-link');
  if (copy) copy.addEventListener('click', function () {
    navigator.clipboard.writeText(location.href).then(function () {
      copy.textContent = 'link copiado!'; setTimeout(function () { copy.textContent = 'Copiar link'; }, 1500);
    });
  });
})();
