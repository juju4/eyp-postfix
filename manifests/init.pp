class postfix (
    $append_dot_mydomain                 = $postfix::params::append_dot_mydomain_default,
    $biff                                = $postfix::params::biff_default,
    $generatecert                        = $postfix::params::generatecert_default,
    $inetinterfaces                      = $postfix::params::inetinterfaces_default,
    $ipv6                                = $postfix::params::ipv6_default,
    $mail_spool_directory                = $postfix::params::mail_spool_directory_default,
    $mydestination                       = $postfix::params::mydestination_default,
    $mydomain                            = $postfix::params::mydomain_default,
    $myhostname                          = $postfix::params::myhostname_default,
    $mynetworks                          = $postfix::params::mynetworks_default,
    $myorigin                            = $postfix::params::myorigin_default,
    $opportunistictls                    = $postfix::params::opportunistictls_default,
    $readme_directory                    = $postfix::params::readme_directory_default,
    $recipient_delimiter                 = $postfix::params::recipient_delimiter_default,
    $relayhost                           = $postfix::params::relayhost_default,
    $relayhost_mx_lookup                 = $postfix::params::relayhost_mx_lookup_default,
    $smtpdbanner                         = $postfix::params::smtpdbanner_default,
    $subjectselfsigned                   = $postfix::params::subjectselfsigned_default,
    $tlscert                             = $postfix::params::tlscert_default,
    $tlspk                               = $postfix::params::tlspk_default,
    $virtual_alias                       = $postfix::params::virtual_alias_default,
    $install_mailclient                  = $postfix::params::install_mailclient_default,
    $default_process_limit               = $postfix::params::default_process_limit_default,
    $smtpd_client_connection_count_limit = $postfix::params::smtpd_client_connection_count_limit_default,
    $smtpd_client_connection_rate_limit  = $postfix::params::smtpd_client_connection_rate_limit_default,
    $in_flow_delay                       = $postfix::params::in_flow_delay_default,
    $setgid_group                        = $postfix::params::setgid_group_default,
    $smtp_fallback_relay                 = $postfix::params::smtp_fallback_relay_default,
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
    validate_bool($biff)
  }

  if($append_dot_mydomain)
  {
    validate_bool($append_dot_mydomain)
  }

  if($readme_directory)
  {
    validate_string($readme_directory)
  }

  validate_string($myorigin)

  validate_string($mydomain)

  if($recipient_delimiter)
  {
    validate_string($recipient_delimiter)
  }

  validate_array($mydestination)

  if($smtp_fallback_relay!=undef)
  {
    validate_array($smtp_fallback_relay)
  }

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
          notify  => Class['postfix::service'],
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
          notify  => Class['postfix::service'],
          audit   => 'content',
          source  => $tlspk
        }

        file { '/etc/pki/tls/certs/postfix.pem':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => Package['openssl'],
          notify  => Class['postfix::service'],
          audit   => 'content',
          source  => $tlscert
        }
      }
    }
  }

  if($install_mailclient)
  {
    package { $postfix::params::mailclient:
      ensure => 'installed',
      before => Package['postfix'],
    }
  }

  if($postfix::params::purge_default_mta!=undef)
  {
    package { $postfix::params::purge_default_mta:
      ensure  => 'absent',
      require => Package['postfix'],
    }
  }

  package { 'postfix':
    ensure => 'installed',
  }

  # TODO: to concat
  file { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['postfix'],
    notify  => Class['postfix::service'],
    content => template("${module_name}/main.cf.erb")
  }

  class { 'postfix::service':
    ensure         => 'running',
    enable         => true,
    manage_service => true,
  }

  if($postfix::params::switch_to_postfix)
  {
    exec { 'switch_mta_to_postfix':
      command => $postfix::params::switch_to_postfix,
      unless  => $postfix::params::check_postfix_mta,
      require => Package['postfix'],
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
      notify  => Class['postfix::service'],
      content => template("${module_name}/virtual_alias/virtual_alias.erb"),
      }
  }

  #postmap /etc/postfix/transport
  exec { 'reload postfix transport':
    command     => 'postmap /etc/postfix/transport',
    refreshonly => true,
    notify      => Class['postfix::service'],
  }

  concat { '/etc/postfix/transport':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['postfix'],
    notify  => Exec['reload postfix transport'],
  }

  concat::fragment{ '/etc/postfix/transport header':
    target  => '/etc/postfix/transport',
    order   => '00',
    content => template("${module_name}/transport/header.erb"),
  }

}
