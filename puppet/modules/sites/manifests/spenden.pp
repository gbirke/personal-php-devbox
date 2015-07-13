class sites::spenden {
  apache::vhost { 'spenden.wikimedia.dev':
   docroot  => '/vagrant/www/spenden',
   template => 'sites/vhost_php.conf.erb',
 }
}
