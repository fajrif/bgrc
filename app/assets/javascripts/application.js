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
//= require bootsnav.js
//= require jquery.nav.js
//= require hamburger-menu.js
//= require theme-vendors.min.js
//= require bootstrap-select.min.js
//= require main.js

jQuery(document).ready(function($){
	// Search
	if (history && history.pushState) {
		$(".filter_select").change(function(e) {
			$.get($("#index_search").attr("action"), $("#index_search").serialize(), {module:"leave"}, "script");
			history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + $("#index_search").serialize());
			e.preventDefault();
		});
	}

});
