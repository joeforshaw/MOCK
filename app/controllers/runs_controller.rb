class RunsController < ApplicationController

  def create
    @dataset = Dataset.find(params[:dataset])
    @run = Run.new(
      :dataset_id => @dataset.id,
      :user_id => current_user.id
    )
    @run.save
    temp_file_name = "tmp/user.#{current_user.id}.dataset.#{@dataset.id}.csv"
    File.open(temp_file_name, 'w') {|f| f.write(@dataset.to_csv) }
    puts "algo/MOCK 1 1 #{temp_file_name} #{@dataset.rows} #{@dataset.columns - 1} #{current_user.id} #{@run.id}"
    `algo/MOCK 1 1 #{temp_file_name} #{@dataset.rows} #{@dataset.columns - 1} #{current_user.id} #{@run.id}`
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
      @runs = current_user.runs
    end
  end

  def show
    @run = Run.find(params[:id])
    gon.dataset_path = "#{dataset_path(@run.dataset.id)}.csv"
  end

end
