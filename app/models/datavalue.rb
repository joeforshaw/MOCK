class Datavalue < ActiveRecord::Base
  belongs_to :datapoint

  validates :datapoint_id, presence:     true,
                           numericality: true
  validates :value,        presence:     true,
                           numericality: true
end
