class Cluster < ActiveRecord::Base
  belongs_to :solution
  has_many :cluster_datapoints
  has_many :datapoints, :through => :cluster_datapoints
end
