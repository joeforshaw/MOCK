class EvidenceAccumulationSolution < ActiveRecord::Base

  require 'tree'

  belongs_to :run

  has_one :agglom_node, :dependent => :destroy

  validates :run_id, presence:     true,
                     numericality: true

  def newick_format_path
    return "/evidence_accumulation_solution/#{self.id}.newick"
  end

  def execute
    dissimilarity_matrix = self.calculate_dissimilarity_matrix
    root_node = self.hierarchical_clustering(dissimilarity_matrix)
    root_agglom_node = save_tree(root_node, nil)
  end

  def calculate_dissimilarity_matrix
    no_of_solutions  = self.run.solutions.size
    no_of_datapoints = self.run.dataset.datapoints.size

    dissimilarity_matrix = Array.new(no_of_datapoints) {Array.new(no_of_datapoints, 0.0)}
    
    self.run.solutions.each do |solution|
      solution.clusters.each do |cluster|
        cluster_datapoints = cluster.datapoints
        cluster_datapoints_size = cluster_datapoints.size
        for i in (0..cluster_datapoints_size - 1)
          for j in (0..cluster_datapoints_size - 1)
            i_datapoint_index = cluster_datapoints[i].sequence_id - 1
            j_datapoint_index = cluster_datapoints[j].sequence_id - 1
            dissimilarity_matrix[i_datapoint_index][j_datapoint_index] += 1
          end
        end
      end
    end

    for i in (0..no_of_datapoints - 1)
      for j in (0..no_of_datapoints - 1)
        dissimilarity_matrix[i][j] = 1 - (dissimilarity_matrix[i][j] / no_of_solutions)
      end
    end

    self.update_attributes(:completed => true)
    return dissimilarity_matrix
  end

  def hierarchical_clustering(dissimilarity_matrix)
    tree_nodes = []
    node_id = 1

    # Put each datapoint into a cluster
    self.run.dataset.datapoints.each do |datapoint|
      tree_nodes << Tree::TreeNode.new(node_id.to_s, TreeNodeContent.new(datapoint,nil))
      node_id += 1
    end

    
    while tree_nodes.size > 1
      smallest_distance = 2.0
      closest_nodes = [nil, nil]
      tree_nodes.each do |node|
        tree_nodes.each do |other_node|
          if node.name != other_node.name
            distance = average_link_distance(node, other_node, dissimilarity_matrix)
            if distance < smallest_distance
              smallest_distance = distance
              closest_nodes = [node, other_node]
            end
          end
        end
      end

      puts ""
      puts "Number of Nodes: #{tree_nodes.size}"
      puts "Smallest distance: #{smallest_distance}"
      puts "Closest nodes: #{closest_nodes[0].name}, #{closest_nodes[1].name}"
      puts ""

      # Create a new cluster with the two closest clusters as it's children
      parent_node = Tree::TreeNode.new(node_id.to_s, TreeNodeContent.new(nil, nil))
      node_id += 1

      for i in (0..1)
        closest_nodes[i].content.distance = smallest_distance
        parent_node << closest_nodes[i]
      end

      tree_nodes << parent_node
      tree_nodes = tree_nodes - closest_nodes
    end
    return tree_nodes[0]
  end


  def average_link_distance(node, other_node, dissimiliarity_matrix)
    no_of_datapoint_pairs = 0.0
    total_distance = 0.0
    node.each_leaf do |node|
      other_node.each_leaf do |other_node|
        no_of_datapoint_pairs += 1
        total_distance += dissimiliarity_matrix[node.content.datapoint.sequence_id - 1][other_node.content.datapoint.sequence_id - 1]
      end
    end
    return total_distance / no_of_datapoint_pairs
  end


  def complete_link_distance(node, other_node, dissimiliarity_matrix)
    max_distance = -1.0
    node.each_leaf do |node|
      other_node.each_leaf do |other_node|
        if dissimiliarity_matrix[node.content.sequence_id - 1][other_node.content.sequence_id - 1] > max_distance
          max_distance = dissimiliarity_matrix[node.content.sequence_id - 1][other_node.content.sequence_id - 1]
        end
      end
    end
    return max_distance
  end

  def save_tree(node, parent_agglom_node)
    agglom_node = AgglomNode.new
    if node.is_root?
      agglom_node.evidence_accumulation_solution = self
    end
    if node.is_leaf?
      agglom_node.datapoint = node.content.datapoint
    end
    agglom_node.parent = parent_agglom_node
    agglom_node.distance = node.content.distance
    agglom_node.save

    node.children do |child_node|
      save_tree(child_node, agglom_node)
    end
    return agglom_node
  end

end
