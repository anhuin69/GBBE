class Item < ActiveRecord::Base
  belongs_to :storage
  belongs_to :parent, -> (item){ where storage_id: item.storage_id }, class_name: 'Item', primary_key: 'remote_id', foreign_key: 'parent_remote_id'
  has_many :children, -> (item){ where storage_id: item.storage_id }, class_name: 'Item', primary_key: 'remote_id', foreign_key: 'parent_remote_id'

  def as_json(options)
    super(:only => [:id, :storage_id, :parent, :title, :description, :mimeType, :fileSize])
  end

end
