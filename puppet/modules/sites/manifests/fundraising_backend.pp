class sites::fundraising_backend {

  include sites::params

  apache::vhost { 'fundraising-backend.wikimedia.dev':
   docroot  => '/vagrant/www/fundraising-backend',
   template => 'sites/vhost_php.conf.erb',
 }

}
