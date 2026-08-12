// Left off-canvas drawer menu + homepage carousels for the public redesign.
jQuery(function ($) {
  var $menu = $('#offcanvas-menu');
  var $body = $('body');

  function openMenu() {
    $menu.addClass('is-open').attr('aria-hidden', 'false');
    $('.bbcc-menu-toggle').attr('aria-expanded', 'true');
    $body.addClass('bbcc-no-scroll');
  }

  function closeMenu() {
    $menu.removeClass('is-open').attr('aria-hidden', 'true');
    $('.bbcc-menu-toggle').attr('aria-expanded', 'false');
    $body.removeClass('bbcc-no-scroll');
  }

  // Left and right hamburgers both share the .bbcc-menu-toggle class, so one
  // binding opens the menu no matter which side the visitor taps.
  $('.bbcc-menu-toggle').on('click', function (e) {
    e.preventDefault();
    openMenu();
  });

  $('#offcanvas-close, #offcanvas-backdrop').on('click', function (e) {
    e.preventDefault();
    closeMenu();
  });

  $(document).on('keyup', function (e) {
    if (e.key === 'Escape' && $menu.hasClass('is-open')) {
      closeMenu();
    }
  });

  // Collapsible accordion groups (Club Life sidebar, offcanvas menu sections):
  // a toggle button reveals a sibling panel with a smooth height/opacity
  // transition. `hidden` is display:none, which has no height to transition
  // from, so the panel is measured and animated by hand and the attribute is
  // set at the ends.
  var ACCORDION_DURATION = 260;
  var ACCORDION_EASING = 'cubic-bezier(.4, 0, .2, 1)';
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function slidePanel(panel, open) {
    if (reduceMotion) { panel.hidden = !open; return; }
    if (panel.bbccAnim) panel.bbccAnim.cancel();

    panel.hidden = false;
    var height = panel.scrollHeight;
    panel.style.overflow = 'hidden';
    // fill:forwards holds the last frame, otherwise the panel snaps back to
    // its natural height for a frame before onfinish hides it
    panel.bbccAnim = panel.animate(
      { height: open ? ['0px', height + 'px'] : [height + 'px', '0px'],
        opacity: open ? [0, 1] : [1, 0] },
      { duration: ACCORDION_DURATION, easing: ACCORDION_EASING, fill: 'forwards' }
    );
    panel.bbccAnim.onfinish = function () {
      var anim = panel.bbccAnim;
      panel.bbccAnim = null;
      panel.hidden = !open;
      panel.style.overflow = '';
      if (anim) anim.cancel(); // release the fill now the real state is set
    };
  }

  function initAccordion(toggleSelector, groupClass, openClass) {
    document.querySelectorAll(toggleSelector).forEach(function (btn) {
      btn.addEventListener('click', function () {
        var panel = document.getElementById(btn.getAttribute('aria-controls'));
        var expanded = btn.getAttribute('aria-expanded') === 'true';
        btn.setAttribute('aria-expanded', expanded ? 'false' : 'true');
        var group = btn.closest('.' + groupClass);
        if (group) group.classList.toggle(openClass, !expanded);
        if (panel) slidePanel(panel, !expanded);
      });
    });
  }

  initAccordion('.bbcc-clublife-nav-toggle', 'bbcc-clublife-nav-group', 'bbcc-clublife-nav-group-open');
  initAccordion('.bbcc-offcanvas-toggle', 'bbcc-offcanvas-group', 'bbcc-offcanvas-group-open');

  // Generic "view more" reveal button: shows the hidden siblings matching
  // the button's data-target selector, then hides itself. The selector is
  // always the hiding class itself, so derive the class to strip from it.
  $('.bbcc-view-more').on('click', function () {
    var $btn = $(this);
    var target = String($btn.data('target') || '');
    $(target).removeClass(target.replace(/^\./, ''));
    $btn.hide();
  });

  // Homepage carousels (Swiper is bundled in theme-vendors.min.js).
  if (typeof Swiper !== 'undefined') {
    $('.bbcc-swiper').each(function () {
      var el = this;
      var options = {
        slidesPerView: 1.15,
        spaceBetween: 16,
        grabCursor: true,
        navigation: {
          nextEl: el.querySelector('.bbcc-swiper-next'),
          prevEl: el.querySelector('.bbcc-swiper-prev')
        },
        pagination: {
          el: el.querySelector('.bbcc-swiper-pagination'),
          clickable: true
        },
        breakpoints: {
          576: { slidesPerView: 2, spaceBetween: 20 },
          992: { slidesPerView: 3, spaceBetween: 24 },
          1200: { slidesPerView: 4, spaceBetween: 24 }
        }
      };
      if (el.classList.contains('bbcc-testimonials-swiper')) {
        options.autoplay = { delay: 5000, disableOnInteraction: false, pauseOnMouseEnter: true };
      }
      new Swiper(el, options);
    });
  }
});
