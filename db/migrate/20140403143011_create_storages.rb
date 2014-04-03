class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.references :user
      t.string :provider
      t.string :token
      t.string :login
      t.string :password
      t.string :url
      t.integer :port
      t.integer :quota_bytes_total, :limit => 8
      t.integer :quota_bytes_used, :limit => 8
      t.text :etag
      t.text :uid
      t.text :picture_url

      t.timestamps
    end

    add_index :storages, :user_id
  end
end
