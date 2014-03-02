class MdsDataset < ActiveRecord::Base

  belongs_to :dataset
  has_many :datapoints, :as => :clusterable, :dependent => :destroy

  def to_csv
    CSV.generate do |csv|
      self.datapoints.order(:sequence_id).each do |datapoint|
        datavalues = []
        datavalues << datapoint.id
        datapoint.datavalues.order(:id).each do |datavalue|
          datavalues << datavalue.value
        end
        csv << [datavalues.join(" ")]
      end
    end
  end

  def calculate
    @dataset = self.dataset
    @datapoints = @dataset.datapoints.order(:sequence_id)

    # Initialise data value array
    datavalues = Array.new(@dataset.rows) { Array.new(@dataset.columns) { 0 } }
    @datapoints.each do |datapoint|
      datapoint.datavalues.each_with_index do |datavalue, j|
        datavalues[datapoint.sequence_id - 1][j] = datavalue.value
      end
    end

    # Populate distance matrix
    distance = Array.new(@dataset.rows) { Array.new(@dataset.columns) { 0 } }
    for i in 0..(@dataset.rows-1)
      for j in 0..(@dataset.rows-1)
        distance[i][j] = Math.sqrt(datavalues[i].zip(datavalues[j]).map { |x| (x[1] - x[0])**2 }.reduce(:+))
      end
    end

    # Tell RMDS the linear algebra backend to be used.
    MDS::Backend.active = MDS::GSLInterface

    # The squared Euclidean distance matrix.
    d2 = MDS::Matrix.create_rows(*distance)

    # Find a Cartesian embedding in two dimensions
    # that approximates the distances in two dimensions.
    scaled_matrix = MDS::Metric.projectd(d2, 2)

    scaled_datavalues = []
    for i in (0..@datapoints.count-1)
      scaled_datapoint = Datapoint.create(:sequence_id => i + 1, :clusterable => self)
      for j in (0..1)
        scaled_datavalues << Datavalue.new(:value => scaled_matrix[i, j], :datapoint => scaled_datapoint)
      end
    end
    Datavalue.import scaled_datavalues
  end

end
