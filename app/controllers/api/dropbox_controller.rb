require 'dropbox_sdk'

class DropboxController < ApiController

  def initialize(storage, csrf_token = nil)
    super(storage, csrf_token)
    @flow = DropboxOAuth2Flow.new(Gatherbox::Application.config.api[storage.provider][:ID],
                                  Gatherbox::Application.config.api[storage.provider][:SECRET],
                                  Gatherbox::Application.config.api[storage.provider][:REDIRECT_URI],
                                  {:dropbox_auth_csrf_token => csrf_token},
                                  :dropbox_auth_csrf_token)
    initialize_client
  end

  def initialize_client
    if (@storage.token.nil? || @storage.token.empty?)
      @client = nil
    else
      @client = DropboxClient.new(@storage.token)
    end
  end

  def get_authorization_url
    return @flow.start("#{@storage.user.authentication_token},#{@storage.user.email}")
  end

  def authorize(code, state = nil)
    begin
      access_token, user_id, url_state = @flow.finish({'code' => code, 'state' => state})
      @storage.token = access_token
      initialize_client
      return true
    rescue Exception => error
      return false
    end
  end

  def get_account_infos
    begin
      account_infos = @client.account_info()
      result = Hash.new
      result[:login] = account_infos['display_name']
      result[:quota_bytes_total] = account_infos['quota_info']['quota']
      result[:quota_bytes_used] = account_infos['quota_info']['normal'] + account_infos['quota_info']['shared']
      result[:root_folder_id] = '/'
      return 200, result
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def file_get(remote_id)
    begin
      api_result = @client.metadata(remote_id, 0, false)
      return 200, file_resource(api_result)
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def changes(local_item)
    begin
      api_result = @client.metadata(local_item.remote_id, 25000, true, local_item.etag, nil, true)
      status_code = 200
      result = Hash.new
      result[api_result['path']] = api_result['is_deleted'] ? nil : file_resource(api_result)

      unless (api_result['contents'].nil?)
        api_result['contents'].each do |child|
          if (child['is_deleted'])
            result[child['path']] = nil
          else
            result[child['path']] = file_resource(child)
            result[child['path']][:parent_remote_id] = api_result['path']
          end
        end
      end

    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
    return status_code, result
  end

  def delete(remote_id)
    begin
      @client.file_delete(remote_id)
      return 200, 'ok'
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def patch(remote_id, resources)
    begin
      unless (resources[:title].nil? || resources[:title].empty? || remote_id == '/')
        new_path = remote_id
        name_idx = new_path.rindex('/')
        new_path = new_path[0..name_idx] + resources[:title]
        api_result = @client.file_move(remote_id, new_path)
        return 200, file_resource(api_result)
      else
        return 200, Hash.new
      end
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def move(remote_id, old_parent_id, new_parent_id)
    begin
      file_title = remote_id.split('/').last
      new_path = new_parent_id + '/' + file_title
      api_result = @client.file_move(remote_id, new_path)
      return 200, file_resource(api_result)
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def copy(remote_id, parent_remote_id, copy_title)
    begin
      new_path = parent_remote_id + '/' + copy_title
      api_result = @client.file_copy(remote_id, new_path)
      return 200, file_resource(api_result)
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def create_folder(title, description, parent_remote_id)
    begin
      api_result = @client.file_create_folder(parent_remote_id + '/' + title)
      return 200, file_resource(api_result)
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def upload_file(parent_remote_id, title, mime_type, file_path)
    begin
      file = open(file_path)
      api_result = @client.put_file(parent_remote_id + '/' + title, file)
      return 200, file_resource(api_result)
    rescue Exception => error
      if (error.instance_of?(DropboxNotModified))
        return 200, Hash.new
      elsif (error.instance_of?(DropboxAuthError))
        return :not_acceptable, 'unauthorized drive'
      else
        return :unprocessable_entity, error.to_s
      end
    end
  end

  def file_resource(data)
    result = Hash.new
    result[:remote_id] = data['path']
    result[:mimeType] = data['is_dir'] ? 'application/folder' : data['mime_type']
    result[:fileSize] = data['bytes']
    result[:modifiedDate] = data['modified']
    result[:title] = data['path'] == '/' ? '/' : data['path'].split('/').last
    result[:etag] = data['hash'] unless data['hash'].nil?
    return result
  end
end