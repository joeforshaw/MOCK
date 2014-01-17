class EvidenceAccumulationSolution < ActiveRecord::Base

  require 'matrix'

  belongs_to :run
  has_many :clusters, :dependent => :destroy

  validates :run_id, presence:     true,
                     numericality: true

  def calculate
    # no_of_solutions   = run.solutions.size
    no_of_datapoints  = self.run.dataset.datapoints.size
    similarity_matrix = Matrix.zero(no_of_datapoints)

    datapoints = self.run.dataset.datapoints

    run.solutions.each do |solution|
      datapoints.each_with_index do |datapoint, i|
        cluster_id = datapoint.get_cluster(solution).generated_cluster_id
        datapoints.each_with_index do |another_datapoint, j|
            another_cluster_id = another_datapoint.get_cluster(solution).generated_cluster_id
            if cluster_id == another_cluster_id
                similarity_matrix[i,j] += 1
            end
        end
      end    
    end

    puts similarity_matrix

  end

end
