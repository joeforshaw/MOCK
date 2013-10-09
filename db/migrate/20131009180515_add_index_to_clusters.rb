class AddIndexToClusters < ActiveRecord::Migration
  def change
    add_index :clusters, :solution_id
  end
end
