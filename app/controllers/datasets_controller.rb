class DatasetsController < ApplicationController

  def new
    @dataset = Dataset.new
  end

  def create
    puts "Poops"
    uploaded_io = params[:dataset][:file]
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'w') do |file|
      file.write(uploaded_io.read)
    end
    # redirect_to :datasets
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
    end
  end

end
