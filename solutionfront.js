var margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
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

var solutionFrontSVG = d3.select("#solution-front-graph")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var dsv = d3.dsv(" ", "text/plain");

// Solution data
dsv("data/joe.example.solution.pf", function(error, data) {
    data.forEach(function(d) {
        d.Connectivity = +d.Connectivity;
        d.Deviation    = +d.Deviation;
    });

    x.domain([0, 1]);
    y.domain([0, 1]);

    solutionFrontSVG.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      .append("text")
        .attr("class", "label")
        .attr("x", width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("Connectivity");

    solutionFrontSVG.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Overall Deviation");

    data.sort(function(a, b) {
        return d3.ascending(a.Deviation, b.Deviation);
    });

    solutionFrontSVG.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("d", line)

});

// Control data
dsv("data/joe.example.control.pf", function(error, data) {
    data.forEach(function(d) {
        d.Connectivity = +d.Connectivity;
        d.Deviation    = +d.Deviation;
    });

    console.log(data);

    data.sort(function(a, b) {
        return d3.ascending(a.Deviation, b.Deviation);
    });

    solutionFrontSVG.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("d", line)  
});
