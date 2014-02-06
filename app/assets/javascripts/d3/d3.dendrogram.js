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

var datapointClusters = [];

function elbow(d, i) {
  return "M" + d.source.x + "," + d.source.y + "H" + d.target.x + "V" + d.target.y ;
}

var wrap = d3.select("#dendrogram").append("svg")
    .attr("width", dimensions.width)
    .attr("height", dimensions.height)
    .style("-webkit-backface-visibility", "hidden");

var vis = wrap.append("g");

$(".evidence-accumulation-solution").spin();

d3.text(gon.solution_path, function(text) {

  var dataDsv = d3.dsv(" ", "text/plain");
    var data = dataDsv.parseRows(text).map(function(row) {
      datapointClusters[row[datapointIndex]] = +row[clusterIndex];
      return row.map(function(value) {
        return +value;
      });
  });

  d3.text(gon.evidence_accumulation_solution_path, function(text) {

    $(".evidence-accumulation-solution").spin(false);

    newickTree = newick.parse(text);
    var nodes = cluster.nodes(newickTree);

    dendrogram(nodes[0], 0);

    calculateDominantClusters(nodes[0]);

    // Create links between nodes
    var link = vis.selectAll("path.link")
        .data(cluster.links(nodes))
      .enter().append("path")
        .attr("class", "link")
        .attr("d", elbow)
        .style("stroke", function(d) { return color_scale(d.target.dominantCluster); });


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
          .attr("r", function(d) { return (d.children && 'parent' in d) ? 0 : 2; })
          .attr("data-point", function(d) { return d.name });

  });

});

function dendrogram(node) {
  var multiplier = 150;
  node.y = (dimensions.height - 4) - (dimensions.height * node.length) + 2;
  if (node.children) {
    node.children.forEach(function(childNode) {
      dendrogram(childNode);
    });
  }
}

function getDatapointColour(node) {
  return color_scale(node.dominantCluster);
}

function calculateDominantClusters(node) {
  if (node.children) {
    leftDominantCluster = calculateDominantClusters(node.children[0]);
    rightDominantCluster = calculateDominantClusters(node.children[1]);
    if (leftDominantCluster[0] === rightDominantCluster[0]) {
      node.dominantCluster = leftDominantCluster[0];
      return [leftDominantCluster[0], leftDominantCluster[1] + rightDominantCluster[1]];
    } else if (leftDominantCluster[1] > rightDominantCluster[1]) {
      node.dominantCluster = leftDominantCluster[0];
      return [leftDominantCluster[0], leftDominantCluster[1]];
    } else {
      node.dominantCluster = rightDominantCluster[0];
      return [rightDominantCluster[0], rightDominantCluster[1]];
    }
  } else {
    node.dominantCluster = datapointClusters[+node.name];
    console.log(node.name, node.dominantCluster);
    return [datapointClusters[+node.name], 1];
  }
}
