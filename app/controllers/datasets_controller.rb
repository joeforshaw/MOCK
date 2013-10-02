require 'csv'

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
        :name => params[:dataset][:name]
      )
      if dataset.save
        CSV.foreach(params[:dataset][:file].tempfile) do |line|
          # Create Datapoint
          datapoint = Datapoint.new(:dataset_id => dataset.id)
          if datapoint.save
            
            datavalues = line[0].split(' ')
            datavalues.each do |datavalue_string|
              # Create Datavalue
              Datavalue.new(
                :value => datavalue_string.to_f,
                :datapoint_id => datapoint.id
              ).save
            end
          end
        end
      end
      redirect_to :datasets
    end
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
    end
  end

  def show
    @dataset = Dataset.find(params[:id])
  end

end
