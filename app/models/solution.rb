class Solution < ActiveRecord::Base
  belongs_to :run
  has_many :clusters, :dependent => :destroy

  def mock_file_name
    "user.#{self.run.user.id}.method.1.run.#{self.run.id}.solution.#{self.generated_solution_id - 1}.part"
  end

  def to_csv
    CSV.generate do |csv|
      self.clusters.each do |cluster|
        cluster.datapoints.each do |datapoint|
          datapoint_string = ""
          datapoint.datavalues.each do |datavalue|
            datapoint_string << "#{datavalue.value} "
          end
          datapoint_string << "#{cluster.generated_cluster_id}"
          csv << [datapoint_string]
        end
      end
    end
  end

end
