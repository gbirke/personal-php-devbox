# Basic Puppet manifest

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

class system-update {

  exec { 'apt-get update':
    command => 'apt-get update',
  }

  $sysPackages = [ 'build-essential' ]
  package { $sysPackages:
    ensure => 'installed',
    require => Exec['apt-get update'],
  }
}

class development-essentials {

  $devPackages = [ 'git', 'vim', 'curl' ]
  package { $devPackages:
    ensure => 'installed'
  }

  # TODO https://forge.puppetlabs.com/acme/ohmyzsh
  # TODO download git and vim config
  # TODO install ack-grep package and alias to 'ack command'
  # TODO https://code.google.com/p/psgrep/

}

class apache-setup {

    include apache

    apache::module { 'proxy': }
    apache::module { 'proxy_fcgi': }
}

class roles::php($version = 'installed') {

  include php
  include php::params
  include php::pear
  include php::composer
  include php::composer::auto_update


  # Extensions must be installed before they are configured
  Php::Extension <| |> -> Php::Config <| |>

  # Ensure base packages is installed in the correct order
  # and before any php extensions
  Package['php5-common']
    -> Package['php5-dev']
    -> Package['php5-cli']
    -> Php::Extension <| |>

  class {
    # Base packages
    [ 'php::dev', 'php::cli' ]:
      ensure => $version;

    # PHP extensions
    [
      'php::extension::curl', 'php::extension::gd', 'php::extension::imagick',
      'php::extension::mcrypt', 'php::extension::mysql',
      'php::extension::redis',
    ]:
      ensure => $version;

    [ 'php::extension::igbinary' ]:
      ensure => installed
  }

  # Install the INTL extension
  php::extension { 'php5-intl':
    ensure    => $version,
    package   => 'php5-intl',
    provider  => 'apt'
  }

  create_resources('php::config', hiera_hash('php_config', {}))
  create_resources('php::cli::config', hiera_hash('php_cli_config', {}))

}

class roles::php_fpm($version = 'installed') {

  include php
  include php::params

  class { 'php::fpm':
    ensure => $version,
    emergency_restart_threshold  => 5,
    emergency_restart_interval   => '1m',
    rlimit_files                 => 32768,
    events_mechanism             => 'epoll'
  }

  create_resources('php::fpm::pool',  hiera_hash('php_fpm_pool', {}))
  create_resources('php::fpm::config',  hiera_hash('php_fpm_config', {}))

  Php::Extension <| |> ~> Service['php5-fpm']

  exec { 'restart-php5-fpm':
    command  => 'service php5-fpm restart',
    schedule => hourly
  }

  php::fpm::pool { 'www': user => 'vagrant' }

}

class sites {

  $global_db_user = 'webuser'
  $global_db_pass = 'password123'
  $global_db_grant = ['ALL']
  apache::vhost { 'spenden.wikimedia.dev':
   docroot  => '/vagrant/www/spenden',
   template => '/vagrant/conf/apache/vhost.conf.erb',
 }

  apache::vhost { 'de.wikimedia.dev':
    docroot  => '/vagrant/www/mediawiki',
    template => '/vagrant/conf/apache/vhost.conf.erb',
  }
  mysql::db { 'mediawiki':
    user => $global_db_user,
    password => $global_db_pass,
    host => 'localhost',
    grant => $global_db_grant
  }
  elasticsearch::instance { 'es-01':
    config => {
      'node.name' => 'elasticsearch01',
      'script.disable_dynamic' => false,
      'network.host' => '127.0.0.1',
      'script.groovy.sandbox.class_whitelist' => [
          # Defaults
          'java.util.Date',
          'java.util.Map',
          'java.util.List',
          'java.util.Set',
          'java.util.ArrayList',
          'java.util.Arrays',
          'java.util.HashMap',
          'java.util.HashSet',
          'java.util.UUID',
          'java.math.BigDecimal',
          'org.joda.time.DateTime',
          'org.joda.time.DateTimeZone',
          'org.elasticsearch.common.joda.time.DateTime',
          'org.elasticsearch.common.joda.time.DateTimeZone',
          # Added for Cirrus
          'java.util.Locale',
          'org.apache.lucene.util.automaton.RegExp',
          'org.apache.lucene.util.automaton.CharacterRunAutomaton'
      ],
      'script.groovy.sandbox.package_whitelist' => [
          # Defaults
          'java.util',
          'java.lang',
          'org.joda.time',
          'org.elasticsearch.common.joda.time',
          # Added for Cirrus
          'org.apache.lucene.util.automaton'
      ],
      'script.groovy.sandbox.receiver_whitelist' => [
          # Defaults
          'java.lang.Math',
          'java.lang.Integer',
          '"[I"',
          '"[[I"',
          '"[[[I"',
          'java.lang.Float',
          '"[F"',
          '"[[F"',
          '"[[[F"',
          'java.lang.Double',
          '"[D"',
          '"[[D"',
          '"[[[D"',
          'java.lang.Long',
          '"[J"',
          '"[[J"',
          '"[[[J"',
          'java.lang.Short',
          '"[S"',
          '"[[S"',
          '"[[[S"',
          'java.lang.Character',
          '"[C"',
          '"[[C"',
          '"[[[C"',
          'java.lang.Byte',
          '"[B"',
          '"[[B"',
          '"[[[B"',
          'java.lang.Boolean',
          '"[Z"',
          '"[[Z"',
          '"[[[Z"',
          'java.math.BigDecimal',
          'java.math.BigDecimal',
          'java.util.Arrays',
          'java.util.Date',
          'java.util.List',
          'java.util.Map',
          'java.util.Set',
          'java.lang.Object',
          'org.joda.time.DateTime',
          'org.joda.time.DateTimeUtils',
          'org.joda.time.DateTimeZone',
          'org.joda.time.Instant',
          'org.elasticsearch.common.joda.time.DateTime',
          'org.elasticsearch.common.joda.time.DateTimeUtils',
          'org.elasticsearch.common.joda.time.DateTimeZone',
          'org.elasticsearch.common.joda.time.Instant',
          # Added for Cirrus
          'org.apache.lucene.util.automaton.RegExp',
          'org.apache.lucene.util.automaton.CharacterRunAutomaton'
      ]
    }
  }

}

Exec['apt-get update'] -> Package <| |>

include system-update

include apache-setup
include '::mysql::server'

include 'roles::php'
include 'roles::php_fpm'
#TODO install other PHP QA and documentation tools

include development-essentials

class { 'php::phpunit':
  ensure => latest
}

# Install Elasticsearch
class { 'elasticsearch':
  autoupgrade => true,
  manage_repo  => true,
  repo_version => '1.4',
  java_install => true
}


include sites
