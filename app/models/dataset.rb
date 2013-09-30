class Dataset < ActiveRecord::Base

  belongs_to :user
  has_many   :runs
  has_many   :datapoints

end
