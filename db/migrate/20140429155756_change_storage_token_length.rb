class ChangeStorageTokenLength < ActiveRecord::Migration
  def change
    change_column :storages, :token, :string, :limit => 1024
  end
end
