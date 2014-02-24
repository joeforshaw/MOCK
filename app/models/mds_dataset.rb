class MdsDataset < ActiveRecord::Base

  belongs_to :solution
  has_many :datapoints, :as => :clusterable, :dependent => :destroy

end
