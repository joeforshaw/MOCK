class Dataset < ActiveRecord::Base
  belongs_to :user
  has_many :runs, :dependent => :destroy
  has_many :datapoints, :dependent => :destroy

  def to_csv
    CSV.generate do |csv|
      self.datapoints.each do |datapoint|
        datapoint_string = ""
        datapoint.datavalues.each do |datavalue|
          datapoint_string << "#{datavalue.value} "
        end
        csv << [datapoint_string]
      end
    end
  end

end
