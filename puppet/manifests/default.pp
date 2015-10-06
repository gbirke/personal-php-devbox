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

class development-essentials {

  $devPackages = [ "git", "vim", "curl" ]
  ensure_packages($devPackages)

  $gitConfigLocation = "/home/vagrant/.gitconfig"
  exec { 'install-git-config':
    command => "wget -O ${gitConfigLocation} https://gist.github.com/raw/1082842/.gitconfig",
    creates => $gitConfigLocation,
    user => "vagrant",
  }

  $vimConfigLocation = "/home/vagrant/.vimrc"
  exec { 'install-vim-config':
    command => "wget -O ${vimConfigLocation} https://gist.github.com/raw/913899/.vimrc",
    creates => $vimConfigLocation,
    user => "vagrant",
  }

  ohmyzsh::install { 'vagrant': }
  ohmyzsh::theme   { 'vagrant': theme => 'robbyrussell' }
  ohmyzsh::plugins { 'vagrant': plugins => 'git github git-flow composer' }

  $aliasConfig = "/home/vagrant/.oh-my-zsh/custom/aliases.zsh"
  exec { 'install-aliases-for-zsh':
    command => "wget -O ${aliasConfig} https://gist.github.com/raw/1267907/.alias",
    creates => $aliasConfig,
    user => "vagrant",
  }

  ensure_packages(["ack-grep"])
  file { '/usr/bin/ack':
    ensure => 'link',
    target => '/usr/bin/ack-grep'
  }

  # TODO https://github.com/jvz/psgrep

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

  # hack for xdebug
  $install_dir = "/usr/lib/php5/${::php_extension_version}"
  class {
    # Base packages
    [ 'php::dev', 'php::cli' ]:
      ensure => $version;

    # PHP extensions
    [
      'php::extension::curl', 'php::extension::gd', 'php::extension::imagick',
      'php::extension::mcrypt', 'php::extension::mysql',
    ]:
      ensure => $version;

    [ 'php::extension::igbinary' ]:
      ensure => installed;

    [ 'php::extension::xdebug' ]:
      ensure => "installed",
      settings => [
        "set .anon/zend_extension '${install_dir}/xdebug.so'", # any better way to override this?
        "set .anon/xdebug.remote_enable on",
        "set .anon/xdebug.remote_connect_back on",
        "set .anon/xdebug.idekey 'netbeans-xdebug'",
      ];
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

class { 'ohmyzsh': }

include system-update

include apache-setup
include '::mysql::server'

include 'roles::php'
include 'roles::php_fpm'
#TODO install other PHP QA and documentation tools

include development-essentials
