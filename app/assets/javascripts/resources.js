$(document).ready(function() {
    if ($('body#new_resource') || $('body#edit_resource')) {
        ResourceForm.init();
    }
});

var ResourceForm = {

    init: function() {
        ResourceForm.attachEventListeners();
        ResourceForm.updateProgressBar();
        ResourceForm.updateScoreBar();

        $('button.save').on('click', function(event) {
            $('div.tab-pane.active form').submit();
        });
    },

    attachEventListeners: function() {
        $('select.date_type').on('change', function(event) {
            switch (parseInt(this.value)) {
                case 0: // single
                    $(this).nextAll('div.date:first').show();
                    $(this).nextAll('div.begin_date:first').hide();
                    $(this).nextAll('div.end_date:first').hide();
                    break;
                default: // bulk or inclusive/span
                    $(this).nextAll('div.date:first').hide();
                    $(this).nextAll('div.begin_date:first').show();
                    $(this).nextAll('div.end_date:first').show();
                    break;
            }
        }).trigger('change');

        $('input.year').on('keyup', function(event) {
            if ($(this).val().length < 1) {
                $(this).parent().parent().find('input.month').prop('disabled', true);
                $(this).parent().parent().find('input.day').prop('disabled', true);
            } else {
                $(this).parent().parent().find('input.month').prop('disabled', false);
            }
        }).trigger('keyup');

        $('input.month').on('keyup', function(event) {
            if ($(this).val().length < 1) {
                $(this).parent().parent().find('input.day').prop('disabled', true);
            } else {
                $(this).parent().parent().find('input.day').prop('disabled', false);
            }
        }).trigger('keyup');

        $('.question input, .question select').on('change', function(event) {
            ResourceForm.updateProgressBar();
            ResourceForm.updateScoreBar();
        }).trigger('change');
    },

    updateScoreBar: function() {
        // Formula (from SRS): TODO: this is broken
        //
        // climate control 70% + emergency preparedness 30% =
        // environment (location)
        //
        // format (40%) + environment (location) (10%) + storage/container (5%)
        // + use/access (5%) + condition (40%) = total
        //
        //  (question 1 weight * question 1 value
        // + question 2 weight * question 2 value
        // + question 2a weight * question 2a value)
        // / number of top-level questions

        var score = 0;
        var weight_elements = $('.question input[name="weight"]');

        weight_elements.each(function() {
            var weight = $(this).val();

            var input_elem = $(this).parent().find(
                'input[type="radio"]:checked, input[type="checkbox"]:checked, option:selected');
            var response_value = input_elem.attr('data-option-score');

            if (response_value !== undefined) {
                score += (parseFloat(response_value) * parseFloat(weight))
                    / weight_elements.length;
            }
        });

        $('div.progress-bar.score').attr('style', 'width:' + score * 100 + '%');
    },

    updateProgressBar: function() {
        var numQuestions = $('.question').length;
        var numAnsweredQuestions = 0;
        $('.question').each(function() {
            var numChecked = $(this).find(
                'input[type="radio"]:checked, input[type="checkbox"]:checked').length;
            if (numChecked > 0 || ($(this).find('select').val() !== undefined
                && $(this).find('select').val().length > 0)) {
                numAnsweredQuestions++;
            }
        });
        $('div.progress-bar.psap-progress').attr('style',
                'width:' + numAnsweredQuestions / numQuestions * 100 + '%');
    }

};
