$(document).ready(function() {

    var horizontalPadding = (document.width - 960) / 2;

    var margin     = {top: 30, right: horizontalPadding, bottom: 30, left: horizontalPadding},
        pageWidth  = document.width,
        width      = 960,
        pageHeight = document.height,
        height     = 500;

    var x = d3.scale.linear()
        .range([0, width]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var color = d3.scale.category10();

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .interpolate("step-after")
        .x(function(d) { return x(d[1]); })
        .y(function(d) { return y(d[2]); });

    var solutionFrontSVG = d3.select("#pareto-front-graph")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var dsv = d3.dsv(" ", "text/plain");

    $(".solution-front").spin();

    // Solution front data
    d3.text(gon.solution_front_path, function(text) {

        var solutionDsv = d3.dsv(" ", "text/plain");
        var solutionData = solutionDsv.parseRows(text).map(function(row) {
            return row.map(function(value) {
                return +value;
            });
        });

        // Set x and y domains between 0 and 1
        x.domain([0, 1]);
        y.domain([0, 1]);

        // Draw x-axis
        solutionFrontSVG.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis)
          .append("text")
            .attr("class", "graph-label")
            .attr("x", 40 + width / 2)
            .attr("y", -6)
            .style("text-anchor", "end")
            .text("Connectivity");

        // Draw y-axis
        solutionFrontSVG.append("g")
            .attr("class", "y axis")
            .call(yAxis)
          .append("text")
            .attr("class", "graph-label")
            .attr("x", 50 + height / -2)
            .attr("y", 6)
            .attr("transform", "rotate(-90)")
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text("Overall Deviation");

        // Control data
        d3.text(gon.solution_control_front_path, function(text) {

            $(".solution-front").spin(false);

            var controlDsv = d3.dsv(" ", "text/plain");
            var controlData = controlDsv.parseRows(text).map(function(row) {
                return row.map(function(value) {
                    return +value;
                });
            });

            // Draw control line
            solutionFrontSVG.append("path")
                .datum(controlData)
                .attr("class", "line")
                .attr("d", line)
                .style("stroke", "rgb(220,220,220)");

            // Draw solution front line
            solutionFrontSVG.append("path")
                .datum(solutionData)
                .attr("class", "line")
                .attr("d", line)
                .style("stroke", "rgb(241,194,50)");

            // Add points to solution front line
            solutionFrontSVG.selectAll("solution-front-point")
                .data(solutionData).enter()
                .append("a")
                .attr("xlink:href", function(d) { return gon.solution_path + d[0]; })
                .append("circle")
                .attr("class", "solution-front-point")
                .attr("r", 5)
                .attr("cx", function(d) { return x(d[1]); })
                .attr("cy", function(d) { return y(d[2]); });

        });
    });
});