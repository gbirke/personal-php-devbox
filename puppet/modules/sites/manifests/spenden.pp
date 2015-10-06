class sites::spenden {

  include sites::params

  apache::vhost { 'spenden.wikimedia.dev':
   docroot  => '/vagrant/www/fundraising',
   template => 'sites/vhost_php.conf.erb',
 }

 mysql::db { 'fundraising':
   user => "${sites::params::db_user}",
   password =>  "${sites::params::db_pass}",
   host => 'localhost',
   grant =>  "${sites::params::db_grant}"
 }

}
