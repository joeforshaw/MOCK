class MdsSolution < ActiveRecord::Base

  require 'mds'
  require 'mds/interfaces/gsl_interface'

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
    @solution = Solution.includes(clusters: :datapoints).find(self.solution.id)
    @clusters = @solution.clusters

    @dataset = @solution.run.dataset
    @datapoints = @dataset.datapoints.order(:sequence_id)

    # Initialise data value array
    datavalues = Array.new(@dataset.rows) { Array.new(@dataset.columns) { 0 } }
    @clusters.each do |cluster|
      cluster.datapoints.each do |datapoint|
        datapoint.datavalues.each_with_index do |datavalue, j|
          datavalues[datapoint.sequence_id - 1][j] = datavalue.value
        end
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
    puts scaled_matrix.m

    @mds_dataset = MdsDataset.create(:mds_solution => self)
    scaled_datavalues = []
    mds_cluster_datapoints = []
    @clusters.each do |cluster|
      mds_cluster = Cluster.create(:generated_cluster_id => cluster.generated_cluster_id, :plottable => self)
      cluster.datapoints.each do |datapoint|
        scaled_datapoint = Datapoint.create(:sequence_id => datapoint.sequence_id, :clusterable => @mds_dataset)
        for j in (0..1)
          scaled_datavalues << Datavalue.new(:value => scaled_matrix[datapoint.sequence_id - 1, j], :datapoint => scaled_datapoint)
          mds_cluster_datapoints << ClusterDatapoint.new(:cluster => mds_cluster, :datapoint => scaled_datapoint)
        end
      end
    end

    Datavalue.import scaled_datavalues
    ClusterDatapoint.import mds_cluster_datapoints
  end

end
