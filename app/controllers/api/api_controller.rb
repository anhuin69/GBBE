
class ApiController

  def self.get_controller(storage)
    controller = nil
    unless (Gatherbox::Application.config.api[storage.provider].nil?)
      controller = GoogleDriveController.new(storage)
    end
    return controller
  end

  def initialize(storage)
    @storage = storage
  end

  # @return string Authorization URL to visit
  def get_authorization_url
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Authorize the authentication to a user account on a remote storage
  # @return boolean (true if authorized, false otherwise)
  def authorize(code)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Get account informations and return them formated
  # @return :code, {:login, :picture_url, :quota_bytes_total, quota_bytes_used, :root_folder_id, :etag}
  def get_account_infos
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Get file informations and return them formated
  # @return :code, {:remote_id, :remote_link, :title, :mimeType, :description, :parent_remote_id
  # :createdDate, :modifiedDate, :userPermission, :fileSize, :iconLink, :etag, :md5checksum}
  def file_get(remote_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Get all changes on this storage since last check
  # @return [file1 (similar to file_get return), ...]
  def changes
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Move a file or folder
  # @return :code, :message (empty if no error)
  def move(remote_id, old_parent_id, new_parent_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Copy the file to the parent folder specified
  # @return :code, {:remote_id, :remote_link, :title, :mimeType, :description, :parent_remote_id
  # :createdDate, :modifiedDate, :userPermission, :fileSize, :iconLink, :etag, :md5checksum}
  def copy(remote_id, parent_remote_id, copy_title)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  # Create a folder in the specified parent folder
  # @return :code, {:remote_id, :remote_link, :title, :mimeType, :description, :parent_remote_id
  # :createdDate, :modifiedDate, :userPermission, :fileSize, :iconLink, :etag, :md5checksum}
  def create_folder(title, parent_remote_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end
end