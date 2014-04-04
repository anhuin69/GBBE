
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
  # @return {:status, :login, :picture_url, :quota_bytes_total, quota_bytes_used, :root_folder_id, :etag}
  def get_account_infos
    raise "API.method.undefined #{self.class.name} #{__method__}"
  end

end