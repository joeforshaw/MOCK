$(document).ready(function() {
    var xDimension = 1;
    var yDimension = 2;

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

    var solutionSVG = d3.select("#solution-graph")
        .attr("width", pageWidth)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    $(".solution").spin();

    d3.text(gon.solution_path, function(text) {
        
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
            .attr("class", "x axis")
            .attr("width", width)
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis)

        solutionSVG.append("g")
            .attr("class", "y axis")
            // .attr("transform", "translate(" + (margin.left) + ",0)")
            .call(yAxis)

        solutionSVG.selectAll(".dot")
            .data(data)
          .enter().append("circle")
            .attr("class", "solution-point")
            .attr("r", 3)
            .attr("cx", function(d) { return x(d[xDimension]); })
            .attr("cy", function(d) { return y(d[yDimension]); })
            .attr("data-cluster", function(d) { return d[d.length - 1]; })
            .style("fill", function(d) { return color(d[d.length - 1]); });
            

        var legend = solutionSVG.selectAll(".solution-legend")
            .data(color.domain())
          .enter().append("g")
            .attr("transform", function(d, i) { return "translate(28," + i * 22 + ")"; });

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
});