class sites::attribution {
  $docroot = '/vagrant/www/attribution'

  apache::vhost { 'attribution.wikimedia.dev':
   docroot  => $docroot,
   template => 'sites/vhost_basic_html.conf.erb'
 }

 # Now clone git@github.com:wmde/Lizenzverweisgenerator.git

}
