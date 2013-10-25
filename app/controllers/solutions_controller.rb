class SolutionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    run = Run.find(params[:id])
    respond_to do |format|
      format.html do
      end
      format.csv do
        render text: run.objective_csv
      end
    end
  end

  def show
    @body_classes << "graph-body"
    @solution = Solution.find(params[:id])
    gon.solution_path = "#{solution_path(@solution.id)}.csv"

    if @solution.clusters.size > 0

      respond_to do |format|
        format.html do          
        end
        format.csv do
          render text: @solution.to_csv
        end
      end
      
    else
      clusters = []
      cluster_datapoints = []

      solution_file_path = "algo/data/#{@solution.mock_file_name}"

      # Create clusters
      File.open(solution_file_path, "r+") do |file|
        
        # Collect cluster ids from files
        generated_cluster_ids = Set.new
        CSV.foreach(file) do |line|
          generated_cluster_ids.add(line.first.split(' ').last.to_i)
        end

        # Create Cluster records
        generated_cluster_ids.each do |generated_cluster_id|
          clusters << Cluster.new(:solution_id => params[:id], :generated_cluster_id => generated_cluster_id)
        end

      end

      Cluster.import clusters

      clusters_for_solution = Cluster.where(:solution_id => @solution.id)
      File.open(solution_file_path, "r+") do |file|
        datapoints = @solution.run.dataset.datapoints
        datapoints.each do |datapoint|
          generated_cluster_id = file.readline.split(' ').last.to_i
          cluster = clusters_for_solution.where(:generated_cluster_id => generated_cluster_id).first
          cluster_datapoints << ClusterDatapoint.new(:cluster_id => cluster.id, :datapoint_id => datapoint.id)
        end
      end

      ClusterDatapoint.import cluster_datapoints

      File.delete(solution_file_path)

    end
  end

end
