// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require flatpickr.min.js
//= require quill.global
//= require bootstrap.bundle.min.js
//= require simplebar.min.js
//= require choices.min.js
//= require app.js

jQuery(document).ready(function($){
  if (history && history.pushState) {
    // handle index sort and pagination using ajax
    $("#index_table .pagination a").on("click", function(e) {
      $.getScript(this.href);
      history.pushState({module:"leave"}, document.title, this.href);
      e.preventDefault();
    });

    $(".filter_checkbox").click(function(e) {
      $.get($("#index_search").attr("action"), $("#index_search").serialize(), {module:"leave"}, "script");
      history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + $("#index_search").serialize());
      e.preventDefault();
    });

    $(".filter_select").change(function(e) {
      $.get($("#index_search").attr("action"), $("#index_search").serialize(), {module:"leave"}, "script");
      history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + $("#index_search").serialize());
      e.preventDefault();
    });

    $("#btn-export-page").on("click", function(e) {
			var myArray = window.location.href.split("?");
      e.preventDefault();
			window.location.href = myArray[0] + ".xls?" + myArray[1];
    });

    $("#btn-reset-table").on("click", function(e) {
			if($('#index_search')[0]) {
				$('#index_search')[0].reset();
			}
			if($('#index_filter')[0]) {
				$('#index_filter')[0].reset();
			}
      $.get($("#index_search").attr("action"), "", {module:"leave"}, "script");
      history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action"));
      e.preventDefault();
    });

    $("#index_table th.sort").on("click", function(e) {
			var sort = $(this).data('sort');
			var direction = "asc";
			if($(this).attr('class').includes('asc')) {
				direction = "desc";
			}
			var qs = $("#index_search").serialize() + "&" + $("#index_filter").serialize() + "&sort=" + sort + "&direction=" + direction;
      $.get($("#index_search").attr("action"), qs, {module:"leave"}, "script");
      history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + qs);
      e.preventDefault();
    });

    // handle index input search keyup using ajax
		// Combine with filters
    $("#index_search input").keyup(function(e) {
			if( this.value.length > 0 && this.value.length < 4 ) return;
			var qs = $("#index_search").serialize() + "&" + $("#index_filter").serialize();
      $.get($("#index_search").attr("action"), qs, {module:"leave"}, "script");
      history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + qs);
      e.preventDefault();
    });

		$("#index_filter").on("submit", function(e) {
			var qs = $("#index_search").serialize() + "&" + $("#index_filter").serialize();
      $.get($("#index_search").attr("action"), qs, {module:"leave"}, "script");
      history.replaceState({module:"leave"}, document.title, $("#index_search").attr("action") + "?" + qs);
      e.preventDefault();
    });

    // bind window for popstate
    $(window).bind("popstate", function(evt) {
      var state = evt.originalEvent.state;
      if (state && state.module === "leave"){
        $.getScript(location.href);
      }
    });
  }

	// reset filter
	$("#btnReset").click(function(e) {
		$('#index_filter')[0].reset();
  });

	// Flatpickr
	$(".datetimepicker").flatpickr({"altInput":true, "altFormat": "d/m/Y H:i", "enableTime": true, "disableMobile":true, "dateFormat":"d/m/Y H:i"});
	$(".datepicker").flatpickr({"altInput":true, "altFormat": "d/m/Y", "enableTime": false, "disableMobile":true, "dateFormat":"d/m/Y"});

	// Choices
	if($('.form-select').length > 0){
		$('.form-select').each(function(index, element) {
			const choices = new Choices(element, {
				searchEnabled: false
			});
		});
	}
});
