class Solution < ActiveRecord::Base

  require 'mds'
  require 'mds/interfaces/stdlib_interface'

  belongs_to :run

  has_many :clusters, :dependent => :destroy

  validates :run_id,                presence:     true,
                                    numericality: true
  validates :generated_solution_id, presence:     true,
                                    numericality: true
  validates :connectivity,          presence:     true,
                                    numericality: true
  validates :deviation,             presence:     true,
                                    numericality: true

  def file_dir
    "algo/data/user.#{self.run.user.id}.method.1.run.#{self.run.id}.solution.#{self.generated_solution_id - 1}.part"
  end

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

  def save_data_file
    if File.exist?(self.file_dir)
      clusters = []
      cluster_datapoints = []

      # Create clusters
      File.open(self.file_dir, "r+") do |file|

        # Collect cluster ids from files
        generated_cluster_ids = Set.new
        CSV.foreach(file) do |line|
          generated_cluster_ids.add(line.first.split(' ').last.to_i)
        end

        # Create Cluster records
        generated_cluster_ids.each do |generated_cluster_id|
          clusters << Cluster.new(:solution_id => self.id, :generated_cluster_id => generated_cluster_id)
        end

      end

      Cluster.import clusters

      clusters_for_solution = Cluster.where(:solution_id => self.id)
      File.open(self.file_dir, "r+") do |file|
        datapoints = self.run.dataset.datapoints
        datapoints.each do |datapoint|
          generated_cluster_id = file.readline.split(' ').last.to_i
          cluster = clusters_for_solution.where(:generated_cluster_id => generated_cluster_id).first
          cluster_datapoints << ClusterDatapoint.new(:cluster_id => cluster.id, :datapoint_id => datapoint.id)
        end
      end

      ClusterDatapoint.import cluster_datapoints

      File.delete(self.file_dir)

      self.update_attributes(:parsed => true)
    end
  end

  def mds
    @dataset = self.run.dataset

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
    return MDS::Metric.projectd(d2, 2).m
  end

end
