class Datapoint < ActiveRecord::Base
  belongs_to :clusterable, :polymorphic => true

  has_many :cluster_datapoints, :dependent => :delete_all
  has_many :clusters,           :through   => :cluster_datapoints
  has_many :datavalues,         :dependent => :delete_all

  validates :clusterable_id, presence:     true,
                             numericality: true
  validates :sequence_id,    presence:     true,
                             numericality: true

  def get_cluster(solution)
    clusters = self.clusters.where(:plottable => solution)
    puts clusters.size
    return clusters.first
  end

end
