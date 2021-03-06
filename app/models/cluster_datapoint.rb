class ClusterDatapoint < ActiveRecord::Base
  belongs_to :cluster, :autosave => true
  belongs_to :datapoint

  validates :cluster_id,   presence:     true,
                           numericality: true
  validates :datapoint_id, presence:     true,
                           numericality: true

end
