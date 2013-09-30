class Cluster < ActiveRecord::Base

  belongs_to :solution
  has_many   :datapoints

end
