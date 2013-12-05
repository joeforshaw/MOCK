require 'test_helper'

class DatapointTest < ActiveSupport::TestCase
  

  test "a datapoint can be created" do
    assert Datapoint.new(
      :dataset_id  => 1,
      :sequence_id => 1,
    ).save, "Can't create a datapoint"
  end


  test "creating a datapoint without a dataset_id" do
    assert !Datapoint.new(:sequence_id => 1).save, "Created a datapoint without a dataset_id"
  end


  test "creating a datapoint without a sequence_id" do
    assert !Datapoint.new(:dataset_id  => 1).save, "Created a datapoint without a sequence_id"
  end


end
