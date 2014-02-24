class Cluster < ActiveRecord::Base
  belongs_to :plottable, :polymorphic => true

  has_many :cluster_datapoints, :dependent => :delete_all
  has_many :datapoints,         :through   => :cluster_datapoints

  validates :plottable_id, presence:     true,
                           numericality: true

end
