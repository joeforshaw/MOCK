$(document).ready(function() {

  if (window.gon === undefined || gon.is_dendrogram === null || !gon.is_dendrogram) {
    return;
  }

  $(".evidence-accumulation-solution").spin();

  initialiseVariables();

  if (gon.solution_path !== undefined) {
    loadSolutionDendrogram();
  } else {
    loadDendrogram();
  }

  optionHandler();
  cutButtonHandler();
});

function initialiseVariables() {
  dimensions = { width: 960, height: 720 };

  horizontalPadding = ($(window).width() - dimensions.width) / 2;

  margin = {top: 30, right: horizontalPadding, bottom: 30, left: horizontalPadding},

  config = {
    clusterIndex          : 1,
    datapointIndex        : 0,
    nonValueColumns       : 2,
    hideUnanimousBranches : $('hide-unanimous-branches').length > 0 ? document.getElementById('hide-unanimous-branches').checked : false,
    cutting               : false
  };

  y = d3.scale.linear().range([dimensions.height, 0]);
  y.domain([100,0]).nice();

  yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

  cluster = d3.layout.cluster()
      .size([dimensions.width, 1])
      .sort(null)
      .value(function(d) { return d.length; })
      .children(function(d) { return d.branchset; })
      .separation(function(a, b) { return 1; });

  diagonal = d3.svg.diagonal().projection(function(d) { return [d.x, d.y]; });

  color_scale = d3.scale.category20();

  // Fix cluster ids to colours
  if (gon.is_solution !== undefined && gon.is_solution) {
      for (var i = 0; i < gon.number_of_clusters; i++) {
          color_scale(i);
      }
  }

  datapointClusters = [];

  wrap = d3.select("#dendrogram").append("svg")
      .attr("width", $(window).width())
      .attr("height", dimensions.height + margin.top + margin.bottom)
      .style("-webkit-backface-visibility", "hidden")
      .on("mousemove", moveCut)
      .on("mousedown", calculateCut)


  vis = wrap.append("g")
          .attr("transform", "translate(" + margin.left + ", " + margin.top + ")");

  cutLine = vis.append("line")
      .attr("class", "cut-line");

  cutText = vis.append("text")
      .attr("class", "cut-text");
}

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

    vis.append("g")
        .attr("class", "y-axis axis")
        .call(yAxis)
        .append("text")
          .attr("class", "graph-label")
          .attr("x", 50 + dimensions.height / -2)
          .attr("y", -50)
          .attr("transform", "rotate(-90)")
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text("Co-assignment (%)");

    $(".evidence-accumulation-solution").spin(false);

    var newickTree = newick.parse(text);
    var nodes = cluster.nodes(newickTree);

    allNodes = nodes;

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
  return "M" + d.source.x + "," + d.source.y
       + "H" + d.target.x
       + "V" + d.target.y;
}

function getLinkColour(link) {
  if (!config.hideUnanimousBranches || !link.source.unanimousChildren) {
    return color_scale(link.target.dominantCluster);
  } else {
    return 'transparent';
  }
}

function drawNodes(nodes) {
  var nodes_to_draw = vis.selectAll("g.node").data(nodes)
    .enter().append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .append("circle")
        .style("fill",                   function(d) { return getNodeColour(d); })
        .attr("class",                   function(d) { return isUnanimous(d) ?  "join unanimous-leaf" : "join"; })
        .attr("r",                       function(d) { return (d.children && 'parent' in d) ? 2 : 2; })
        .attr("data-point",              function(d) { return d.name; })
        .attr("data-cluster",            function(d) { return d.dominantCluster; })
        .attr("data-cluster-size",       function(d) { return d.dominantClusterSize; })
        .attr("data-unanimous-children", function(d) { return d.unanimousChildren; })
        .attr("original-title",          function(d) { config.hideUnanimousBranches ? "Test" : 0 });

  $('.unanimous-leaf').tipsy({ fade: true, gravity: 's', offset: 1, offsetX: 3 });

  return nodes_to_draw;
}

function isUnanimous(node) {
  return node.parent !== undefined
     && !node.parent.unanimousChildren
     &&  node.unanimousChildren;
}

function setNodeHeights(node) {
  var multiplier = 150;
  var height = dimensions.height - ((dimensions.height * node.length));
  if (height >= dimensions.height) {
    height = dimensions.height - 2;
  } else if (height <= 0 || node.parent === undefined) {
    height = 2;
  }
  node.y = height;
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
    var dominantClusterSize = 0;
    var unanimousChildren = true;
    var child = [null, null];

    child[0] = calculateDominantClusters(node.children[0]);
    child[1] = calculateDominantClusters(node.children[1]);

    if (child[0].dominantCluster === child[1].dominantCluster) {
      node.dominantCluster     = child[0].dominantCluster;
      node.dominantClusterSize = child[0].dominantClusterSize + child[1].dominantClusterSize;
      node.unanimousChildren   = child[0].unanimousChildren && child[1].unanimousChildren;
    } else if (child[0].dominantClusterSize >= child[1].dominantClusterSize) {
      node.dominantCluster     = child[0].dominantCluster;
      node.dominantClusterSize = child[0].dominantClusterSize;
      node.unanimousChildren   = false;
    } else {
      node.dominantCluster     = child[1].dominantCluster;
      node.dominantClusterSize = child[1].dominantClusterSize;
      node.unanimousChildren   = false;
    }
  } else {
    node.dominantCluster     = datapointClusters[+node.name];
    node.dominantClusterSize = 1;
    node.unanimousChildren   = true;
  }
  return {
    dominantCluster     : node.dominantCluster,
    dominantClusterSize : node.dominantClusterSize,
    unanimousChildren   : node.unanimousChildren
  };
}

function optionHandler() {
  $("input#hide_unanimous_branches").change(function() {
    config.hideUnanimousBranches = document.getElementById('hide_unanimous_branches').checked;
    redrawDendrogram();
    vis.selectAll('.unanimous-leaf')
      .attr("original-title", function(d) { return getTipsyMessage(d); })
      .style("cursor", config.hideUnanimousBranches ? "pointer" : "default");
  });
}

function redrawDendrogram() {
  $(".evidence-accumulation-solution").spin();
  vis.selectAll("g.node circle").style("fill", function(d) { return getNodeColour(d); });
  vis.selectAll("path.link").style("stroke", function(d) { return getLinkColour(d); });
  $(".evidence-accumulation-solution").spin(false);
}

function getTipsyMessage(node) {
  if (config.hideUnanimousBranches) {
    if (node.children === undefined) {
      return "A datapoint";
    } else {
      return "Number of datapoints: " + node.dominantClusterSize;
    }
  } else {
    return "";
  }
}

// Dedrogram cut code

function cutButtonHandler() {
  $("#cut_dendrogram").click(function(e) {
    config.cutting = !config.cutting;
    if (config.cutting) {
      startCutting();
    } else {
      stopCutting();
    }
  });

  $(document).keyup(function(e) {
    if (e.keyCode == 27) { stopCutting(); }
  });
}

function moveCut() {
  if (config.cutting) {
    var m = d3.mouse(this);
    var distance = calculateDistance(m[1]);
    cutLine
      .attr("x1", 0)
      .attr("y1", m[1] - margin.top)
      .attr("x2", dimensions.width)
      .attr("y2", m[1] - margin.top);
    cutText
      .text(((1 - distance) * 100).toFixed(0) + " %")
      .attr("dx", m[0] + 20 - horizontalPadding)
      .attr("dy", m[1] + 20 - margin.top);
  }
}

function calculateCut(distance) {
  if (config.cutting) {
    stopCutting();
    var mousePos = d3.mouse(this);
    var clusterID = 0;
    allNodes.forEach(function(node) {
      if (isRootClusterNode(node, mousePos[1])) {
        addClusterToDatapoints(node, clusterID++);
      }
    });
    calculateDominantClusters(allNodes[0]);
    redrawDendrogram();
  }
}

function isRootClusterNode(node, yMousePosition) {
  var distance = calculateDistance(yMousePosition);
  return node.length <= distance
      && (node.parent !== undefined && node.parent.length > distance
      ||  node.parent === undefined && distance === 1);
}

function addClusterToDatapoints(node, clusterID) {
  if (node.children !== undefined) {
    node.children.forEach(function(child) {
      addClusterToDatapoints(child, clusterID);
    });
  } else {
    datapointClusters[+node.name] = clusterID;
  }
}

function calculateDistance(yPosition) {
  var distance = (1 - (yPosition - margin.top) / dimensions.height);
  if (distance > 1) return 1;
  if (distance < 0) return 0;
  return distance;
}

function startCutting() {
  $button = $("#cut_dendrogram");
  $button.removeClass("orange-button");
  $button.addClass("purple-button");
  $("svg").css("cursor", "pointer");
}

function stopCutting() {
  config.cutting = !config.cutting;
  $button = $("#cut_dendrogram");
  $button.removeClass("purple-button");
  $button.addClass("orange-button");
  $("svg").css("cursor", "default");
  cutLine
    .attr("x1", 0)
    .attr("y1", -100)
    .attr("x2", dimensions.width)
    .attr("y2", -100);
  cutText
    .attr("dx", -100)
    .attr("dy", -100);
}
