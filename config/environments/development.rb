Gatherbox::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  #
  # Configuration for remote APIs
  #
  config.api = Hash.new

  # Google Drive
  config.api['google_drive'] = {
      :PROVIDER => 'Google Drive',
      :ID => '1021604253204-s819al729qs968ifdph51mpgefbpn8sr.apps.googleusercontent.com',
      :SECRET => 'Pr0t21clrTOBwBcjyWmLHrUZ',
      :OAUTH_SCOPE => 'https://www.googleapis.com/auth/drive', #, 'https://www.googleapis.com/auth/userinfo.email']
      :REDIRECT_URI => 'http://localhost:3000/storages/link_account/google_drive',
      :ROOT => 'root',
      :CLASS => 'GoogleDriveController'
  }

  # Dropbox
  config.api['dropbox'] = {
      :PROVIDER => 'dropbox',
      :ID => 'v3hc20relbafs8p',
      :SECRET => 'dhi1301p0ojj1sr',
      :REDIRECT_URI => 'http://localhost:3000/storages/link_account/dropbox',
      :ROOT => '/',
      :CLASS => 'DropboxController'
  }

  # SkyDrive
  config.api['skydrive'] = {
      :API_URI => 'https://apis.live.net/v5.0',
      :LOGIN_URI => 'https://login.live.com',
      :PROVIDER => 'skydrive',
      :ID => '000000004011C6F9',
      :SECRET => 'TqgQiUr-1v96RgfnTeXNYt9wkvBGmM9I',
      :OAUTH_SCOPE => 'wl.skydrive wl.skydrive_update wl.offline_access',
      :REDIRECT_URI => 'http://www.gatherbox.com:3000/storages/link_account/skydrive',
      :CLASS => 'SkyDriveController'
  }
end
