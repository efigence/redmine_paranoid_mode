class AddDeletedAtToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :deleted_at, :datetime
    add_index :issues, :deleted_at
  end

  def down
    remove_column :issues, :deleted_at, :datetime
    remove_index :issues, :deleted_at
  end
end
