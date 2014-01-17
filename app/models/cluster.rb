class Cluster < ActiveRecord::Base
  belongs_to :solution

  has_many :cluster_datapoints, :dependent => :delete_all
  has_many :datapoints,         :through   => :cluster_datapoints

  validates :solution_id, presence:     true,
                          numericality: true

end
