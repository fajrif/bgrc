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
});
