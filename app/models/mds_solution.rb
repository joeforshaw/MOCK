class MdsSolution < ActiveRecord::Base

  require 'mds'
  require 'mds/interfaces/stdlib_interface'

  belongs_to :solution
  has_many :clusters, :as => :plottable, :dependent => :destroy

  has_one :mds_dataset

  def to_csv
    CSV.generate do |csv|
      self.clusters.each do |cluster|
        cluster.datapoints.order(:sequence_id).each do |datapoint|
          datavalues = []
          datavalues << datapoint.id
          datavalues << cluster.generated_cluster_id
          datapoint.datavalues.order(:id).each do |datavalue|
            datavalues << datavalue.value
          end
          csv << [datavalues.join(" ")]
        end
      end
    end
  end

  def calculate
    @dataset = self.mds_dataset

    # Initialise data value array
    datavalues = Array.new(@dataset.rows) { Array.new(@dataset.columns) { 0 } }
    @dataset.datapoints.order(:sequence_id).each_with_index do |datapoint, i|
      datapoint.datavalues.each_with_index do |datavalue, j|
        datavalues[i][j] = datavalue.value
      end
    end

    # Populate distance matrix
    distance = Array.new(@dataset.rows) { Array.new(@dataset.columns) { 0 } }
    for i in 0..(@dataset.rows-1)
      for j in 0..(@dataset.rows-1)
        distance[i][j] = Math.sqrt(datavalues[i].zip(datavalues[j]).map { |x| (x[1] - x[0])**2 }.reduce(:+))
      end
    end

    puts datavalues.size
    puts
    puts distance.size

    # Tell RMDS the linear algebra backend to be used.
    MDS::Backend.active = MDS::StdlibInterface

    # The squared Euclidean distance matrix.
    d2 = MDS::Matrix.create_rows(*distance)

    # Find a Cartesian embedding in two dimensions
    # that approximates the distances in two dimensions.
    scaled_matrix = MDS::Metric.projectd(d2, 2).m
    puts scaled_matrix
  end

end
