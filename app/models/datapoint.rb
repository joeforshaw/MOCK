class Datapoint < ActiveRecord::Base
  belongs_to :dataset

  has_many :cluster_datapoints, :dependent => :destroy
  has_many :clusters,           :through   => :cluster_datapoints,
                                :dependent => :destroy
  has_many :datavalues,         :dependent => :destroy

  validates :dataset_id,  presence:     true,
                          numericality: true
  validates :sequence_id, presence:     true,
                          numericality: true

end
