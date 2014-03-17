class AddErrorsToTrackers < ActiveRecord::Migration
  def change
    add_column :trackers, :error_count, :integer, :default => 0
  end
end
