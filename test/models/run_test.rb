require 'test_helper'

class DatasetTest < ActiveSupport::TestCase


  test "a run can be created" do
    assert Run.new(
      :runtime    => 1,
      :dataset_id => 1,
      :user_id    => 1,
      :completed  => false
    ).save!, "Can't create a run"
  end


  test "creating a run without a runtime" do
    assert !Run.new(
      :dataset_id => 1,
      :user_id    => 1,
      :completed  => false
    ).save, "Created a run without a runtime"
  end


  test "creating a run without a dataset_id" do
    assert !Run.new(
      :runtime    => 1,
      :user_id    => 1,
      :completed  => false
    ).save, "Created a run without a dataset_id"
  end

  test "creating a run without a user_id" do
    assert !Run.new(
      :runtime    => 1,
      :dataset_id => 1,
      :completed  => false
    ).save, "Created run without a user_id"
  end

  test "creating a run without a completed flag" do
    assert !Run.new(
      :runtime    => 1,
      :dataset_id => 1,
      :user_id    => 1
    ).save, "Created a run without a completed flag"
  end


end
