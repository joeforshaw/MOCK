class Solution < ActiveRecord::Base
  belongs_to :run
  has_many :clusters

  def mock_file_name
    "user.#{self.run.user.id}.method.1.run.#{self.run.id}.solution.#{self.generated_solution_id - 1}.part"
  end

end
