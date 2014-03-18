class AddLastErrorToTrackers < ActiveRecord::Migration
  def change
    add_column :trackers, :last_error, :text, :default => ""
  end
end
