class MdsDatasetsController < ApplicationController

  def show
    @dataset = Dataset.find(params[:id])
    @mds_dataset = @dataset.mds_dataset

    if @mds_dataset.nil?
      @mds_dataset = MdsDataset.create(:dataset => @dataset)
      @mds_dataset.calculate
    end

    respond_to do |format|
      format.html do
        redirect_to @mds_dataset.dataset
      end
      format.csv do
        render text: @mds_dataset.to_csv
      end
    end
  end

end
