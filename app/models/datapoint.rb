class Datapoint < ActiveRecord::Base

  belongs_to :dataset
  belongs_to :cluster
  has_many   :datavalues

end
