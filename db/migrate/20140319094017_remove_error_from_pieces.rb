class RemoveErrorFromPieces < ActiveRecord::Migration
  def up
    remove_column :pieces, :error
  end

  def down
    add_column :pieces, :error, :text
  end
end
