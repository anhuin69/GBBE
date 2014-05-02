
class SkyDriveController < ApiController

  def initialize(storage, csrf_token = nil)
    super(storage, csrf_token)
    @client = RestClient::Resource.new(Gatherbox::Application.config.api[@storage.provider][:API_URI])
    initialize_client
    end

  def initialize_client
    if (@storage.token.nil? || @storage.token.empty?)
      @access_token = nil
    else
      begin
        response = RestClient.post(Gatherbox::Application.config.api[@storage.provider][:LOGIN_URI] + '/oauth20_token.srf',
                                   {'client_id' => Gatherbox::Application.config.api[@storage.provider][:ID],
                                    'client_secret' => Gatherbox::Application.config.api[@storage.provider][:SECRET],
                                    'grant_type' => 'refresh_token',
                                    'refresh_token' => @storage.token})
        json_response = JSON.parse(response)
        @storage.token = json_response['refresh_token']
        @storage.save!
        @access_token = json_response['access_token']
      rescue Exception => error
        @access_token = nil
      end
    end
  end

  def get_authorization_url
    url = Gatherbox::Application.config.api[@storage.provider][:LOGIN_URI] +
          '/oauth20_authorize.srf' +
          '?client_id=' + Gatherbox::Application.config.api[@storage.provider][:ID] +
          '&scope=' + Gatherbox::Application.config.api[@storage.provider][:OAUTH_SCOPE] +
          '&response_type=code' +
          '&redirect_uri=' + Gatherbox::Application.config.api[@storage.provider][:REDIRECT_URI] +
          '&state=' + "#{@storage.user.authentication_token},#{@storage.user.email}"
    return url
  end

  def authorize(code, state = nil)
    begin
      response = RestClient.post(Gatherbox::Application.config.api[@storage.provider][:LOGIN_URI] + '/oauth20_token.srf',
                                {'client_id' => Gatherbox::Application.config.api[@storage.provider][:ID],
                                 'redirect_uri' => Gatherbox::Application.config.api[@storage.provider][:REDIRECT_URI],
                                 'client_secret' => Gatherbox::Application.config.api[@storage.provider][:SECRET],
                                 'grant_type' => 'authorization_code',
                                 'code' => code})
      json_response = JSON.parse(response)
      @storage.token = json_response['refresh_token']
      @access_token = json_response['access_token']
      return true
    rescue Exception => error
      return false
    end
  end

  def get_account_infos
    result = Hash.new
    begin
      response = @client['/me'].get :params => {'access_token' => @access_token}
      json_response = JSON.parse(response)
      result[:login] = json_response['name']
      response = @client['/me/skydrive/quota'].get :params => {'access_token' => @access_token}
      json_response = JSON.parse(response)
      result[:quota_bytes_total] = json_response['quota']
      result[:quota_bytes_used] = result[:quota_bytes_total].to_i - json_response['available'].to_i
      return 200, result
    rescue => error
      return :unauthorized, result
    end
  end

  def file_get(remote_id)
    remote_id = '/me/skydrive' if remote_id.nil?
    begin
      response = @client[remote_id].get :params => {'access_token' => @access_token}
      return 200, file_resource(JSON.parse(response))
    rescue => error
      return :unauthorized, error.to_s
    end
  end

  def changes(local_item)
    begin
      response = @client[local_item.remote_id + '/files'].get :params => {'access_token' => @access_token}
      json_response = JSON.parse(response)
      result = Hash.new
      status_code, result[local_item.remote_id] = file_get(local_item.remote_id)
      if (status_code != 200)
        result[local_item.remote_id] = nil
        return 200, result
      end

      local_item.children.each do |child|
        result[child.remote_id] = nil
      end

      json_response['data'].each do |child|
        result[child['id']] = file_resource(child)
      end
      return 200, result
    rescue => error
      return :unprocessable_entity, error.to_s
    end
  end

  def delete(remote_id)
    begin
      @client[remote_id].delete :params => {'access_token' => @access_token}
      return 200, 'ok'
    rescue => error
      return :unprocessable_entity, error.to_s
    end
  end

  def patch(remote_id, resources)
  end

  def move(remote_id, old_parent_id, new_parent_id)
    begin
      response = RestClient::Request.execute(:method => 'MOVE',
                                             :url => "https://apis.live.net/v5.0/#{remote_id}",
                                             :headers => {:authorization => "Bearer #{@access_token}"},
                                             :payload => {'destination' => new_parent_id})

      json_response = JSON.parse(response)
      return 200, file_resource(json_response)
    rescue => error
      return :unprocessable_entity, error.to_s
    end
  end

  #TODO impossible to copy a file to the same folder (find a way to do it)
  def copy(remote_id, parent_remote_id, copy_title)
    begin
      response = RestClient::Request.execute(:method => 'COPY',
                                             :url => "https://apis.live.net/v5.0/#{remote_id}",
                                             :headers => {:authorization => "Bearer #{@access_token}"},
                                             :payload => {'destination' => parent_remote_id})

      json_response = JSON.parse(response)
      return 200, file_resource(json_response)
    rescue => error
      return :unprocessable_entity, error.to_s
    end
  end

  def create_folder(title, description, parent_remote_id)
    begin
      response = @client[parent_remote_id].post({'name' => title}, {:authorization => "Bearer #{@access_token}"})
      json_response = JSON.parse(response)
      puts json_response
      return 200, file_resource(json_response)
    rescue => error
      return :unprocessable_entity, error.to_s
    end
  end

  #TODO PUT verb is probably bugged - replace PUT by POST
  def upload_file(parent_remote_id, title, mime_type, file_path)
    puts "UPLOADING '#{title}' to #{parent_remote_id} with mimetype '#{mime_type}' and path '#{file_path}' or size #{File.size(file_path)}"
    begin
      response = @client["#{parent_remote_id}/files/#{title}"].put(File.read(file_path), {:authorization => "Bearer #{@access_token}", :content_type => '', 'Content-Length' => File.size(file_path)})
      json_response = JSON.parse(response)
      puts json_response
      return 200, file_resource(json_response)
    rescue => error
      return :unprocessable_entity, error.to_s
    end
  end

  #TODO transform type into mimetype
  def file_resource(data)
    result = Hash.new
    result[:remote_id] = data['id']
    result[:parent_remote_id] = data['parent_id']
    result[:mimeType] = data['type']
    result[:fileSize] = data['size']
    result[:createdDate] = data['created_time']
    result[:modifiedDate] = data['updated_time']
    result[:title] = data['name']
    result[:description] = data['description']
    result[:remote_link] = data['link']
    return result
  end
end