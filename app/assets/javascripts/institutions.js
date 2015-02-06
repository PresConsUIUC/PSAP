var InstitutionEditForm = function() {

    this.init = function() {
        // Load the edit panel content via ajax when it appears
        var institution_url = $('input[name="institution_url"]').val();
        $('#psap-edit-panel').on('show.bs.modal', function (e) {
            $.get(institution_url + '/edit', function(data) {
                $(e.target).find('.modal-body').html(data);
                PSAP.Form.init();
            });
        });
    };

};

var ResourceSearchForm = {

    init: function() {
        var form = $('.psap-search');
        var all_elements = form.find('textarea, input, select, button');

        $('.psap-clear').on('click', function() {
            all_elements.prop('disabled', true);
            form.submit();
        });

        // resource type
        $('[name="resource_type"]').on('change', function() {
            if ($(this).filter(':checked').val() == '1') { // 1 = item
                $('#format_id').prop('disabled', false);
                $('[name="assessed"]').prop('disabled', false);
            } else {
                $('#format_id').prop('disabled', true);
                $('[name="assessed"]').prop('disabled', true);
            }
        }).filter(':checked').trigger('change');

        // assessed
        $('[name="assessed"]').on('change', function() {
            if ($(this).filter(':checked').val() == '1') {
                $('#score, #score_direction').prop('disabled', false);
            } else {
                $('#score, #score_direction').prop('disabled', true);
            }
        }).filter(':checked').trigger('change');
    }

};

var ready = function() {
    switch ($('input[name="subpage"]').val()) {
        case 'assessment_report':
            $('.psap-chart').each(function() {
                // transform the json source data for D3
                var sourceData = $.parseJSON($(this).prev('input[name="chart_data"]').val());
                var barData = [];
                for (var i = 0; i < sourceData.length; i++) {
                    barData.push({ 'x': i * 10, 'y': sourceData[i] });
                }

                var vis = d3.select('#' + $(this).attr('id')),
                    WIDTH = $(this).width(),
                    HEIGHT = $(this).height(),
                    MARGINS = {
                        top: 20,
                        right: 20,
                        bottom: 20,
                        left: 50
                    },
                    xRange = d3.scale.ordinal().rangeRoundBands([MARGINS.left, WIDTH - MARGINS.right], 0.1).domain(barData.map(function (d) {
                        return d.x;
                    })),
                    yRange = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([0,
                        d3.max(barData, function (d) {
                            return d.y;
                        })
                    ]),
                    xAxis = d3.svg.axis()
                        .scale(xRange)
                        .tickSize(5)
                        .tickSubdivide(true),
                    yAxis = d3.svg.axis()
                        .scale(yRange)
                        .tickSize(5)
                        .orient('left')
                        .tickSubdivide(true);

                vis.append('svg:g')
                    .attr('class', 'x axis')
                    .attr('transform', 'translate(0,' + (HEIGHT - MARGINS.bottom) + ')')
                    .call(xAxis);
                vis.append('svg:g')
                    .attr('class', 'y axis')
                    .attr('transform', 'translate(' + (MARGINS.left) + ',0)')
                    .call(yAxis); /*
                 vis.append('text')
                 .attr('x', WIDTH / 2)
                 .attr('y',  HEIGHT)
                 .style('text-anchor', 'middle')
                 .text('Score'); */
                vis.selectAll('rect')
                    .data(barData)
                    .enter()
                    .append('rect')
                    .attr('x', function (d) {
                        return xRange(d.x);
                    })
                    .attr('y', function (d) {
                        return yRange(d.y);
                    })
                    .attr('class', function (d) { return 'bar bar-' + d.x })
                    .attr('width', xRange.rangeBand())
                    .attr('height', function (d) {
                        return ((HEIGHT - MARGINS.bottom) - yRange(d.y));
                    });
            });
            break;
        case 'search':
            ResourceSearchForm.init();
            break;
    }
    new InstitutionEditForm().init();
};

$(document).ready(ready);
$(document).on('page:load', ready);
