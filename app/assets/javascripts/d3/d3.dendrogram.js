var dimensions = { width: 960, height: 960 };

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
  var multiplier = 150;
  if (n.length != null) offset += n.length * multiplier;
  n.y = offset + 2;
  if (n.children) {
    n.children.forEach(function(n) {
      phylo(n, offset);
    });
  }
}

function fixLeafPositions(nodes) {
  var lowestY = 0;
  nodes.forEach(function(n) {
    if (n.y > lowestY) {
      lowestY = n.y
    }
  });
  nodes.forEach(function(n) {
    if (!n.children) {
      n.y = lowestY
    }
  })
}

// function colourChildren(node) {
//   console.log(node);
//   d3.select(node).style("stroke", "red");
//   if (node.target.children) {
//     node.target.children.forEach(function(child) {
//       colourChildren(child);
//     });
//   }
// }

$(".evidence_accumulation_solution").spin();

d3.text(gon.evidence_accumulation_solution_path, function(text) {

  $(".evidence_accumulation_solution").spin(false);

  var x = newick.parse(text);
  var nodes = cluster.nodes(x);
  phylo(nodes[0], 0);

  fixLeafPositions(nodes)

  // Create links between nodes
  var link = vis.selectAll("path.link")
      .data(cluster.links(nodes))
    .enter().append("path")
      .attr("class", "link")
      .attr("d", elbow)
      // .on("mouseover", function(node) {
      //   d3.select(this).style("stroke", "red");
      //   colourChildren(node);
      // })

  var node = vis.selectAll("g.node")
      .data(nodes.filter(function(n) { return n.x !== undefined; }))
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .append("circle")
        .attr("class", "join")
        .attr("r", function(d) { return (d.children && 'parent' in d) ? 0 : 2; });

});
