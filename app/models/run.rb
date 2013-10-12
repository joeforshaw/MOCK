class Run < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :user
  has_many :solutions
  has_many :control_solutions

  def objective_csv
    CSV.generate do |csv|
      self.solutions.each do |solution|
        csv << ["#{solution.connectivity} #{solution.deviation}"]
      end
    end
  end

  def objective_file_name
    "user.#{self.user.id}.method.1.run.#{self.id}.pf"
  end

  def control_file_name
    "user.#{self.user.id}.method.1.run.#{self.id}.control.pf"
  end

  def control_solution_csv
    CSV.generate do |csv|
      self.control_solutions.each do |control_solution|
        csv << ["#{control_solution.connectivity} #{control_solution.deviation}"]
      end
    end
  end

end
