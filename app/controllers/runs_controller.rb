class RunsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @dataset = Dataset.new    
  end

  def index
    @body_classes << "runs-body"
    @datasets = current_user.datasets
    @runs = current_user.runs.order("created_at DESC")
  end

  def show
    @run = Run.find(params[:id])
    if @run.completed?
      gon.solution_front_path = "#{solutions_path(@run.id)}.csv"
      gon.solution_control_front_path = "#{control_solutions_path(@run.id)}.csv"
      gon.solution_path = "#{solution_path(nil)}"
    end
  end

  def destroy
    Run.destroy(params[:id])
    redirect_to :runs
  end

  def create
    @dataset = Dataset.find(params[:dataset])

    @run = Run.new(
      :dataset_id => @dataset.id,
      :user_id => current_user.id
    )

    if @run.save

      mock_thread = Thread.new do
        start_time = Time.now

        temp_file_name = "tmp/user.#{current_user.id}.dataset.#{@dataset.id}.csv"
        File.open(temp_file_name, 'w') {|f| f.write(@dataset.to_csv) }
        `algo/MOCK 1 1 #{temp_file_name} #{@dataset.rows} #{@dataset.columns - 1} #{current_user.id} #{@run.id}`

        solutions = []
        control_solutions = []
        objective_file = CSV.open("algo/data/#{@run.objective_file_name}")

        # Sort data files
        data_files = Dir.entries("algo/data").sort do |a, b|
          a_split = a.split('.')
          b_split = b.split('.')
          if a_split.size < 9
            1
          elsif b_split.size < 9
            -1
          else
            a_split[7].to_i <=> b_split[7].to_i
          end
        end

        data_files.each do |filename|
          split_filename = filename.split('.')
          if split_filename[1].to_i == current_user.id && split_filename[5].to_i == @run.id
            if split_filename.size == 9
              
              objective_line_string = objective_file.readline.first.split(' ')

              solutions << Solution.new(
                :run_id => @run.id,
                :generated_solution_id => (split_filename[7].to_i + 1),
                :connectivity => objective_line_string[2].to_f,
                :deviation => objective_line_string[3].to_f
              )

            elsif split_filename[6] == "control"
              # Process control data
              File.open("algo/data/#{@run.control_file_name}", "r+") do |file|
                CSV.foreach(file) do |line|
                  split_line = line.first.split(' ')
                  control_solutions << ControlSolution.new(
                    :run_id       => @run.id,
                    :connectivity => split_line[2].to_f,
                    :deviation    => split_line[3].to_f
                  )
                end
              end
            end
          end
        end   

        Solution.import solutions
        ControlSolution.import control_solutions

        @run.update_attributes(:completed => true, :runtime => Time.now - start_time)
      end # End of Thread
      # redirect_to @run
    end

  end

end
