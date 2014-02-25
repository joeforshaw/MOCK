class MdsDataset < ActiveRecord::Base

  belongs_to :mds_solution
  has_many :datapoints, :as => :clusterable, :dependent => :destroy

end
