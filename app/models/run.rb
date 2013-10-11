class Run < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :user
  has_many :solutions
  has_many :control_solutions

  def control_file_name
    "user.#{self.user.id}.method.1.run.#{self.id}.control.pf"
  end

end
