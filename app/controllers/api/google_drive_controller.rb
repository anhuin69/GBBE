require 'google/api_client'

class GoogleDriveController < ApiController

  def initialize(storage, csrf_token = nil)
    super(storage, csrf_token)
    @client = Google::APIClient.new
    @client.authorization.client_id = Gatherbox::Application.config.api[storage.provider][:ID]
    @client.authorization.client_secret = Gatherbox::Application.config.api[storage.provider][:SECRET]
    @client.authorization.redirect_uri = Gatherbox::Application.config.api[storage.provider][:REDIRECT_URI]
    @client.authorization.scope = Gatherbox::Application.config.api[storage.provider][:OAUTH_SCOPE]
    begin
      unless (@storage.token.nil?)
        @client.authorization.refresh_token = @storage.token
        @client.authorization.fetch_access_token!
        init_drive_api
      end
    rescue
      @drive = nil;
    end
  end

  def get_authorization_url
    return @client.authorization.authorization_uri(:state => "#{@storage.user.authentication_token},#{@storage.user.email}").to_s
  end

  def init_drive_api
    @drive = @client.discovered_api('drive', 'v2')
  end

  def authorize(code, state = nil)
    begin
      @client.authorization.code = code
      @client.authorization.fetch_access_token!
      @storage.token = @client.authorization.refresh_token
      init_drive_api
      return true
    rescue Exception => error
      @drive = nil
      return false
    end
  end

  def get_account_infos
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    api_result = @client.execute(:api_method => @drive.about.get)
    result = Hash.new
    status_code = api_result.status
    if (status_code == 200)
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
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    api_result = @client.execute(:api_method => @drive.files.get, :parameters => { 'fileId' => remote_id })
    status_code = api_result.status
    if (status_code == 200)
      result = file_resource(api_result.data)
    else
      result = api_result.data['error']['message']
    end
    return status_code, result
  end

  def changes(local_item, page_token = nil)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    parameters = Hash.new
    parameters['pageToken'] = page_token unless page_token.nil?
    parameters['startChangeId'] = @storage.etag.to_i unless @storage.etag.nil?

    api_result = @client.execute(:api_method => @drive.changes.list, :parameters => parameters)
    status_code = api_result.status
    if (status_code == 200)
      result = Hash.new
      api_result.data.items.each do |change|
        item = nil
        unless (change.deleted || change.file.labels['trashed'] == true)
          item = file_resource(change.file)
        end
        result[change.fileId] = item
      end
      next_page_status, next_page_result = changes(nil, api_result.data.nextPageToken) unless api_result.data['nextPageToken'].nil? || api_result.data['nextPageToken'].empty?
      if (next_page_status == 200)
        result = result.deep_merge(next_page_result)
      end
      @storage.etag = (api_result.data.largestChangeId + 1).to_s
      @storage.save
    else
      result = api_result.data['error']['message']
    end
    return status_code, result
  end

  def delete(remote_id)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    api_result = @client.execute(:api_method => @drive.files.trash, #@drive.files.delete,
                             :parameters => { 'fileId' => remote_id})
    return api_result.status, (api_result.status != 200 ? api_result.data['error']['message'] : 'ok')
  end

  def patch(remote_id, resources)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    api_result = @client.execute(:api_method => @drive.files.patch, :body_object => resources, :parameters => { 'fileId' => remote_id })
    status_code = api_result.status
    if (status_code == 200)
        result = file_resource(api_result.data)
    else
      result = api_result.data['error']['message']
    end
    return status_code, result
  end

  def move(remote_id, old_parent_id, new_parent_id)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    new_parent = @drive.parents.insert.request_schema.new({'id' => new_parent_id})
    api_result = @client.execute(:api_method => @drive.parents.insert, :body_object => new_parent, :parameters => { 'fileId' => remote_id })
    if (api_result.status == 200)
      api_result = @client.execute(:api_method => @drive.parents.delete, :parameters => { 'fileId' => remote_id, 'parentId' => old_parent_id})
    end
    status_code = (api_result.status == 204) ? 200 : api_result.status
    return status_code, (status_code != 200 ? api_result.data['error']['message'] : '')
  end

  def copy(remote_id, parent_remote_id, copy_title)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    copied_file = @drive.files.copy.request_schema.new({'title' => copy_title, 'parents' => [{'id' => parent_remote_id}]})
    result = @client.execute(
        :api_method => @drive.files.copy,
        :body_object => copied_file,
        :parameters => { 'fileId' => remote_id })
    if result.status == 200
      return result.status, file_resource(result.data)
    else
      return result.status, result.data['error']['message']
    end
  end

  def create_folder(title, description, parent_remote_id)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    file = @drive.files.insert.request_schema.new({
                                                     'title' => title,
                                                     'description' => description,
                                                     'mimeType' => 'application/vnd.google-apps.folder'
                                                 })
    unless parent_remote_id.nil?
      file.parents = [{'id' => parent_remote_id}]
    end
    result = @client.execute(
        :api_method => @drive.files.insert,
        :body_object => file)
    if result.status == 200
      return result.status, file_resource(result.data)
    else
      return result.status, result.data['error']['message']
    end
  end

  def upload_file(parent_remote_id, title, mime_type, file_path)
    return :not_acceptable, 'unauthorized drive' if @drive.nil?

    file = @drive.files.insert.request_schema.new({'title' => title, 'mimeType' => mime_type, 'parents' => [{'id' => parent_remote_id}]})
    media = Google::APIClient::UploadIO.new(file_path, mime_type)
    api_result = @client.execute(
        :api_method => @drive.files.insert,
        :body_object => file,
        :media => media,
        :parameters => {
            'uploadType' => 'multipart',
            'alt' => 'json'})
    if api_result.status == 200
      return api_result.status, file_resource(api_result.data)
    else
      return api_result.status, api_result.data['error']['message']
    end
  end

  # Convert a google drive file resource to unified hash values
  def file_resource(data)
    mime_type = data.mimeType unless (data['mimeType'].nil?)
    mime_type = 'folder' if (mime_type.nil? || mime_type.end_with?('folder'))

    result = Hash.new
    result[:remote_id] = data.id
    result[:remote_link] = data.downloadUrl unless (data['downloadUrl'].nil?)
    result[:title] = data.title unless (data['title'].nil?)
    result[:mimeType] = mime_type
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