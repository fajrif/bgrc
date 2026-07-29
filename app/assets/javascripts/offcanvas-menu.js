// Left off-canvas drawer menu + homepage carousels for the public redesign.
jQuery(function ($) {
  var $menu = $('#offcanvas-menu');
  var $body = $('body');

  function openMenu() {
    $menu.addClass('is-open').attr('aria-hidden', 'false');
    $('#offcanvas-open').attr('aria-expanded', 'true');
    $body.addClass('bbcc-no-scroll');
  }

  function closeMenu() {
    $menu.removeClass('is-open').attr('aria-hidden', 'true');
    $('#offcanvas-open').attr('aria-expanded', 'false');
    $body.removeClass('bbcc-no-scroll');
  }

  $('#offcanvas-open').on('click', function (e) {
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

  // Generic "view more" reveal button: shows the hidden siblings matching
  // the button's data-target selector, then hides itself.
  $('.bbcc-view-more').on('click', function () {
    var $btn = $(this);
    $($btn.data('target')).removeClass('bbcc-masonry-item-hidden');
    $btn.hide();
  });

  // Homepage carousels (Swiper is bundled in theme-vendors.min.js).
  if (typeof Swiper !== 'undefined') {
    $('.bbcc-swiper').each(function () {
      var el = this;
      new Swiper(el, {
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
      });
    });
  }
});
