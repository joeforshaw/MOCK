class EvidenceAccumulationSolution < ActiveRecord::Base

  require 'matrix'

  belongs_to :run

  validates :run_id, presence:     true,
                     numericality: true

  def calculate_similarity_matrix
    no_of_datapoints  = self.run.dataset.datapoints.size
    similarity_matrix = Matrix.zero(no_of_datapoints)

    datapoints = self.run.dataset.datapoints
    datapoints_size = datapoints.size

    summed_matrix = Array.new(datapoints_size) {Array.new(datapoints_size, 0)}
    self.run.solutions.each do |solution|

      solution_matrix = solution.get_similarity_matrix
      for i in (0..datapoints_size - 1)
      	for j in (0..datapoints_size - 1)
      	  summed_matrix[i][j] += solution_matrix[i][j]
      	end
      end

    end

    puts summed_matrix

  end

end
