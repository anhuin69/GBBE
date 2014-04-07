
class DropboxController < ApiController

  def initialize(storage)
    super(storage)
    
  end

  def get_authorization_url
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def authorize(code)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def get_account_infos
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def file_get(remote_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def changes
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def delete(remote_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def patch(remote_id, resources)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def move(remote_id, old_parent_id, new_parent_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def copy(remote_id, parent_remote_id, copy_title)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def create_folder(title, parent_remote_id)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

  def upload_file(parent_remote_id, title, mime_type, file_path)
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end
end