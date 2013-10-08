class DatasetsController < ApplicationController

  def new
    if user_signed_in?
      @dataset = Dataset.new
    else
      redirect_to :new_user_session
    end
  end

  def create
    if user_signed_in?
      # Create Dataset
      dataset = Dataset.new(
        :user_id => current_user.id,
        :name => params[:dataset][:name],
        :rows => params[:dataset][:file].tempfile.readlines.size
      )
      dataset_columns = 0;
      if dataset.save
        sequence_id = 1;
        CSV.foreach(params[:dataset][:file].tempfile) do |line|
          dataset_columns = line.first.split(' ').size
          # Create Datapoint
          datapoint = Datapoint.new(
            :dataset_id  => dataset.id,
            :sequence_id => sequence_id
          )
          sequence_id += 1

          if datapoint.save
            line.first.split(' ').each do |datavalue_string|
              # Create Datavalue
              datavalue = Datavalue.new(
                :value => datavalue_string.to_f,
                :datapoint_id => datapoint.id
              )
              datavalue.save
            end
          end
        end
      end
      dataset.update_attributes(:columns => dataset_columns)
      redirect_to dataset
    end
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
    end
  end

  def show
    respond_to do |format|
      format.html do
        if user_signed_in?
          @dataset = Dataset.find_by_id_and_user_id(params[:id], current_user.id)
        end
      end
      format.csv do
        render text: Dataset.find(params[:id]).to_csv
      end
    end
  end

end
