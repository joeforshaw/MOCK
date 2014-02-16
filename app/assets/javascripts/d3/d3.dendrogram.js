$(document).ready(function() {

  if (gon.is_dendrogram === null || !gon.is_dendrogram) {
    return;
  }

  dimensions = { width: 960, height: 960 };

  config = {
    clusterIndex          : 1,
    datapointIndex        : 0,
    nonValueColumns       : 2,
    hideUnanimousBranches : document.getElementById('hide-unanimous-branches').checked
  };

  cluster = d3.layout.cluster()
      .size([dimensions.width, 1])
      .sort(null)
      .value(function(d) { return d.length; })
      .children(function(d) { return d.branchset; })
      .separation(function(a, b) { return 1; });

  diagonal = d3.svg.diagonal().projection(function(d) { return [d.x, d.y]; });

  color_scale = d3.scale.category10();

  datapointClusters = [];

  wrap = d3.select("#dendrogram").append("svg")
      .attr("width", dimensions.width)
      .attr("height", dimensions.height)
      .style("-webkit-backface-visibility", "hidden");

  vis = wrap.append("g");

  $(".evidence-accumulation-solution").spin();

  if (gon.solution_path !== undefined) {
    loadSolutionDendrogram();
  } else {
    loadDendrogram();
  }

  optionHandler();

});

function loadSolutionDendrogram() {
  d3.text(gon.solution_path, function(text) {
    var dataDsv = d3.dsv(" ", "text/plain");
    var data = dataDsv.parseRows(text).map(function(row) {
      datapointClusters[row[config.datapointIndex]] = +row[config.clusterIndex];
      return row.map(function(value) { return +value; });
    });
    loadDendrogram();
  });
}

function loadDendrogram() {
  d3.text(gon.evidence_accumulation_solution_path, function(text) {

    $(".evidence-accumulation-solution").spin(false);

    var newickTree = newick.parse(text);
    var nodes = cluster.nodes(newickTree);

    setNodeHeights(nodes[0], 0);
    if (gon.solution_path !== undefined) {
      calculateDominantClusters(nodes[0]);
    }

    var link = drawLinks(nodes);
    var node = drawNodes(nodes);
  });
}

function drawLinks(nodes) {
  return vis.selectAll("path.link").data(cluster.links(nodes))
    .enter().append("path")
      .attr("class", "link")
      .attr("d", elbow)
      .style("stroke", function(d) { return getLinkColour(d); });
}

function elbow(d, i) {
  return "M" + d.source.x + "," + d.source.y + "H" + d.target.x + "V" + d.target.y ;
}

function getLinkColour(link) {
  if (!config.hideUnanimousBranches || !link.source.unanimousChildren) {
    return color_scale(link.target.dominantCluster);
  } else {
    return 'transparent';
  }
}

function drawNodes(nodes) {
  return vis.selectAll("g.node").data(nodes)
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .append("circle")
        .attr("class", "join")
        .style("fill", function(d) { return getNodeColour(d); })
        .attr("r", function(d) { return (d.children && 'parent' in d) ? 2 : 2; })
        .attr("data-point", function(d) { return d.name; })
        .attr("data-cluster", function(d) { return d.dominantCluster; })
        .attr("data-cluster-size", function(d) { return d.dominantClusterSize; })
        .attr("data-unanimous-children", function(d) { return d.unanimousChildren; });
}

function setNodeHeights(node) {
  var multiplier = 150;
  node.y = (dimensions.height - 4) - (dimensions.height * node.length) + 2;
  if (node.children) {
    node.children.forEach(function(childNode) {
      setNodeHeights(childNode);
    });
  }
}

function getNodeColour(node) {
  if (node.parent === undefined || (!node.parent.unanimousChildren || !config.hideUnanimousBranches)) {
    return color_scale(node.dominantCluster);
  } else {
    return 'transparent';
  }
}

function calculateDominantClusters(node) {
  if (node.children) {
    var dominantCluster = -1;
    var dominantClusterSize = -1;
    var unanimousChildren = true;
    node.children.forEach(function(child) {
      childDominantCluster = calculateDominantClusters(child);
      if (dominantCluster == childDominantCluster[0]) {
        dominantClusterSize += childDominantCluster[1];
      } else if (dominantClusterSize < childDominantCluster[1]) {
        dominantCluster = childDominantCluster[0];
        dominantClusterSize = childDominantCluster[1];
      }

      if (dominantCluster != -1 && dominantCluster != childDominantCluster[0] || !childDominantCluster[2]) {
        unanimousChildren = false;
      }
    });

    node.dominantCluster = dominantCluster;
    node.dominantClusterSize = 1;
    node.unanimousChildren = unanimousChildren;
    return [node.dominantCluster, node.dominantClusterSize, node.unanimousChildren];
  } else {
    node.dominantCluster = datapointClusters[+node.name];
    node.dominantClusterSize = 1;
    node.unanimousChildren = true;
    return [node.dominantCluster, node.dominantClusterSize, node.unanimousChildren];
  }
}

function optionHandler() {
  $("input#hide-unanimous-branches").change(function() {
    $(".evidence-accumulation-solution").spin();
    config.hideUnanimousBranches = document.getElementById('hide-unanimous-branches').checked;
    vis.selectAll("g.node circle").style("fill", function(d) { return getNodeColour(d); });
    vis.selectAll("path.link").style("stroke", function(d) { return getLinkColour(d); });
    $(".evidence-accumulation-solution").spin(false);
  });
}