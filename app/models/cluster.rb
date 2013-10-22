class Cluster < ActiveRecord::Base
  belongs_to :solution
  has_many :cluster_datapoints, :dependent => :destroy
  has_many :datapoints, :through => :cluster_datapoints, :dependent => :destroy
end
