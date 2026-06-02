/* ЭВЕРЕСТ ИНЖИНИРИНГ — общий скрипт всех страниц */
(function () {
  'use strict';

  /* ---- sticky header shadow ---- */
  var header = document.querySelector('.site-header');
  function onScroll() {
    if (!header) return;
    header.classList.toggle('scrolled', window.scrollY > 12);
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---- mobile menu ---- */
  var burger = document.querySelector('.burger');
  var menu = document.querySelector('.mobile-menu');
  if (burger && menu) {
    burger.addEventListener('click', function () {
      var open = burger.classList.toggle('open');
      menu.classList.toggle('open', open);
      document.body.style.overflow = open ? 'hidden' : '';
    });
    menu.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () {
        burger.classList.remove('open');
        menu.classList.remove('open');
        document.body.style.overflow = '';
      });
    });
  }

  /* ---- scroll reveal (scroll-position based; robust in all envs) ---- */
  var revealEls = [].slice.call(document.querySelectorAll('.reveal'));
  var counters = [].slice.call(document.querySelectorAll('[data-count]'));

  function inView(el, ratio) {
    var r = el.getBoundingClientRect();
    var vh = window.innerHeight || document.documentElement.clientHeight;
    return r.top < vh * (ratio || 0.9) && r.bottom > 0;
  }

  function animateCount(el) {
    if (el.dataset.counted) return;
    el.dataset.counted = '1';
    var target = parseFloat(el.dataset.count);
    var suffix = el.dataset.suffix || '';
    var dur = 1400, start = null;
    function step(ts) {
      if (!start) start = ts;
      var p = Math.min((ts - start) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = Math.round(target * eased) + suffix;
      if (p < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }

  function checkReveal() {
    for (var i = revealEls.length - 1; i >= 0; i--) {
      if (inView(revealEls[i], 0.92)) {
        revealEls[i].classList.add('is-visible');
        revealEls.splice(i, 1);
      }
    }
    for (var j = counters.length - 1; j >= 0; j--) {
      if (inView(counters[j], 0.85)) {
        animateCount(counters[j]);
        counters.splice(j, 1);
      }
    }
  }
  window.addEventListener('scroll', checkReveal, { passive: true });
  window.addEventListener('resize', checkReveal);
  window.addEventListener('load', checkReveal);
  checkReveal();
  setTimeout(checkReveal, 200);
  setTimeout(checkReveal, 800);

  /* ---- image failure -> reveal placeholder ---- */
  document.querySelectorAll('.media img').forEach(function (img) {
    img.addEventListener('error', function () { img.classList.add('failed'); });
    if (img.complete && img.naturalWidth === 0) img.classList.add('failed');
  });

  /* ---- articles filter ---- */
  var filterBar = document.querySelector('.filter-bar');
  if (filterBar) {
    var cards = document.querySelectorAll('.art-grid .acard');
    filterBar.addEventListener('click', function (ev) {
      var btn = ev.target.closest('button');
      if (!btn) return;
      filterBar.querySelectorAll('button').forEach(function (b) { b.classList.remove('active'); });
      btn.classList.add('active');
      var cat = btn.dataset.cat;
      cards.forEach(function (card) {
        var show = cat === 'all' || card.dataset.cat === cat;
        card.classList.toggle('hidden', !show);
      });
    });
  }

  /* ---- contact form ---- */
  var form = document.querySelector('.form');
  if (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var ok = form.querySelector('.form-success');
      if (ok) ok.classList.add('show');
      form.querySelectorAll('input,textarea').forEach(function (f) { f.value = ''; });
      setTimeout(function () { if (ok) ok.classList.remove('show'); }, 6000);
    });
  }
})();
