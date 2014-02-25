$(document).ready(function() {

    if (gon.is_plot === null || !gon.is_plot) {
        return;
    }

    datapointIndex  = 0;
    clusterIndex    = 1;
    nonValueColumns = 0;
    firstValueIndex = 0;

    if (gon.is_solution !== null && gon.is_solution) {
        nonValueColumns = 2;
        firstValueIndex = 2;
    }

    xDimension = $("select#x_dimension").val() - 1 + nonValueColumns;
    yDimension = $("select#y_dimension").val() - 1 + nonValueColumns;

    horizontalPadding = ($(window).width() - 960) / 2;

    margin     = {top: 30, right: horizontalPadding, bottom: 30, left: horizontalPadding},
    pageWidth  = $(window).width(),
    width      = 960,
    pageHeight = $(window).height(),
    height     = 500;

    x = d3.scale.linear()
        .range([0, width]);

    y = d3.scale.linear()
        .range([height, 0]);

    color_scale = d3.scale.category20();

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    solutionSVG = d3.select("#solution-graph")
        .attr("width", pageWidth)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


    drawGraph();

});

function drawGraph() {

    $(".solution").spin();

    // Cluster filter when clicking legend boxes
    d3.text(gon.use_mds ? gon.mds_path : gon.solution_path, function(text) {

        $(".solution").spin(false);

        var dataDsv = d3.dsv(" ", "text/plain");
        var data = dataDsv.parseRows(text).map(function(row) {
            return row.map(function(value) {
                return +value;
            });
        });

        var numberOfColumns = data[0].length;

        x.domain(d3.extent(data, function(d) { return d[xDimension]; })).nice();

        y.domain(d3.extent(data, function(d) { return d[yDimension]; })).nice();

        solutionSVG.append("g")
            .attr("class", "x-axis axis")
            .attr("width", width)
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis);

        solutionSVG.append("g")
            .attr("class", "y-axis axis")
            .call(yAxis);

        solutionSVG.selectAll(".dot")
            .data(data)
          .enter().append("circle")
            .attr("class", "solution-point")
            .attr("r", 3)
            .attr("cx", function(d) { return x(d[xDimension]); })
            .attr("cy", function(d) { return y(d[yDimension]); })
            .attr("data-point", function(d) { return d[datapointIndex]; })
            .attr("data-cluster", function(d) {
                if (gon.is_plot) {
                    return d[clusterIndex];
                } else {
                    return 0;
                }

            })
            .style("fill", function(d) {
                if (gon.is_solution) {
                    return color_scale(d[clusterIndex]);
                } else {
                    return color_scale(0);
                }
            });

        // On change event for X Dimension select
        $("select#x_dimension").change(function() {
            xDimension = $("select#x_dimension").val() - 1 + nonValueColumns;
            x.domain(d3.extent(data, function(d) { return d[xDimension]; })).nice();
            xAxis.scale(x);
            fadeInOutAxis(solutionSVG, xAxis, ".x-axis");
            fadeInOut(solutionSVG, "circle", xDimension, yDimension, x, y);
        });

        // On change event for Y Dimension select
        $("select#y_dimension").change(function() {
            yDimension = $("select#y_dimension").val() - 1 + nonValueColumns;
            y.domain(d3.extent(data, function(d) { return d[yDimension]; })).nice();
            yAxis.scale(y);
            fadeInOutAxis(solutionSVG, yAxis, ".y-axis");
            fadeInOut(solutionSVG, "circle", xDimension, yDimension, x, y);
        });

        $("#view_with_mds").change(function() {
            $("svg#solution-graph > g").empty();
            $("select#x_dimension").unbind();
            $("select#y_dimension").unbind();
            $("#view_with_mds").unbind();
            gon.use_mds = !gon.use_mds;
            drawGraph();
        });

        if (gon.use_mds) {
            $("li.dimension").hide();
        } else {
            $("li.dimension").show();
        }

        if (gon.is_solution) {

            var legend = solutionSVG.selectAll(".solution-legend")
                .data(color_scale.domain())
              .enter().append("g")
                .attr("transform", function(d, i) {
                    return "translate(" + (22 * Math.floor(i / 16) + 24) + "," + ((i % 16) * 22)+ ")";
                });

            legend.append("rect")
                .attr("x", width - 18)
                .attr("width", 18)
                .attr("height", 18)
                .style("fill", function(d, i) {
                    return color_scale(i);
                })
                .attr("class", "solution-legend")
                .attr("data-cluster", function(d, i) { return i; });

            $(".solution-legend").click(function() {

                var isReset = false;
                if (!$(this).hasClass("selected")) {
                    $(".solution-legend.selected").removeClass("selected");
                    $(this).addClass("selected");
                } else {
                    isReset = true;
                    $(".solution-legend.selected").removeClass("selected");
                }

                // Get cluster number of clicked legend
                var legendCluster = $(this).data("cluster");

                // Highlight corresponding cluster points
                $(".solution-point").each(function() {
                    if (isReset || legendCluster === $(this).data("cluster")) {
                        $(this).css("opacity", 1);
                    } else {
                        $(this).css("opacity", 0.08);
                    }
                });
            });
        }
    });

}

function fadeInOut(svg, selector, xDimension, yDimension, x, y) {
    svg.selectAll(selector)
        .attr("cx", function(d) { return x(d[xDimension]); })
        .attr("cy", function(d) { return y(d[yDimension]); });
}

function fadeInOutAxis(svg, xAxis, selector) {
    svg.selectAll(selector + " g.tick.major")
        .transition()
        .duration(200)
        .style("opacity", 0)
        .each("end", function() {
            svg.select(selector)
                .call(xAxis);
            svg.selectAll(selector + " g.tick.major")
                .style("opacity", 0);
            svg.selectAll(selector + " g.tick.major")
                .transition()
                .duration(200)
                .style("opacity", 1);
        });
}