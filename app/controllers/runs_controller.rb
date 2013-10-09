class RunsController < ApplicationController

  def new
    @dataset = Dataset.find(params[:dataset])
    @run = Run.new(
      :dataset_id => @dataset.id,
      :user_id => current_user.id
    )
    
    if @run.save

      temp_file_name = "tmp/user.#{current_user.id}.dataset.#{@dataset.id}.csv"
      File.open(temp_file_name, 'w') {|f| f.write(@dataset.to_csv) }
      `algo/MOCK 1 1 #{temp_file_name} #{@dataset.rows} #{@dataset.columns - 1} #{current_user.id} #{@run.id}`

      solutions = []
      clusters = []
      cluster_datapoints = []
      Dir.foreach("algo/data") do |filename|

        split_filename = filename.split('.')
        if split_filename.size == 9 && split_filename[1].to_i == current_user.id && split_filename[5].to_i == @run.id
          
          solution = Solution.new(
            :run_id => @run.id,
            :generated_solution_id => (split_filename[7].to_i + 1)
          )

          if solution.save

            # Create clusters
            File.open("algo/data/#{solution.mock_file_name}", "r+") do |file|
              
              # Collect cluster ids from files
              generated_cluster_ids = Set.new
              CSV.foreach(file) do |line|
                generated_cluster_ids.add(line.first.split(' ').last.to_i)
              end

              # Create Cluster records
              generated_cluster_ids.each do |generated_cluster_id|
                clusters << Cluster.new(:solution_id => solution.id, :generated_cluster_id => generated_cluster_id)
              end

            end
          end
        end
      end

      Cluster.import clusters

      solutions = @run.solutions
      solutions.each do |solution|
        clusters_for_solution = Cluster.where(:solution_id => solution.id)
        File.open("algo/data/#{solution.mock_file_name}", "r+") do |file|
          datapoints = @run.dataset.datapoints
          datapoints.each do |datapoint|
            generated_cluster_id = file.readline.split(' ').last.to_i
            cluster = clusters_for_solution.where(:generated_cluster_id => generated_cluster_id).first
            cluster_datapoints << ClusterDatapoint.new(:cluster_id => cluster.id, :datapoint_id => datapoint.id)
          end
        end
      end

      ClusterDatapoint.import cluster_datapoints

    end

    redirect_to @run
    
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
      @runs = current_user.runs.order("created_at DESC")
    end
  end

  def show
    @run = Run.find(params[:id])
  end

end
