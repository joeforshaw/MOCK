class Dataset < ActiveRecord::Base

  belongs_to :user

  has_many :runs,       :dependent => :destroy
  has_many :datapoints, :dependent => :destroy

  validates :name,    presence:     true
  validates :user_id, presence:     true,
                      numericality: true
  validates :columns, numericality: true
  validates :rows,    numericality: true

  def to_csv
    CSV.generate do |csv|
      self.datapoints.order(:sequence_id).each do |datapoint|
        datavalues = []
        datapoint.datavalues.order(:id).each do |datavalue|
          datavalues << datavalue.value
        end
        csv << [datavalues.join(" ")]
      end
    end
  end

end
