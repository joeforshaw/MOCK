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
    @body_classes << "graph-body"
    @run = Run.find(params[:id])
    if @run.completed?
      gon.solution_front_path = "#{solutions_path(@run.id)}.csv"
      gon.solution_control_front_path = "#{control_solutions_path(@run.id)}.csv"
      gon.solution_path = "#{solution_path(nil)}"
      gon.last_solution = params[:last_solution]
    end
  end

  def destroy
    Run.destroy(params[:id])
    puts "rm algo/data/*run.#{params[:id]}.*"
    `rm algo/data/*run.#{params[:id]}.*`
    redirect_to :runs
  end

  def create
    @dataset = Dataset.find(params[:dataset])

    @run = Run.new(
      :runtime    => -1,
      :dataset_id => @dataset.id,
      :user_id    => current_user.id,
      :completed  => false
    )

    if @run.save

      mock_thread = Thread.new do
        start_time = Time.now

        # Save dataset csv to a temp file
        temp_file_name = create_dataset_temp_file(current_user, @dataset)
        
        # Run MOCK command
        run_mock(temp_file_name, @dataset, current_user, @run)

        # Open file which contains objective measurements for each solution
        objective_file = CSV.open("algo/data/#{@run.objective_file_name}")
        
        # Read data from each data file
        sorted_data_files().each do |filename|
          parse_data_file(filename, objective_file, current_user, @run)         
        end

        # Notify run is complete and update run time
        @run.update_attributes(
          :completed => true,
          :runtime   => Time.now - start_time
        )
      end
    else
      raise "Failed to save this Run to the database"
    end

  end

  def create_dataset_temp_file(user, dataset)
    temp_file_name = "tmp/user.#{user.id}.dataset.#{dataset.id}.csv"
    File.open(temp_file_name, 'w') {|f| f.write(dataset.to_csv) }
    return temp_file_name
  end

  def run_mock(temp_file_name, dataset, user, run)
    puts "algo/MOCK 1 1 #{temp_file_name} #{dataset.rows} #{dataset.columns} #{user.id} #{run.id}"
    `algo/MOCK 1 1 #{temp_file_name} #{dataset.rows} #{dataset.columns} #{user.id} #{run.id}`
  end

  def sorted_data_files
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
    return data_files
  end

  def parse_data_file(filename, objective_file, user, run)
    solutions = []
    control_solutions = []

    split_filename = filename.split('.')
    if split_filename[1].to_i == user.id && split_filename[5].to_i == run.id
      if split_filename.size == 9
        solutions << parse_objective_file(run, objective_file, split_filename)
      elsif split_filename[6] == "control"
        parse_control_file(run).each do |control_solution|
          control_solutions << control_solution
        end
      end
    end

    Solution.import solutions
    ControlSolution.import control_solutions
  end

  def parse_objective_file(run, objective_file, split_filename)
    objective_line_string = objective_file.readline.first.split(' ')

    # Add new solution to solution array
    return Solution.new(
      :run_id                => run.id,
      :generated_solution_id => (split_filename[7].to_i + 1),
      :connectivity          => objective_line_string[2].to_f,
      :deviation             => objective_line_string[3].to_f
    )
  end

  def parse_control_file(run)
    control_solutions = []
    File.open("algo/data/#{run.control_file_name}", "r+") do |file|
      CSV.foreach(file) do |line|
        split_line = line.first.split(' ')
        # Add control solution to array
        control_solutions << ControlSolution.new(
          :run_id       => run.id,
          :connectivity => split_line[2].to_f,
          :deviation    => split_line[3].to_f
        )
      end
    end
    return control_solutions
  end

end
