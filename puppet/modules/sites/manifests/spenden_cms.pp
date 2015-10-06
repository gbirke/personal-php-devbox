class sites::spenden_cms {

  include sites::params

  apache::vhost { 'cms.wikimedia.dev':
   docroot  => '/vagrant/www/spenden_cms',
   template => 'sites/vhost_php.conf.erb',
 }

 mysql::db { 'spenden_cms':
   user => "${sites::params::db_user}",
   password =>  "${sites::params::db_pass}",
   host => 'localhost',
   grant =>  "${sites::params::db_grant}"
 }
}
