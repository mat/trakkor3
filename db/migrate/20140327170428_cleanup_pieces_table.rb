class CleanupPiecesTable < ActiveRecord::Migration
  def up
    remove_column :pieces, :bytecount
    remove_column :pieces, :duration
  end

  def down
    add_column :pieces, :bytecount, :integer
    add_column :pieces, :duration, :integer
  end
end
