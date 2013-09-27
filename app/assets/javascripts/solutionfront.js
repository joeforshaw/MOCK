var margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = 1000 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

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
    .x(function(d) { return x(d.Deviation); })
    .y(function(d) { return y(d.Connectivity); });

var solutionFrontSVG = d3.select("#pareto-front-graph")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var dsv = d3.dsv(" ", "text/plain");

// Solution front data
dsv("/algo/data/joe.example.solution.pf", function(error, solutionData) {
    solutionData.forEach(function(d) {
        d.Connectivity = +d.Connectivity;
        d.Deviation    = +d.Deviation;
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
        .attr("class", "solution-front-label")
        .attr("x", 40 + width / 2)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("Connectivity");

    // Draw y-axis
    solutionFrontSVG.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("class", "solution-front-label")
        .attr("x", 50 + height / -2)
        .attr("y", 6)
        .attr("transform", "rotate(-90)")
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Overall Deviation");

    solutionData.sort(function(a, b) {
        return d3.ascending(a.Deviation, b.Deviation);
    });

    // Control data
    dsv("/algo/data/joe.example.control.pf", function(error, controlData) {
        controlData.forEach(function(d) {
            d.Connectivity = +d.Connectivity;
            d.Deviation    = +d.Deviation;
        });

        // Sort control data
        controlData.sort(function(a, b) {
            return d3.ascending(a.Deviation, b.Deviation);
        });

        // Draw control line
        solutionFrontSVG.append("path")
            .datum(controlData)
            .attr("class", "line")
            .attr("d", line)  
            .style("stroke", "rgb(213,214,215)")

        // Draw solution front line
        solutionFrontSVG.append("path")
            .datum(solutionData)
            .attr("class", "line")
            .attr("d", line)
    });

});
