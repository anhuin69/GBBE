class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  protected
  def authenticate
    authenticate_or_request_with_http_token do |token_email, options|
      unless ((idx = token_email.index(',')).nil? || idx <= 0)
        token = token_email[0..(idx - 1)]
        email = token_email[(idx + 1)..-1]
        User.find_by(:email => email.strip, :authentication_token => token.strip)
      end
    end
  end

end
