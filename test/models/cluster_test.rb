require 'test_helper'

class ClusterTest < ActiveSupport::TestCase
  

  test "cluster can be created" do
    assert Cluster.new(:solution_id => 1).save, "Can't create a cluster"
  end


  test "creating a cluster with no solution ID" do
    assert !Cluster.new.save, "Created a cluster without a solution ID"
  end


end
