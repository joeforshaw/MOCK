require 'test_helper'

class DatasetTest < ActiveSupport::TestCase


  test "dataset can be created" do
    assert Dataset.new(
      :name    => "Test Dataset",
      :user_id => 1,
      :columns => 1,
      :rows    => 1
    ).save, "Can't create a dataset"
  end


  test "creating dataset with no name" do
    assert !Dataset.new(
      :user_id => 1,
      :columns => 1,
      :rows    => 1
    ).save, "Created dataset without a name"
  end


  test "creating dataset with no user ID" do
    assert !Dataset.new(
      :name => "Test Dataset",
      :columns => 1,
      :rows    => 1
    ).save, "Created dataset without a user ID"
  end


end
