class Dataset < ActiveRecord::Base

  belongs_to :user

  has_many :runs,       :dependent => :destroy
  has_many :datapoints, :as => :clusterable, :dependent => :destroy

  has_one :mds_dataset, :dependent => :destroy

  validates :name,    presence:     true
  validates :user_id, presence:     true,
                      numericality: true
  validates :columns, numericality: true
  validates :rows,    numericality: true

  def to_csv
    CSV.generate do |csv|
      self.datapoints.order(:sequence_id).each do |datapoint|
        datavalues = []
        datapoint.datavalues.order(:id).each do |datavalue|
          datavalues << datavalue.value
        end
        csv << [datavalues.join(" ")]
      end
    end
  end

  def self.parse_csv(csv_file, user_id, name)
    # Create Dataset
    dataset = Dataset.new(
      :user_id => user_id,
      :name    => name,
      :columns => -1,
      :rows    => -1
    )
    dataset_columns = -1
    datavalues = []
    sequence_id = 1;
    if dataset.save!
      delimiter = Dataset.delimiter_sniffer(csv_file)
      puts "The delimiter is: #{delimiter}"
      File.open(csv_file, "r+") do |file|
        puts "Opened: #{file.inspect}"

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
            puts "Datapoint saved"
            line.split(delimiter).each do |datavalue_string|
              datavalues << Datavalue.new(
                :value        => datavalue_string.to_f,
                :datapoint_id => datapoint.id
              )
            end
          end
        end
      end
    end
    Datavalue.import datavalues
    dataset.update_attributes(:columns => dataset_columns, :rows => sequence_id - 1)
    return dataset
  end


  private

  def self.delimiter_sniffer(filename)
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
