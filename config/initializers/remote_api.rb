#
# Configuration for remote APIs
#
Gatherbox::Application.config.api = Hash.new

# Google Drive
Gatherbox::Application.config.api['google_drive'] = {
    :PROVIDER => 'Google Drive',
    :ID => '1021604253204-s819al729qs968ifdph51mpgefbpn8sr.apps.googleusercontent.com',
    :SECRET => 'Pr0t21clrTOBwBcjyWmLHrUZ',
    :OAUTH_SCOPE => 'https://www.googleapis.com/auth/drive', #, 'https://www.googleapis.com/auth/userinfo.email']
    :REDIRECT_URI => 'http://localhost:3000/storages/link_account/google_drive',
    :ROOT => 'root',
    :CLASS => 'GoogleDriveController'
}

# Dropbox
Gatherbox::Application.config.api['dropbox'] = {
    :PROVIDER => 'dropbox',
    :ID => 'v3hc20relbafs8p',
    :SECRET => 'dhi1301p0ojj1sr',
    :REDIRECT_URI => 'http://localhost:3000/storages/link_account/dropbox',
    :ROOT => '/',
    :CLASS => 'DropboxController'
}

# SkyDrive
Gatherbox::Application.config.api['skydrive'] = {
    :API_URI => 'https://apis.live.net/v5.0',
    :LOGIN_URI => 'https://login.live.com',
    :PROVIDER => 'skydrive',
    :ID => '000000004011C6F9',
    :SECRET => 'TqgQiUr-1v96RgfnTeXNYt9wkvBGmM9I',
    :OAUTH_SCOPE => 'wl.skydrive wl.skydrive_update wl.offline_access',
    :REDIRECT_URI => 'http://www.gatherbox.com:3000/storages/link_account/skydrive',
    :CLASS => 'SkyDriveController'
}