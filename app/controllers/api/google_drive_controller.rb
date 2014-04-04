require 'google/api_client'

class GoogleDriveController < ApiController
  attr_accessor :storage

  def initialize(storage)
    super(storage)
    @client = Google::APIClient.new
    @client.authorization.client_id = Gatherbox::Application.config.api[storage.provider][:ID]
    @client.authorization.client_secret = Gatherbox::Application.config.api[storage.provider][:SECRET]
    @client.authorization.redirect_uri = Gatherbox::Application.config.api[storage.provider][:REDIRECT_URI]
    @client.authorization.scope = Gatherbox::Application.config.api[storage.provider][:OAUTH_SCOPE]
    begin
      @drive = @client.discovered_api('drive', 'v2')
      unless (@storage.token.nil?)
        @client.authorization.refresh_token = @storage.token
        @client.authorization.fetch_access_token!
      end
    rescue
      @drive = nil;
    end
  end

  def get_authorization_url
    return @client.authorization.authorization_uri(:state => "#{@storage.user.authentication_token},#{@storage.user.email}").to_s
  end

  def authorize(code)
    begin
      @client.authorization.code = code
      @client.authorization.fetch_access_token!
      puts "----------------------"
      puts @client.authorization
      puts "----------------------"
      @storage.token = @client.authorization.refresh_token
      return true
    rescue Exception => error
      puts "====================="
      puts error
      puts "====================="
      return false
    end
  end

  def get_account_infos
    api_result = @client.execute(:api_method => @drive.about.get)
    result = Hash.new
    result[:code] = api_result.status
    if (result[:code] == 200)
      result[:login] = api_result.data.name
      result[:picture_url] = (api_result.data.user.nil? || api_result.data.user.picture.nil?) ? nil : api_result.data.user.picture.url
      result[:quota_bytes_total] = api_result.data.quota_bytes_total
      result[:quota_bytes_used] = api_result.data.quota_bytes_used
      result[:root_folder_id] = api_result.data.rootFolderId
      result[:etag] = nil
    end
    return result
  end

end