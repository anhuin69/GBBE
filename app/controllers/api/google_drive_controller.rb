require 'google/api_client'

class GoogleDriveController < ApiController
  attr_accessor :storage

  # TODO: manage revoked access
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
      @storage.token = @client.authorization.refresh_token
      return true
    rescue Exception => error
      return false
    end
  end

  def get_account_infos
    api_result = @client.execute(:api_method => @drive.about.get)
    result = Hash.new
    status_code = api_result.status
    if (status_code == 200)
      puts "------------------------"
      puts api_result.data.to_json
      result[:login] = api_result.data.name
      result[:picture_url] = (api_result.data.user.nil? || api_result.data.user.picture.nil?) ? nil : api_result.data.user.picture.url
      result[:quota_bytes_total] = api_result.data.quota_bytes_total
      result[:quota_bytes_used] = api_result.data.quota_bytes_used
      result[:root_folder_id] = api_result.data.rootFolderId
      result[:etag] = api_result.data.etag
    end
    return status_code, result
  end

  def file_get(remote_id)
    api_result = @client.execute(:api_method => @drive.files.get, :parameters => { 'fileId' => remote_id })
    result = Hash.new
    status_code = api_result.status
    if (status_code == 200)
      result = file_resource(api_result.data)
    end
    return status_code, result
  end

  def changes(page_token = nil)
    parameters = Hash.new
    parameters['pageToken'] = page_token unless page_token.nil?
    parameters['startChangeId'] = @storage.etag.to_i unless @storage.etag.nil?

    api_result = @client.execute(:api_method => @drive.changes.list, :parameters => parameters)
    status_code = api_result.status
    result = Hash.new
    if (status_code == 200)
      api_result.data.items.each do |change|
        item = nil
        unless (change.deleted || change.file.labels['trashed'] == true)
          item = file_resource(change.file)
        end
        result[change.fileId] = item
      end
      next_page_status, next_page_result = changes(api_result.data.nextPageToken) unless api_result.data['nextPageToken'].nil? || api_result.data['nextPageToken'].empty?
      if (next_page_status == 200)
        result = result.deep_merge(next_page_result)
      end
      @storage.etag = (api_result.data.largestChangeId + 1).to_s
      @storage.save
    end
    return status_code, result
  end

  def delete(remote_id)
    api_result = @client.execute(:api_method => @drive.files.trash, #@drive.files.delete,
                             :parameters => { 'fileId' => remote_id})
    return api_result.status, (api_result.status != 200 ? api_result.data['error']['message'] : 'ok')
  end

  def patch(remote_id, resources)
    api_result = @client.execute(:api_method => @drive.files.patch, :body_object => resources, :parameters => { 'fileId' => remote_id })
    status_code = api_result.status
    result = Hash.new
    if (status_code == 200)
        result = file_resource(api_result.data)
    end
    return status_code, result
  end

  def move(remote_id, old_parent_id, new_parent_id)
    new_parent = @drive.parents.insert.request_schema.new({'id' => new_parent_id})
    api_result = @client.execute(:api_method => @drive.parents.insert, :body_object => new_parent, :parameters => { 'fileId' => remote_id })
    if (api_result.status == 200)
      api_result = @client.execute(:api_method => @drive.parents.delete, :parameters => { 'fileId' => remote_id, 'parentId' => old_parent_id})
    end
    status_code = (api_result.status == 204) ? 200 : api_result.status
    return status_code, (status_code != 200 ? api_result.data['error']['message'] : '')
  end

  def file_resource(data)
    result = Hash.new
    result[:remote_id] = data.id
    result[:remote_link] = data.selfLink unless (data['selfLink'].nil?)
    result[:title] = data.title unless (data['title'].nil?)
    result[:mimeType] = data.mimeType unless (data['mimeType'].nil?)
    result[:description] = data.description unless (data['description'].nil?)
    result[:createdDate] = data.createdDate unless (data['createdDate'].nil?)
    result[:modifiedDate] = data.modifiedDate unless (data['modifiedDate'].nil?)
    result[:userPermission] = data.userPermission.role unless (data['userPermission'].nil?)
    result[:fileSize] = data.fileSize unless (data['fileSize'].nil?)
    result[:iconLink] = data.thumbnailLink unless (data['thumbnailLink'].nil?)
    result[:etag] = data.etag unless (data['etag'].nil?)
    result[:md5checksum] = data.md5checksum unless (data['md5checksum'].nil?)
    result[:parent_remote_id] = data.parents[0].id unless data['parents'].nil? || data.parents.nil? || data.parents.empty?
    return result
  end
end