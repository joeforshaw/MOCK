class AddPlottableToClusters < ActiveRecord::Migration
  def change
    add_column :clusters, :plottable_id, :integer
    add_column :clusters, :plottable_type, :string
  end
end
