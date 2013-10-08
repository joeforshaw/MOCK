class Datapoint < ActiveRecord::Base
  belongs_to :dataset, dependent: :destroy
  has_many :cluster_datapoints
  has_many :clusters, :through => :cluster_datapoints
  has_many :datavalues
end
