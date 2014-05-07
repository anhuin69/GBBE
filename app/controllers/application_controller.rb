class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = 'authorization'
    head(:ok) if request.request_method == 'OPTIONS'
  end

  protected
  def authenticate
    if params.key?(:state) && !request.env.key?('HTTP_AUTHORIZATION')
      state = params[:state]
      if (params.key?(:format) && params[:format] == 'dropbox' && (idx = state.index('|')) != nil)
        state = state[(idx + 1)..-1]
        params[:state] = params[:state][0..(idx - 1)]
      end
      request.env['HTTP_AUTHORIZATION'] = "Token #{state}"
    end
    authenticate_or_request_with_http_token do |token_email, options|
      unless ((idx = token_email.index(',')).nil? || idx <= 0)
        token = token_email[0..(idx - 1)]
        email = token_email[(idx + 1)..-1]
        @user = User.find_by(:email => email.strip, :authentication_token => token.strip)
        @user != nil && @user != false
      end
    end
  end

  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    error = {}
    error[parameter_missing_exception.param] = ['parameter is required']
    response = { errors: error }
    render json: response, status: :unprocessable_entity
  end

end
