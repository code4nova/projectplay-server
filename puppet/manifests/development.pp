stage { 'req-install': before => Stage['rvm-install'] }

class requirements {
  group { "puppet": ensure => "present", }
  exec { "apt-update":
    command => "/usr/bin/apt-get -y update"
  }

  package {
    ["postgresql", "libpq-dev","nodejs" ]: 
      ensure => installed, require => Exec['apt-update']
  }
}

class installrvm {
  include rvm
  rvm::system_user { vagrant: ; }

  if $rvm_installed == "true" {
    rvm_system_ruby {
      'ruby-1.9.3-p194':
        ensure => 'present';
    }
  }
}

class doinstall {
  class { requirements:, stage => "req-install" }
  include installrvm
}

include doinstall
