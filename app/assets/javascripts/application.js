// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.remotipart
//= require flatpickr.min.js
//= require bootsnav.js
//= require jquery.nav.js
//= require hamburger-menu.js
//= require theme-vendors.min.js
//= require bootstrap-select.min.js
//= require main.js
//= require offcanvas-menu

jQuery(document).ready(function($){
	// Search
	if (history && history.pushState) {
		$(".filter_select").change(function(e) {
			$.get($("#index_search").attr("action"), $("#index_search").serialize(), {module:"leave"}, "script");
			history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + $("#index_search").serialize());
			e.preventDefault();
		});
	}

	// Flatpickr
	$(".datepicker").flatpickr({"altInput":true, "altFormat": "d/m/Y", "enableTime": false, "disableMobile":true, "dateFormat":"d/m/Y"});
	var maxBookingDate = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000);
	$(".datecourtpicker").flatpickr({"altInput":true, minDate: "today", maxDate: maxBookingDate, "altFormat": "d/m/Y", "enableTime": false, "disableMobile":true, "dateFormat":"d/m/Y"});

	// Sticky header: parked at minus the topbar height, so the topbar scrolls
	// away and only the navbar stays pinned. Measured here rather than hardcoded
	// because the topbar can wrap to two lines on a narrow screen.
	var stickyHeader = document.querySelector('.bbcc-header');
	if (stickyHeader) {
		var stickyTopbar = stickyHeader.querySelector('.bbcc-topbar');
		var stickyTrigger = stickyTopbar ? stickyTopbar.offsetHeight : 10;
		var isStuck = false;

		if (stickyTopbar) stickyHeader.style.top = -stickyTrigger + 'px';

		var onHeaderScroll = function () {
			var shouldStick = window.pageYOffset > stickyTrigger;
			if (shouldStick === isStuck) return;
			isStuck = shouldStick;
			stickyHeader.classList.toggle('bbcc-header-stuck', isStuck);
		};

		window.addEventListener('scroll', onHeaderScroll, { passive: true });
		onHeaderScroll();
	}

	// Accordions (Events, FAQ, ...): opening one <details> closes its siblings
	// within the same .bbcc-accordion/.bbcc-faq-list group.
	//
	// A bare <details> snaps open because its content is display:none while
	// closed and so has nothing to transition from, so the panel height is
	// animated by hand and `open` is flipped at the ends of that animation.
	var ACCORDION_MS = 260;
	var ACCORDION_EASING = 'cubic-bezier(.4, 0, .2, 1)';
	var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

	function accordionPanel(details) {
		return details.querySelector('.bbcc-accordion-body, .bbcc-faq-item-body');
	}

	function accordionAnimate(panel, from, to, onDone) {
		if (panel.bbccAnim) panel.bbccAnim.cancel();
		panel.style.overflow = 'hidden';
		// fill:forwards holds the last frame, otherwise the panel snaps back to
		// its natural height for a frame before onfinish applies the real state
		panel.bbccAnim = panel.animate(
			{ height: [from + 'px', to + 'px'], opacity: [from ? 1 : 0, to ? 1 : 0] },
			{ duration: ACCORDION_MS, easing: ACCORDION_EASING, fill: 'forwards' }
		);
		panel.bbccAnim.onfinish = function () {
			var anim = panel.bbccAnim;
			panel.bbccAnim = null;
			onDone();
			panel.style.overflow = '';
			if (anim) anim.cancel(); // release the fill now the real state is set
		};
	}

	function accordionCollapse(details) {
		var panel = accordionPanel(details);
		if (!details.open || !panel) return;
		if (reduceMotion) { details.open = false; return; }

		// the icon belongs to the panel it controls, so it turns back as the
		// panel closes rather than waiting for `open` to drop at the end
		details.classList.add('is-closing');
		accordionAnimate(panel, panel.offsetHeight, 0, function () {
			details.classList.remove('is-closing');
			details.open = false;
		});
	}

	function accordionExpand(details) {
		var panel = accordionPanel(details);
		if (!panel) return;
		details.classList.remove('is-closing');
		details.open = true;
		if (reduceMotion) return;

		accordionAnimate(panel, 0, panel.offsetHeight, function () {});
	}

	document.querySelectorAll('.bbcc-accordion, .bbcc-faq-list').forEach(function (group) {
		var items = group.querySelectorAll(':scope > details');
		items.forEach(function (item) {
			var summary = item.querySelector('summary');
			if (!summary || !accordionPanel(item)) return;

			summary.addEventListener('click', function (e) {
				e.preventDefault();
				if (item.open && !item.classList.contains('is-closing')) {
					accordionCollapse(item);
				} else {
					items.forEach(function (other) { if (other !== item) accordionCollapse(other); });
					accordionExpand(item);
				}
			});
		});
	});
});
