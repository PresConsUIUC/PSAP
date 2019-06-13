var AssessmentChart = {

    init: function() {
        $('.psap-chart').each(function() {
            // transform the json source data for D3
            var sourceData = $.parseJSON($(this).prev('input[name="chart_data"]').val());
            var barData = [];
            for (var i = 0; i < sourceData.length; i++) {
                barData.push({'x': i * 10, 'y': sourceData[i]});
            }

            var WIDTH = $(this).width();
            var HEIGHT = $(this).height();
            var MARGINS = { top: 20, right: 20, bottom: 20, left: 50 };

            var vis = d3.select('#' + $(this).attr('id'));
            var xRange = d3.scale.ordinal().
                rangeRoundBands([MARGINS.left, WIDTH - MARGINS.right], 0.1).
                domain(barData.map(function (d) {
                    return d.x;
                }));
            var yRange = d3.scale.linear().
                range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([0,
                    d3.max(barData, function (d) {
                        return d.y;
                    })
                ]);
            var xAxis = d3.svg.axis().scale(xRange).tickSize(5)
                .tickSubdivide(true);
            // get y domain max
            var y_max = yRange.domain().slice(-1)[0];
            var yAxis = d3.svg.axis().scale(yRange).tickSize(5).orient('left')
                .ticks(8);

            vis.append('svg:g').attr('class', 'x axis')
                .attr('transform', 'translate(0,' + (HEIGHT - MARGINS.bottom) + ')')
                .call(xAxis);
            vis.append('svg:g').attr('class', 'y axis')
                .attr('transform', 'translate(' + (MARGINS.left) + ',0)')
                .call(yAxis);

            vis.append('text') // x-axis label
                .attr('x', WIDTH / 2)
                .attr('y',  HEIGHT + MARGINS.bottom)
                .style('text-anchor', 'middle')
                .text('Assessment Score Range');
            vis.append('text') // y-axis label
                .attr('transform', 'rotate(-90)')
                .attr('x', 0 - HEIGHT / 2)
                .attr('y', 10)
                .style('text-anchor', 'middle')
                .text('Number of Items');
            vis.selectAll('rect').data(barData).enter().append('rect')
                .attr('x', function (d) { return xRange(d.x); })
                .attr('y', function (d) { return yRange(d.y); })
                .attr('class', function (d) { return 'bar bar-' + d.x })
                .attr('width', xRange.rangeBand())
                .attr('height', function (d) {
                    return ((HEIGHT - MARGINS.bottom) - yRange(d.y));
                });
        });
    }

};

var AssessmentReportView = function() {

    AssessmentChart.init();

    $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        var url        = $(e.target).data("url");
        var section_id = $(e.target).attr('href');
        $.ajax({
            url: url,
            success: function(html) {
                $(section_id).html(html);
            }
        });
    });

};

var ready = function() {
    if ($('body#assessment_report').length) {
        new AssessmentReportView();
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);