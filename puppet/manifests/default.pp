# Basic Puppet manifest

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class system-update {

  exec { 'apt-get update':
    command => 'apt-get update',
  }

  $sysPackages = [ "build-essential" ]
  package { $sysPackages:
    ensure => "installed",
    require => Exec['apt-get update'],
  }
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

  exec { "restart-php5-fpm":
    command  => "service php5-fpm restart",
    schedule => hourly
  }

  php::fpm::pool { 'www': user => 'vagrant' }

}

class { 'php::phpunit':
  ensure => latest
}

Exec["apt-get update"] -> Package <| |>

include system-update

include apache-setup
include '::mysql::server'

include 'roles::php'
include 'roles::php_fpm'
