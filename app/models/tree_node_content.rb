class TreeNodeContent

  attr_accessor :datapoint, :distance, :cached_distances

  def initialize(datapoint, distance)
    @datapoint = datapoint
    @distance = distance
    @cached_distances = {}
  end

end