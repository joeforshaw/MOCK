require 'test_helper'

class DatavalueTest < ActiveSupport::TestCase
  

  test "a datavalue can be created" do
    assert Datavalue.new(
      :datapoint_id => 1,
      :value        => 1.0,
    ).save, "Can't create a datavalue"
  end


  test "creating a datavalue without a datapoint_id" do
    assert !Datavalue.new(:value => 1.0).save, "Created a datavalue without a datapoint_id"
  end


  test "creating a datavalue without a value" do
    assert !Datavalue.new(:datapoint_id  => 1).save, "Created a datapoint without a value"
  end


end
