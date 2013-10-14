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

var solutionSVG = d3.select("#solution-graph")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.text(gon.solution_path, function(text) {

    var dataDsv = d3.dsv(" ", "text/plain");
    var data = dataDsv.parseRows(text).map(function(row) {
        return row.map(function(value) {
            return +value;
        });
    });

    var numberOfColumns = data[0].length;

    x.domain(d3.extent(data, function(d) { return d[1]; })).nice();

    y.domain(d3.extent(data, function(d) { return d[2]; })).nice();

    solutionSVG.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      .append("text")
        .attr("class", "graph-label")
        .attr("x", width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("First Dimension");

    solutionSVG.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("class", "graph-label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Second Dimension");

    solutionSVG.selectAll(".dot")
        .data(data)
      .enter().append("circle")
        .attr("class", "solution-point")
        .attr("r", 3)
        .attr("cx", function(d) { return x(d[1]); })
        .attr("cy", function(d) { return y(d[2]); })
        .attr("data-cluster", function(d) { return d[d.length - 1]; })
        .style("fill", function(d) { return color(d[d.length - 1]); });
        

    var legend = solutionSVG.selectAll(".solution-legend")
        .data(color.domain())
      .enter().append("g")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
        .attr("x", width - 18)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", function(d, i) { return color(i); })
        .attr("class", "solution-legend")
        .attr("data-cluster", function(d, i) { return i; });

    // legend.append("text")
    //     .attr("x", width - 24)
    //     .attr("y", 9)
    //     .attr("dy", ".35em")
    //     .style("text-anchor", "end")
    //     .text(function(d) { return d; });

});

$(document).ready(function() {

    // Cluster filter when clicking legend boxes
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
                $(this).css("opacity", 0.1);
            }
        });
    });

});