class Solution < ActiveRecord::Base
  belongs_to :run
  has_many :clusters

  def mock_file_name
    "user.#{self.run.user.id}.method.1.run.#{self.run.id}.solution.#{self.generated_solution_id - 1}.part"
  end

  def to_csv
    CSV.generate do |csv|
      self.datapoints.order(:sequence_id).each do |datapoint|
        datapoint_string = ""
        datapoint.datavalues.each do |datavalue|
          datapoint_string << "#{datavalue.value} "
        end
        csv << [datapoint_string]
      end
    end
  end

end
