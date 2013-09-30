class ClusterDatapoint < ActiveRecord::Base
  belongs_to :cluster
  belongs_to :datapoint
end
