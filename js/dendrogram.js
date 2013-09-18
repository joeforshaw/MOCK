var r = 960 / 2;

var cluster = d3.layout.cluster()
    .size([1000, 1])
    .sort(null)
    .value(function(d) { return d.length; })
    .children(function(d) { return d.branchset; })
    .separation(function(a, b) { return 1; });

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.x, d.y]; });

var wrap = d3.select("#dendrogram").append("svg")
    .attr("width", r * 3)
    .attr("height", r * 2 + 50)
    .style("-webkit-backface-visibility", "hidden");

var vis = wrap.append("g");

// Calculates child link distance
function phylo(n, offset) {
  var multiplier = 270;
  if (n.length != null) offset += n.length * multiplier;
  n.y = offset;
  if (n.children) {
    n.children.forEach(function(n) {
      phylo(n, offset);
    });
  } else {
    n.y = 2.5 * multiplier;
  }
}

d3.text("life.txt", function(text) {
  var x = newick.parse(text);
  var nodes = cluster.nodes(x);
  phylo(nodes[0], 0);

  // Create links between nodes
  var link = vis.selectAll("path.link")
      .data(cluster.links(nodes))
    .enter().append("path")
      .attr("class", "link")
      .attr("d", diagonal);

  var node = vis.selectAll("g.node")
      .data(nodes.filter(function(n) { return n.x !== undefined; }))
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      // .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })

  node.append("circle")
      .attr("r", 2.5);

  // var label = vis.selectAll("text")
  //     .data(nodes.filter(function(d) { return d.x !== undefined && !d.children; }))
  //   .enter().append("text")
  //     .attr("dy", ".31em")
  //     .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
  //     .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
  //     // .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + (r - 170 + 8) + ")rotate(" + (d.x < 180 ? 0 : 180) + ")"; })
  //     .text(function(d) { return d.name.replace(/_/g, ' '); });
});
