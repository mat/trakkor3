class RenameMd5sumToCode < ActiveRecord::Migration
  def up
    rename_column :trackers, :md5sum, :code
  end

  def down
    rename_column :trackers, :code, :md5sum
  end
end
