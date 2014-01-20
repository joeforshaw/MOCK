class Newick
  
  def self.format(agglom_node)
    node_string = "#{format_children(agglom_node)}#{format_node(agglom_node)}"
    if agglom_node.root?
      return "#{node_string};"
    else
      return node_string
    end
  end

  def self.format_node(agglom_node)
    format_string = ""
    if !agglom_node.datapoint.nil?
      format_string = "#{format_string}#{agglom_node.datapoint.id}"
    end
    
    if !agglom_node.distance.nil?
      format_string = "#{format_string}:#{agglom_node.distance}"
    end
    return format_string
  end

  def self.format_children(agglom_node)
    children_tokens = []
    agglom_node.children.each do |child_node|
      children_tokens << format(child_node)
    end
    if children_tokens.empty?
      return ""
    else
      return "(#{children_tokens.join(",")})"
    end
  end

end