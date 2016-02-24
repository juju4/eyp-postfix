# == Class: postfix
#
# Full description of class postfix here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'postfix':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class postfix (
    $mynetworks = [ '127.0.0.1' ],
    $inetinterfaces = '127.0.0.1',
    $smtpdbanner = '$myhostname ESMTPi $mail_name',
    $ipv6=false,
    $relayhost=undef,
    $opportunistictls=false,
    $tlscert=undef,
    $tlspk=undef,
    $myhostname=undef,
    $generatecert=false,
    $subjectselfsigned=undef,
    )
    inherits postfix::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  validate_array($mynetworks)

  if($tlscert) or ($tlspk) or ($opportunistictls)
  {

    exec { 'postfix mkdir /etc/pki/tls/private':
      command => 'mkdir -p /etc/pki/tls/private',
      creates => '/etc/pki/tls/private',
    }

    exec { 'postfix mkdir /etc/pki/tls/certs':
      command => 'mkdir -p /etc/pki/tls/certs',
      creates => '/etc/pki/tls/certs',
    }

    package { 'openssl':
      ensure  => 'installed',
      require => Exec[ ['postfix mkdir /etc/pki/tls/certs', 'postfix mkdir /etc/pki/tls/certs' ] ]
    }

    if($generatecert)
    {
      if($subjectselfsigned)
      {
        exec { 'openssl pk':
          command => '/usr/bin/openssl genrsa -out /etc/pki/tls/private/postfix-key.key 2048',
          creates => '/etc/pki/tls/private/postfix-key.key',
          require => Package['openssl'],
        }

        exec { 'openssl cert':
          command => "/usr/bin/openssl req -new -key /etc/pki/tls/private/postfix-key.key -subj '$subjectselfsigned' | /usr/bin/openssl x509 -req -days 10000 -signkey /etc/pki/tls/private/postfix-key.key -out /etc/pki/tls/certs/postfix.pem",
          creates => '/etc/pki/tls/certs/postfix.pem',
          notify  => Service['postfix'],
          require => Exec['openssl pk'],
        }
      }
      else
      {
        fail('to generate a selfsigned certificate I need a subject (variable subjectselfsigned)')
      }
    }
    else
    {
      if ($subjectselfsigned)
      {
        fail('you need to enable selfsigned certificates using the variable generatecert')
      }

      if($tlscert==undef) or ($tlspk==undef) or ($opportunistictls==undef)
      {
        fail("everytime you forget required a TLS file, God kills a kitten - OTLS(${opportunistictls}) - CERT(${tlscert}) - KEY(${tlspk}) - please think of the kittens")
      }
      else
      {
        file { '/etc/pki/tls/private/postfix-key.key':
          ensure  => present,
          owner   => "root",
          group   => "root",
          mode    => 0644,
          require => Package['openssl'],
          notify  => Service["postfix"],
          audit   => 'content',
          source  => $tlspk
        }

        file { '/etc/pki/tls/certs/postfix.pem':
          ensure  => present,
          owner   => "root",
          group   => "root",
          mode    => 0644,
          require => Package['openssl'],
          notify  => Service["postfix"],
          audit   => 'content',
          source  => $tlscert
        }
      }
    }
  }

  package { $dependencies:
    ensure => installed,
  }

  package { 'postfix':
    ensure => 'installed',
  }

  file { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Package['postfix'],
    notify  => Service['postfix'],
    content => template("${module_name}/main.cf.erb")
  }

  service { 'postfix':
    enable  => true,
    ensure  => "running",
    require => Package["postfix"],
  }

  if($switch_to_postfix)
  {
    exec { 'switch_mta_to_postfix':
      command => $switch_to_postfix,
      unless  => $check_postfix_mta,
      require => [Package[$dependencies], Package['postfix']],
    }
  }

}
