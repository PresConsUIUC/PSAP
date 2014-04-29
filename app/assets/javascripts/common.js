$(document).ready(function() {
    // Sorting and pagination links
    // These don't work yet
    //$('#formats th a, .pagination a').live('click', function() {
    /*$(document).on('click', '.pagination a', function() {
        $.getScript(this.href);
        return false;
    });*/

	$('button[data-toggle="popover"]').popover();

    // Entity live-search forms
    $('.entity_search').submit(function() {
        $.get(this.action, $(this).serialize(), null, 'script');
        $(this).nextAll('input').addClass('active');
        return false;
    });
    $('.entity_search input').on('keyup', function() {
        $.get($('.entity_search').attr('action'),
            $('.entity_search').serialize(), null, 'script');
        $(this).addClass('active');
        return false;
    });

    // Show the modal progress view after submitting an ajax form
    $(document).on('submit', 'form[data-remote="true"]', function() {
        var view = $('#modal_progress_view');
        view.height($(document).height());
        view.show();
    });

    updateResultsCount();

    $(window).on('resize', function() {
		var navBar = $('nav.navbar');
		// Unfix the nav bar from the top on small screens; otherwise it will
		// fill way too much of the screen.
		if ($(window).width() < 500 || $(window).height() < 400) {
			navBar.removeClass('navbar-fixed-top');
			$('body').css('padding-top', '');
		} else {
			navBar.addClass('navbar-fixed-top');
			$('body').css('padding-top', '50px');
		}
    }).trigger('resize');

    // Fade out flash messages after a delay. This will work only with
    // server-rendered flash messages; the same thing is done with ajax-
    // rendered flash messages in ajax.js.
    /*
    setTimeout(function() {
        $('div.alert-dismissable').fadeOut(1000);
    }, 5000);
    */

    // Used by the Bootstrap 3 tab bar
    // http://getbootstrap.com/javascript/#tabs
    $('ul.nav-tabs a, ul.nav-pills a').click(function(e) {
        e.preventDefault();
        $(this).tab('show');
    });

    // Show the glossary, bibliography, help, etc. in a modal panel instead of
    // a new page
    $('a.modal_view').on('click', function() {
        $('#appModal').modal('show');

        $.get($(this).attr('data-open'), function(data) {
            var content = $(data).find('div#page_content');

            $('div.modal-body').html(content.html());
            $('#appModalTitle').text($('div.modal-body h1').text());
            $('div.modal-body h1').remove();
        });
        return false;
    });

	Form.enableDynamicNestedEntities();
});

/**
 * Updates the results count text. Called on document ready and in index.js.erb
 * files on ajax load.
 */
function updateResultsCount() {
    var query_input = $('.entity_search input[name="q"]');
    if (query_input.length) {
        var query_length = query_input.val().length;
        var count_elem = $('input[name="results_count"]');
        if (count_elem.length) {
            var count = count_elem.val();
            $('.entity_count').text(count + ' '
                + ((query_length > 0) ? ((count == 1) ? 'match' : 'matches') : 'total'));
        }
    }
}

var Form = {

    TYPE_URL: 0,

	enableDynamicNestedEntities: function() {
		var updateIndexes = function() {
			$('.addable_removable').each(function() {
				$(this).find('.addable_removable_input_group input[type="hidden"].index').each(function(index) {
					$(this).val(index);
				});
			});
		};

		// enable certain form elements to be dynamically added and removed, as
		// in the case of a nested form with a 1..n relationship to its child
		// object(s).
		$('.addable_removable button.remove').on('click', function() {
			// Instead of removing it from the DOM, hide it and set its
			// "_destroy" key to 1, so Rails knows to destroy its corresponding
			// model.
			var group = $(this).closest('.addable_removable_input_group');
			group.hide();
			group.find('input[type="hidden"].destroy').val(1);

			updateIndexes();
		});

		$('.addable_removable button.add').on('click', function() {
			// prohibit adding more than 10 fields
			if ($(this).closest('.addable_removable')
				.children('.addable_removable_input_group').length >= 10) {
				return;
			}

			// clone the last input group and insert the clone into the DOM
			var group = $(this).prevAll('.addable_removable_input_group:first');
			var cloned_group = group.clone(true);
			group.after(cloned_group);
			cloned_group.show();

			// find all of its input elements
			cloned_group.find('input, select, textarea').each(function() {
				// update the element's indexes within the form, for rails
				var index = parseInt($(this).attr('id').match(/\d+/)[0]);
				$(this).attr('id',
					$(this).attr('id').replace(index, index + 1));
				$(this).attr('name',
					$(this).attr('name').replace(index, index + 1));

				// reset its value
				if ($(this).is('select')) {
					$(this).val(
						$(this).parent().prev().find('select:first').val());
				} else if (!$(this).is('input[type="hidden"]')) {
					$(this).val(null);
				} else if ($(this).is('input[type="hidden"].destroy')) {
					$(this).val(0);
				}
			});

			updateIndexes();
		});

		updateIndexes();
	},

    validate: function(field_id, min_length, max_length, type) {
        var elem = $('#' + field_id);
        elem.parent('div').removeClass('has-success');
        elem.parent('div').removeClass('has-error');
        elem.next('span').removeClass('glyphicon-ok');
        elem.next('span').removeClass('glyphicon-remove');

        var passValidation = function(elem) {
            elem.parent('div').addClass('has-success');
            elem.next('span').addClass('glyphicon-ok');
        };

        var failValidation = function(elem) {
            elem.parent('div').addClass('has-error');
            elem.next('span').addClass('glyphicon-remove');
        };

        passValidation(elem);

        var value = elem.val().trim();

        if (min_length > 0 && max_length > 0) {
            if (value.length >= min_length && value.length <= max_length) {
                passValidation(elem);
            } else {
                failValidation(elem);
            }
        } else if (type == Form.TYPE_URL) {
            // very crude checks here, but good enough
            if (value.substring(0, 7) == 'http://' && value.length > 7
                || value.substring(0, 8) == 'https://' && value.length > 8) {
                passValidation(elem);
            } else {
                failValidation(elem);
            }
        }
    }

};
