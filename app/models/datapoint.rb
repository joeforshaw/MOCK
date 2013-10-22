class Datapoint < ActiveRecord::Base
  belongs_to :dataset
  has_many :cluster_datapoints, :dependent => :destroy
  has_many :clusters, :through => :cluster_datapoints, :dependent => :destroy
  has_many :datavalues, :dependent => :destroy
end
