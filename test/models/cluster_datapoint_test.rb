require 'test_helper'

class ClusterDatapointTest < ActiveSupport::TestCase


  test "cluster datapoint can be created" do
    assert ClusterDatapoint.new(
      :cluster_id   => 1,
      :datapoint_id => 1,
    ).save, "Can't create a cluster datapoint"
  end


  test "creating cluster datapoint with cluster ID" do
    assert !ClusterDatapoint.new(:cluster_id => 1).save, "Saved cluster datapoint without a cluster ID"
  end


  test "creating dataset with no datapoint ID" do
    assert !ClusterDatapoint.new(:datapoint_id => 1).save, "Saved cluster datapoint without a datapoint ID"
  end


end
