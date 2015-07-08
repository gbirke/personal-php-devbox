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

Exec["apt-get update"] -> Package <| |>

include system-update

include apache-setup
include '::mysql::server'
