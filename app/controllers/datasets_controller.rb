class DatasetsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @dataset = Dataset.new
  end

  def create
    # Create Dataset
    dataset = Dataset.new(
      :user_id => current_user.id,
      :name => params[:dataset][:name],
      :rows => params[:dataset][:file].tempfile.readlines.size
    )
    dataset_columns = -1;
    datavalues = []
    if dataset.save
      sequence_id = 1;
      CSV.foreach(params[:dataset][:file].tempfile) do |line|
        # Calculate number of columns
        if dataset_columns < 0
          dataset_columns = line.first.split(' ').size
        end
        # Create Datapoint
        datapoint = Datapoint.new(
          :dataset_id  => dataset.id,
          :sequence_id => sequence_id
        )
        sequence_id += 1
        
        if datapoint.save
          line.first.split(' ').each do |datavalue_string|
            # Create Datavalue
            datavalues << Datavalue.new(
              :value => datavalue_string.to_f,
              :datapoint_id => datapoint.id
            )
          end
        end

      end
    end
    Datavalue.import datavalues
    dataset.update_attributes(:columns => dataset_columns)
    redirect_to dataset
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
    respond_to do |format|
      format.html do
        @dataset = Dataset.find(params[:id])
      end
      format.csv do
        render text: Dataset.find(params[:id]).to_csv
      end
    end
  end

end
