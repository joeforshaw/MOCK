var dimensions = { width: 960, height: 960 };

var datapointIndex  = 0;
var clusterIndex    = 1;
var firstValueIndex = 2;
var nonValueColumns = 2;

var cluster = d3.layout.cluster()
    .size([dimensions.width, 1])
    .sort(null)
    .value(function(d) { return d.length; })
    .children(function(d) { return d.branchset; })
    .separation(function(a, b) { return 1; });

var diagonal = d3.svg.diagonal().projection(function(d) { return [d.x, d.y]; });

var color_scale = d3.scale.category10();

datapointClusters = [];

function elbow(d, i) {
  return "M" + d.source.x + "," + d.source.y + "H" + d.target.x + "V" + d.target.y ;
}

var wrap = d3.select("#dendrogram").append("svg")
    .attr("width", dimensions.width)
    .attr("height", dimensions.height)
    .style("-webkit-backface-visibility", "hidden");

var vis = wrap.append("g");

// Calculates child link distance
function phylo(n, offset) {
  var multiplier = 150;
  if (n.length != null) offset += n.length * multiplier;
  // n.y = offset + 2;
  n.y = (dimensions.height - 4) - (dimensions.height * n.length) + 2;
  if (n.children) {
    n.children.forEach(function(n) {
      phylo(n, offset);
    });
  }
}

function getDatapointColour(d) {
  if (d.name != undefined && d.name.length > 0) {
    return color_scale(datapointClusters[+d.name]);
  } else {
    return "rgb(210,210,210)";
  }
}

$(".evidence_accumulation_solution").spin();

d3.text(gon.solution_path, function(text) {

  var dataDsv = d3.dsv(" ", "text/plain");
    var data = dataDsv.parseRows(text).map(function(row) {
      datapointClusters[row[datapointIndex]] = +row[clusterIndex];
      return row.map(function(value) {
        return +value;
      });
  });

  d3.text(gon.evidence_accumulation_solution_path, function(text) {

    $(".evidence_accumulation_solution").spin(false);

    newickTree = newick.parse(text);
    var nodes = cluster.nodes(newickTree);
    phylo(nodes[0], 0);

    // Create links between nodes
    var link = vis.selectAll("path.link")
        .data(cluster.links(nodes))
      .enter().append("path")
        .attr("class", "link")
        .attr("d", elbow)

    var node = vis.selectAll("g.node")
        .data(nodes.filter(function(n) { return n.x !== undefined; }))
      .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
        .append("circle")
          .attr("class", "join")
          .style("fill", function(d) {
            return getDatapointColour(d);
          })
          .attr("r", function(d) { return (d.children && 'parent' in d) ? 2 : 2; })
          .attr("data-point", function(d) { return d.name });

  });


});
