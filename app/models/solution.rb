class Solution < ActiveRecord::Base
  belongs_to :run
  has_many :clusters, :dependent => :destroy

  def mock_file_name
    "user.#{self.run.user.id}.method.1.run.#{self.run.id}.solution.#{self.generated_solution_id - 1}.part"
  end

  def to_csv
    CSV.generate do |csv|
      self.clusters.each do |cluster|
        cluster.datapoints.order(:sequence_id).each do |datapoint|
          datavalues = []
          datapoint.datavalues.order(:id).each do |datavalue|
            datavalues << datavalue.value
          end
          datavalues << cluster.generated_cluster_id
          csv << [datavalues.join(" ")]
        end
      end
    end
  end

end
