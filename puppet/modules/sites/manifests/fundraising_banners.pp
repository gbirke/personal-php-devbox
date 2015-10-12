class sites::fundraising_banners {

  include sites::params

  apache::vhost { 'banners.wikimedia.dev':
   serveraliases => 'banner.wikimedia.dev',
   docroot  => '/vagrant/www/FundraisingBanners',
   template => 'sites/vhost_php.conf.erb',
 }

}
