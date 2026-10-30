// Optional "other players' names" panel for Golf and Racquet bookings.
//
// Markup (see shared/_player_names):
//   <div class="bbcc-players" data-player-names data-count-source="#some-select" data-field="player_names[]">
//     <button type="button" class="bbcc-players-toggle" aria-expanded="false">...</button>
//     <div class="bbcc-players-panel" hidden><div class="bbcc-players-fields"></div></div>
//   </div>
// The booker is player 1, so a party of N gets N-1 inputs. The panel hides itself
// for a party of one, and typed names survive the party size changing.
jQuery(function ($) {
  function sync($wrap) {
    var $source = $($wrap.data('countSource'));
    var count = parseInt($source.val(), 10) || 1;
    var needed = Math.max(count - 1, 0);
    var $fields = $wrap.find('.bbcc-players-fields');
    var field = $wrap.data('field') || 'player_names[]';

    $wrap.prop('hidden', needed < 1);
    while ($fields.children().length > needed) { $fields.children().last().remove(); }
    for (var i = $fields.children().length; i < needed; i++) {
      $('<input type="text" class="bbcc-players-input" maxlength="60" autocomplete="off">')
        .attr('name', field)
        .appendTo($fields);
    }
    $fields.children().each(function (index) {
      $(this).attr({ placeholder: 'Player ' + (index + 2) + ' Name (optional)',
                     'aria-label': 'Player ' + (index + 2) + ' name' });
    });
  }

  function toggle($wrap, open) {
    var $panel = $wrap.find('.bbcc-players-panel');
    var $button = $wrap.find('.bbcc-players-toggle');
    $button.attr('aria-expanded', open ? 'true' : 'false');
    $wrap.toggleClass('is-open', open);
    if (open) { $panel.prop('hidden', false).hide().slideDown(180); }
    else { $panel.slideUp(180, function () { $panel.prop('hidden', true); }); }
  }

  // binds every panel under root once; pages that swap their markup via AJAX call it again
  function init(root) {
    $(root || document).find('[data-player-names]').each(function () {
      var $wrap = $(this);
      if ($wrap.data('bound')) return;
      $wrap.data('bound', true);
      $($wrap.data('countSource')).on('change', function () { sync($wrap); });
      $wrap.on('click', '.bbcc-players-toggle', function () {
        toggle($wrap, $(this).attr('aria-expanded') !== 'true');
      });
      sync($wrap);
    });
  }
  init();

  // lets pages that rebuild the count select (golf, by spots left) re-run the sync
  window.bbccPlayerNames = {
    init: init,
    sync: function (root) { $(root || document).find('[data-player-names]').each(function () { sync($(this)); }); },
    reset: function (root) {
      $(root || document).find('[data-player-names]').each(function () {
        var $wrap = $(this);
        $wrap.find('.bbcc-players-fields').empty();
        $wrap.removeClass('is-open').find('.bbcc-players-toggle').attr('aria-expanded', 'false');
        $wrap.find('.bbcc-players-panel').prop('hidden', true).hide();
        sync($wrap);
      });
    }
  };
});
