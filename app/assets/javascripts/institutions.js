var ready = function() {
    if ($('body#show_institution')) {
        ShowInstitutionForm.attachEventListeners();

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
                .attr('width', xRange.rangeBand())
                .attr('height', function (d) {
                    return ((HEIGHT - MARGINS.bottom) - yRange(d.y));
                })
                .attr('fill', 'rgb(66, 139, 202)'); // bootstrap blue
        });
    }
};

var ShowInstitutionForm = {
    attachEventListeners: function() {
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

$(document).ready(ready);
$(document).on('page:load', ready);
