class DatasetsController < ApplicationController


  before_filter :authenticate_user!


  def new
    @dataset = Dataset.new
  end


  def create
    file_extension = File.extname(params[:dataset][:file].original_filename)
    puts "Extension: #{file_extension}"
    if file_extension == ".csv"
      parse_csv(params[:dataset][:file].tempfile)
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
    gon.is_plot = true
    gon.is_solution = false
    respond_to do |format|
      format.html do
        @dataset
      end
      format.csv do
        render text: @dataset.to_csv
      end
    end
  end


  def parse_csv(csv_file)
    # Create Dataset
    dataset = Dataset.new(
      :user_id => current_user.id,
      :name    => params[:dataset][:name],
      :columns => -1,
      :rows    => params[:dataset][:file].tempfile.readlines.size
    )
    dataset_columns = -1;
    datavalues = []
    if dataset.save!
      sequence_id = 1;
      delimiter = delimiter_sniffer(csv_file)
      File.open(csv_file, "r+") do |file|
        file.each_line do |line|

          # Calculate number of columns
          if dataset_columns < 0
            dataset_columns = line.split(delimiter).size
          end
          # Create Datapoint
          datapoint = Datapoint.new(
            :clusterable  => dataset,
            :sequence_id => sequence_id
          )
          sequence_id += 1

          if datapoint.save!
            line.split(delimiter).each do |datavalue_string|
              datavalues << Datavalue.new(
                :value => datavalue_string.to_f,
                :datapoint_id => datapoint.id
              )
            end
          end
        end
      end
    end
    Datavalue.import datavalues
    dataset.update_attributes(:columns => dataset_columns)
    redirect_to dataset
  end


  def delimiter_sniffer(filename)
    file = File.open(filename)
    firstline = file.readline

    chosenDelimiter = nil
    bestDelimiterSize = 0;

    puts "firstline: #{firstline}"
    [',','\t',' '].each do |delimiter|
      delimiterSize = firstline.split(delimiter).size
      puts "'#{delimiter}' has size of #{delimiterSize}"
      if delimiterSize > bestDelimiterSize
        chosenDelimiter = delimiter
        bestDelimiterSize = delimiterSize
      end
    end

    if chosenDelimiter.nil?
      throw Exception
    end
    puts "Delimiter: '#{chosenDelimiter}'"

    return chosenDelimiter

  end

end
