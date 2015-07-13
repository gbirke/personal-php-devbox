# == Class: sites::params
#
class sites::params {
  $db_user = 'webuser'
  $db_pass = 'password123'
  $db_grant = ['ALL']
}
