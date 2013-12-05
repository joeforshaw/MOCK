class ControlSolution < ActiveRecord::Base
  
  belongs_to :run

  validates :run_id,       presence:     true,
                           numericality: true
  validates :connectivity, presence:     true,
                           numericality: true
  validates :deviation,    presence:     true,
                           numericality: true

end
