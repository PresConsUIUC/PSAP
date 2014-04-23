$(document).ready(function() {
    // Update the Edit Section button with the currently selected section ID
    if ($('body#assessment_template').length) {
        $('.nav-pills').on('click', function() {
            var section_id = $(this).find('li.active').attr('data-open');
            $('#edit_section_button').attr('href',
                    '/assessment-sections/' + section_id + '/edit');
        }).trigger('click');
    }
});
