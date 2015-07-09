# Personal PHP development box

Vagrant file and puppet deployment for my personal PHP development box at Wikimedia DE.

At the moment, everything is very rudimentary and uses lots of defaults. I try too keep the master branch free of project-specific stuff. See the wikimedia branch for examples for vhosts.

## Installation
* Install vagrant using the installation instructions in the [Getting Started document](http://vagrantup.com/v1/docs/getting-started/index.html)
* Clone this repository
* Install submodules with ```git submodule update --init```
* After running ```vagrant up``` the box is set up using Puppet
* Look at the "sites" class, check out the code in the `www` directory and run `vagrant provision`.
* Set up your hosts file or a tool like dnsmasq to connect vhost name on the virtual machine to the dns service of your host mache. See http://passingcuriosity.com/2013/dnsmasq-dev-osx/ for dnsmasq setup on Mac OS X.
* Open the address http://de.wikimedia.dev/ in your browser.

## Installed components
* [PHP](https://github.com/jippi/puppet-php.git)
* [MySQL](https://github.com/puppetlabs/puppetlabs-mysql.git)
* [Apache](https://github.com/example42/puppet-apache.git)
