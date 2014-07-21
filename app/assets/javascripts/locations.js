var ready = function() {
    if ($('body#show_location')) {
        var checkboxes = $('input[name="resources[]"]');

        // hook up "check/uncheck all" buttons
        $('#psap-check-all').on('click', function() {
            checkboxes.each(function() {
                $(this).prop('checked', true);
            });
            $('#psap-uncheck-all').show();
            $(this).hide();
            checkboxes.trigger('change');
        });
        $('#psap-uncheck-all').on('click', function() {
            checkboxes.each(function() {
                $(this).prop('checked', false);
            });
            $('#psap-check-all').show();
            $(this).hide();
            checkboxes.trigger('change');
        });

        // conditionally enable the "move checked" button depending on whether
        // any checkboxes are checked
        checkboxes.on('change', function() {
            $('button#psap-move-checked').prop('disabled',
                !checkboxes.is(':checked'));
        }).trigger('change');
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
