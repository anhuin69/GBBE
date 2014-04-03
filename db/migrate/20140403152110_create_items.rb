class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :storage
      t.string :parent_remote_id
      t.string :remote_id
      t.text :remote_link
      t.text :title
      t.text :mimeType
      t.text :description
      t.datetime :createdDate
      t.datetime :modifiedDate
      t.integer :userPermission
      t.integer :fileSize, :limit => 8
      t.text :etag
      t.text :md5checksum
      t.text :iconLink

      t.timestamps
    end

    add_index :items, :storage_id
    add_index :items, :remote_id
    add_index :items, :parent_remote_id
  end
end
