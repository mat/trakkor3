class DropTableLoggedExceptions < ActiveRecord::Migration
  def up
    drop_table :logged_exceptions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
