class Solution < ActiveRecord::Base

  belongs_to :run

  has_many :clusters, :as => :plottable, :dependent => :destroy

  has_one :mds_solution, :dependent => :destroy

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
          clusters << Cluster.new(:plottable => self, :generated_cluster_id => generated_cluster_id)
        end

      end

      Cluster.import clusters

      clusters_for_solution = Cluster.where(:plottable => self)
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

end
