# Personal PHP development box

Vagrant file and puppet deployment for my personal PHP development box.
I was first trying [dirkaholic/vagrant-php-dev-box](https://github.com/dirkaholic/vagrant-php-dev-box), but was disappointed with the old version of Ubuntu and PHP. So I built my own, with PHP 5.5 and Ubuntu 14.04 LTS (Trusty Tahr).

At the moment, everything is very rudimentary and uses lots of defaults. I try too keep the master branch free of project-specific stuff. See the wikimedia branch for examples for vhosts.

## Installation
* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* Clone this repository
* Install submodules with ```git submodule update --init```
* After running ```vagrant up``` the box is set up using Puppet
* Set up your vhosts for your projects and run `vagrant provision`.
* Set up your hosts file or a tool like dnsmasq to connect vhost name on the virtual machine to the dns service of your host mache. See http://passingcuriosity.com/2013/dnsmasq-dev-osx/ for dnsmasq setup on Mac OS X.
* Open the vhost address in your browser.

## Installed components
* [PHP](https://github.com/jippi/puppet-php.git)
* [MySQL](https://github.com/puppetlabs/puppetlabs-mysql.git)
* [Apache](https://github.com/example42/puppet-apache.git)
