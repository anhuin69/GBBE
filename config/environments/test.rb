Gatherbox::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_assets  = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.secret_key_base = 'a9e46d31eff5e9799a310670cd5b9b49c39694fe9ac9c3c417a476f6e230e0980c432da9db237509866badf6048fa9622deac1eab6d5ac713b2bbde0d5ff0765'

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
