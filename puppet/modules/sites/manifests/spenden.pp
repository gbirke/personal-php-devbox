class sites::spenden {
  apache::vhost { 'spenden.wikimedia.dev':
   docroot  => '/vagrant/www/spenden',
   template => '/vagrant/conf/apache/vhost.conf.erb',
 }
}
