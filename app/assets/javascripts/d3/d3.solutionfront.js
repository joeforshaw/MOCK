$(document).ready(function() {
    if (window.gon === undefined || gon.is_run === null || !gon.is_run) {
        return;
    }

    $('#solution-front-graph').svg();

    solutionID       = 0;
    connectivity     = 1;
    overallDeviation = 2;
    noOfClusters     = 3;
    silhouetteWidth  = 4;
    controlDistance  = 5;

    noOfHighlightedSolutions = 0;

    var horizontalPadding = ($(window).width() - 960) / 2;

    var margin     = {top: 30, right: horizontalPadding, bottom: 30, left: horizontalPadding},
        pageWidth  = $(window).width(),
        width      = 960,
        pageHeight = $(window).height(),
        height     = 500;

    var x = d3.scale.linear()
        .range([0, width]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .interpolate("step-after")
        .x(function(d) { return x(d[connectivity]); })
        .y(function(d) { return y(d[overallDeviation]); });

    solutionFrontSVG = d3.select("#solution-front-graph svg")
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
                .attr("class", "solution-front-link")
                .each(function(d) {
                    if (gon.evidence_accumulation === undefined || !gon.evidence_accumulation || gon.evidence_accumulation_complete) {
                        d3.select(this).attr("xlink:href", function(d) { return getSolutionPath(d); });
                    }
                })
                .append("circle")
                .attr("r", 5)
                .attr("cx", function(d) { return x(d[connectivity]); })
                .attr("cy", function(d) { return y(d[overallDeviation]); })
                .attr("original-title", function(d) {
                    return "Solution "                  + d[solutionID] + "<hr/>" 
                         + "Number of Clusters : "      + d[noOfClusters]
                         + "<br/>Silhouette width : "   + d[silhouetteWidth]
                         + "<br/>Control distance : "   + d[controlDistance];
                })
                .on('mouseover', function(d){
                    $(".last-solution").removeClass("last-solution");
                })
                .attr("id", function(d) { return d[solutionID]; })
                .attr("class", function(d) { return "solution-front-point"; });

            $("#" + gon.last_solution).addClass("last-solution");

            // Use tipsy to indiciate to user they have to wait for EA to complete
            if (gon.evidence_accumulation && !gon.evidence_accumulation_complete) {
                $("circle.solution-front-point").attr("original-title", "Evidence Accumulation is running. Try again when it's complete.");
            }
            $("circle.solution-front-point").tipsy({ fade: true, gravity: 's', offset: 1, offsetX: 5, html: true });
            
            setupEventsListeners(solutionFrontSVG, solutionData);
        });
    });
});

function setupEventsListeners(svg, data) {
    // Event listener for number field
    $("#solution_number").bind("change paste keyup", function() {
        var value = this.value;

        if (value !== "") {
            if (value < 0) {
                value = 0;
            } else if (value > gon.no_of_solutions) {
                value = gon.no_of_solutions;
            }
            this.value = value;
        }
        noOfHighlightedSolutions = value;

        if ($("#solution_measure_silhouette_width").is(':checked')) {
            highlight("silhouette-width");
        } else if ($("#solution_measure_control_distance").is(':checked')) {
            highlight("control-distance");
        }
    });

    $("#solution_measure_silhouette_width").change(function() {
        highlight("silhouette-width");
    });

    $("#solution_measure_control_distance").change(function() {
        highlight("control-distance");
    });
}

function highlight(measureClass) {
    clearHighlightedPoints();
    solutionFrontSVG.selectAll(".solution-front-point")
        .sort(function(a,b) {
            if (measureClass === "silhouette-width") {
                return d3.descending(a[silhouetteWidth], b[silhouetteWidth]);
            } else {
                return d3.descending(a[controlDistance], b[controlDistance]);
            }
        }).each(function(d, i) {
            if (i < noOfHighlightedSolutions) {
                $("#" + d[solutionID]).addClass(measureClass);
            }
        });
}

function clearHighlightedPoints() {
    $(".silhouette-width").removeClass("silhouette-width");
    $(".control-distance").removeClass("control-distance");
}

function getSolutionPath(d) {
    if (gon.evidence_accumulation) {
        if (gon.evidence_accumulation_complete) {
            return gon.evidence_accumulation_path + "?solution=" + d[solutionID];
        } else {
            return "";
        }
        
    } else {
        return gon.solution_path + d[solutionID];
    }
}

function updateLastSolution() {
    gon.unwatch('last_solution', updateLastSolution);
    alert(gon.last_solution);
}
