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
      
      # Get a list of the names of all solution files generated
      Dir.foreach("algo/data") do |filename|

        split_filename = filename.split('.')

        if split_filename.size == 9 && split_filename[1].to_i == current_user.id && split_filename[5].to_i == @run.id
          
          solution = Solution.new(
            :run_id => @run.id,
            :generated_solution_id => (split_filename[7].to_i + 1)
          )

          if solution.save
            clusters = Set.new []
            File.open("algo/data/#{solution.mock_file_name}", "r+") do |file|
              puts file.inspect
              CSV.foreach(file) do |line|
                cluster_id = line.first.split(' ').last.to_i
                if !clusters.add?(cluster_id).nil?
                  cluster = Cluster.new(
                    :solution_id => solution.id,
                    :generated_cluster_id => cluster_id
                  )
                  cluster.save
                end

                
                
              end
            end

          end

        end
      end
    end
    
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
