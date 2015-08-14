class AddDeletedAtToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :deleted_at, :datetime
    add_index :journals, :deleted_at
  end
end
