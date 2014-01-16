class EvidenceAccumulationSolution < ActiveRecord::Base

  belongs_to :run
  has_many :clusters, :dependent => :destroy

  validates :run_id, presence:     true,
                     numericality: true

  def create

  end

end
