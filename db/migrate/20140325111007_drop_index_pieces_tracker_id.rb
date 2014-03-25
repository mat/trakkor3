class DropIndexPiecesTrackerId < ActiveRecord::Migration
  def up
    remove_index :pieces, {name: "pieces_tracker_error"}
  end

  def down
    add_index :pieces, [:tracker_id]
  end
end
