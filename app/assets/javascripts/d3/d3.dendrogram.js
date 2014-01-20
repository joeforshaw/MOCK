var dimensions = { width: 1000, height: 2000 };

var cluster = d3.layout.cluster()
    .size([dimensions.width, 1])
    .sort(null)
    .value(function(d) { return d.length; })
    .children(function(d) { return d.branchset; })
    .separation(function(a, b) { return 1; });

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.x, d.y]; });

function elbow(d, i) {
  return "M" + d.source.x + "," + d.source.y
      + "H" + d.target.x + "V" + d.target.y ;
}

var wrap = d3.select("#dendrogram").append("svg")
    .attr("width", dimensions.width)
    .attr("height", dimensions.height)
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
    n.y = 5.7 * multiplier;
  }
}

// function phylo(n, offset) {
//   if (n.length != null) offset += n.length * 230;
//   n.y = offset;
//   if (n.children)
//     n.children.forEach(function(n) {
//       phylo(n, offset);
//     });
// }

d3.text(gon.evidence_accumulation_solution_path, function(text) {
  var x = newick.parse(text);
  var nodes = cluster.nodes(x);
  phylo(nodes[0], 0);

  // Create links between nodes
  var link = vis.selectAll("path.link")
      .data(cluster.links(nodes))
    .enter().append("path")
      .attr("class", "link")
      .attr("d", elbow);

  var node = vis.selectAll("g.node")
      .data(nodes.filter(function(n) { return n.x !== undefined; }))
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .append("circle")
        .attr("class", "join")
        .attr("r", function(d) { return ('children' in d) ? 0 : 2 });

  // console.log(nodes[5].children == undefined)

  // var label = vis.selectAll("text")
  //     .data(nodes.filter(function(d) { return d.x !== undefined && !d.children; }))
  //   .enter().append("text")
  //     .attr("dy", ".31em")
  //     .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
  //     .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
  //     // .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + (r - 170 + 8) + ")rotate(" + (d.x < 180 ? 0 : 180) + ")"; })
  //     .text(function(d) { return d.name.replace(/_/g, ' '); });

});
