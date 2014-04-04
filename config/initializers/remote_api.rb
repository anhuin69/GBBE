#
# Configuration for remote APIs
#
Gatherbox::Application.config.api = Hash.new
Gatherbox::Application.config.api['google_drive'] = {
    :PROVIDER => 'Google Drive',
    :ID => '1021604253204-s819al729qs968ifdph51mpgefbpn8sr.apps.googleusercontent.com',
    :SECRET => 'Pr0t21clrTOBwBcjyWmLHrUZ',
    :OAUTH_SCOPE => 'https://www.googleapis.com/auth/drive',
    :REDIRECT_URI => 'http://localhost:3000/storages/link_account',
    :ROOT => 'root'
}
Gatherbox::Application.config.api['dropbox'] = {
    :PROVIDER => 'dropbox',
    :ID => 'v3hc20relbafs8p',
    :SECRET => 'dhi1301p0ojj1sr',
    :REDIRECT_URI => 'http://localhost:3000/storages/dropbox_oauth2/callback',
    :ROOT => '/'
}

# TODO: maybe to remove
#Gatherbox::Application.config.GoogleDrive = {
#    :PROVIDER => 'google_drive',
#    :ID => '1021604253204-s819al729qs968ifdph51mpgefbpn8sr.apps.googleusercontent.com',
#    :SECRET => 'Pr0t21clrTOBwBcjyWmLHrUZ',
#    :OAUTH_SCOPE => 'https://www.googleapis.com/auth/drive',
#    :REDIRECT_URI => 'http://localhost:3000/storages/google_oauth2/callback'
#}

#Gatherbox::Application.config.Dropbox = {
#    :PROVIDER => 'dropbox',
#    :ID => 'v3hc20relbafs8p',
#    :SECRET => 'dhi1301p0ojj1sr',
#    :REDIRECT_URI => 'http://localhost:3000/storages/dropbox_oauth2/callback'
#}


