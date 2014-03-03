class DatasetsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @dataset = Dataset.new
  end


  def create
    file_extension = File.extname(params[:dataset][:file].original_filename)
    puts "Extension: #{file_extension}"
    if file_extension == ".csv"
      dataset = Dataset.parse_csv(params[:dataset][:file].tempfile, current_user.id, params[:dataset][:name])
      redirect_to dataset
    else
      throw Exception
    end
  end


  def destroy
    Dataset.destroy(params[:id])
    redirect_to :datasets
  end


  def index
    @body_classes << "datasets-body"
    @datasets = current_user.datasets.order("created_at DESC")
  end


  def show
    @body_classes << "graph-body"
    @dataset = Dataset.find(params[:id])
    gon.solution_path = "#{dataset_path(@dataset.id)}.csv"
    gon.mds_path = "#{mds_dataset_path(@dataset.id)}.csv"
    gon.is_plot = true
    gon.is_solution = false
    gon.use_mds = false

    respond_to do |format|
      format.html do
        @dataset
      end
      format.csv do
        render text: @dataset.to_csv
      end
    end
  end

end
