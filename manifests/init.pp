class postfix (
    $append_dot_mydomain = $postfix::params::append_dot_mydomain_default,
    $biff = $postfix::params::biff_default,
    $generatecert = $postfix::params::generatecert_default,
    $inetinterfaces = $postfix::params::inetinterfaces_default,
    $ipv6 = $postfix::params::ipv6_default,
    $mail_spool_directoryi = $postfix::params::mail_spool_directory_default,
    $mydestination = $postfix::params::mydestination_default,
    $mydomain = $postfix::params::mydomain_default,
    $myhostname = $postfix::params::myhostname_default,
    $mynetworks = $postfix::params::mynetworks_default,
    $myorigin = $postfix::params::myorigin_default,
    $opportunistictls = $postfix::params::opportunistictls_default,
    $readme_directory = $postfix::params::readme_directory_default,
    $recipient_delimiter = $postfix::params::recipient_delimiter_default,
    $relayhost = $postfix::params::relayhost_default,
    $smtpdbanner = $postfix::params::smtpdbanner_default,
    $subjectselfsigned = $postfix::params::subjectselfsigned_default,
    $tlscert = $postfix::params::tlscert_default,
    $tlspk = $postfix::params::tlspk_default,
    $virtual_alias = $postfix::params::virtual_alias_default,
    ) inherits postfix::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if($virtual_alias)
  {
    validate_hash($virtual_alias)
  }

  validate_array($mynetworks)

  if($biff)
  {
    validate_string($biff)
  }

  if($append_dot_mydomain)
  {
    validate_string($append_dot_mydomain)
  }

  validate_string($readme_directory)

  validate_string($myorigin)

  validate_string($mydomain)

  if($recipient_delimiter)
  {
    validate_string($recipient_delimiter)
  }

  validate_array($mydestination)

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
          command => "/usr/bin/openssl req -new -key /etc/pki/tls/private/postfix-key.key -subj '${subjectselfsigned}' | /usr/bin/openssl x509 -req -days 10000 -signkey /etc/pki/tls/private/postfix-key.key -out /etc/pki/tls/certs/postfix.pem",
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
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => Package['openssl'],
          notify  => Service['postfix'],
          audit   => 'content',
          source  => $tlspk
        }

        file { '/etc/pki/tls/certs/postfix.pem':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => Package['openssl'],
          notify  => Service['postfix'],
          audit   => 'content',
          source  => $tlscert
        }
      }
    }
  }

  package { $postfix::params::dependencies:
    ensure => installed,
  }

  package { 'postfix':
    ensure => 'installed',
  }

  file { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['postfix'],
    notify  => Service['postfix'],
    content => template("${module_name}/main.cf.erb")
  }

  service { 'postfix':
    ensure  => 'running',
    enable  => true,
    require => Package['postfix'],
  }

  if($postfix::params::switch_to_postfix)
  {
    exec { 'switch_mta_to_postfix':
      command => $postfix::params::switch_to_postfix,
      unless  => $postfix::params::check_postfix_mta,
      require => [Package[$postfix::params::dependencies], Package['postfix']],
    }
  }

  if($virtual_alias)
  {

    exec { 'postmap virtual':
      command => "postmap ${postfix::params::baseconf}/virtual",
      creates => "${postfix::params::baseconf}/virtual.db",
      require => [ File["${postfix::params::baseconf}/virtual"], Package['postfix'] ],
    }

    file { "${postfix::params::baseconf}/virtual":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['postfix'],
      notify  => Service['postfix'],
      content => template("${module_name}/virtual_alias/virtual_alias.erb"),
      }
  }

}
