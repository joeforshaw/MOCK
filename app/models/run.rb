class Run < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :user
  belongs_to :evidence_accumulation_solution

  has_many :solutions,         :dependent => :destroy
  has_many :control_solutions, :dependent => :destroy

  validates :runtime,    presence: true
  validates :dataset_id, presence: true
  validates :user_id,    presence: true
  validates :completed,  inclusion: { in: [true, false] }

  def objective_csv
    CSV.generate do |csv|
      self.solutions.order(:connectivity).each do |solution|
        csv << ["#{solution.id} #{solution.connectivity} #{solution.deviation}"]
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
      self.control_solutions.order(:connectivity).each do |control_solution|
        csv << ["#{control_solution.id} #{control_solution.connectivity} #{control_solution.deviation}"]
      end
    end
  end

  def execute(temp_file_name)
    puts "algo/MOCK 1 1 #{temp_file_name} #{self.dataset.rows} #{self.dataset.columns} #{self.user.id} #{self.id}"
    `algo/MOCK 1 1 #{temp_file_name} #{self.dataset.rows} #{self.dataset.columns} #{self.user.id} #{self.id}`
  end

  def get_parsing_status
    solutions_parsed = self.solutions.where(:parsed => true).size.to_f
    no_of_solutions = self.solutions.size.to_f
    percentage_parsed = ((solutions_parsed / no_of_solutions) * 100.0).to_i
    if percentage_parsed < 100
      @parsing_status = "Solution parsing #{percentage_parsed}%"
    else
      @parsing_status = "Parsing complete"
    end
  end

  def get_evidence_accumulation_status
    if self.evidence_accumulation
      if !self.parsed
        return "Evidence accumulation waiting"
      elsif !self.evidence_accumulation_solution.completed
        return "Evidence accumulation running"
      else
        return "Evidence accumulation complete"
      end
    else
      return nil
    end
  end

end
