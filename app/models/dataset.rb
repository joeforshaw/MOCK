class Dataset < ActiveRecord::Base
  belongs_to :user
  has_many :runs
  has_many :datapoints

  def to_csv
    CSV.generate do |csv|
      # csv << column_names
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
