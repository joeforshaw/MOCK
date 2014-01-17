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

  def completed?
    self.completed
  end

  def execute(temp_file_name)
    puts "algo/MOCK 1 1 #{temp_file_name} #{self.dataset.rows} #{self.dataset.columns} #{self.user.id} #{self.id}"
    `algo/MOCK 1 1 #{temp_file_name} #{self.dataset.rows} #{self.dataset.columns} #{self.user.id} #{self.id}`
  end

end
