/*==============================================================
    pull menu
 ==============================================================*/
(function($) {
  "use strict";

	var bodyEl = document.body,
			closeBtn = $("#menu-wrap-close-btn"),
			mask = $("#menu-wrap-menu-1 .menu-wrap-mask"),
			topBar = $(".top-header-area"),
			parentMenu = $(".full-width-pull-menu"),
			menu = $("#menu-wrap-menu-1");

	function closeMenu() {
    menu.removeClass("active");
		var showMenu = $('.menu-wrap-content-menu.show');
		showMenu.removeClass("show");
		parentMenu.removeClass("opened-menu");
		topBar.removeClass("opened-menu");
		classie.remove(bodyEl, 'overflow-hidden');
	}

	$('.open-wrap-menu').each(function () {
		var $this = $(this);
		$this.on("click", function () {
			closeMenu();
			// console.log($(this).data('menu-id'));
			var _menuId = $(this).data('menu-id');
			var menuId = $('#' + _menuId);
			menuId.addClass("show");
			menu.addClass("active");
			parentMenu.addClass("opened-menu");
			topBar.addClass("opened-menu");
			classie.add(bodyEl, 'overflow-hidden');
		});
	});

  // Close menu when click on Close button
  closeBtn.on("click", function() {
		closeMenu();
  });

  mask.on("click", function() {
		closeMenu();
  });

})(jQuery);
