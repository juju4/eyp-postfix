# multidomain mailserver
# https://www.rosehosting.com/blog/mailserver-with-virtual-users-and-domains-using-postfix-and-dovecot-on-a-centos-6-vps/
#
# concat main.cf
#
# 00 - base
# 01 - transport
# 50 - vmail
# 51 - virtual aliases
# 52 - virtual_mailbox_maps
# 53 - virtual domains
# 54 - SASL
# 55 - smtpd restrictions
# 60 - content filter
# 61 - sender_canonical_maps
#
###
#
# concat master.cf
#
# 00 - header
# 01 - smtp default
# 02 - other defaults
#
class postfix (
    $append_dot_mydomain                 = $postfix::params::append_dot_mydomain_default,
    $biff                                = $postfix::params::biff_default,
    $generatecert                        = $postfix::params::generatecert_default,
    $inetinterfaces                      = $postfix::params::inetinterfaces_default,
    $ipv6                                = $postfix::params::ipv6_default,
    $mail_spool_directory                = $postfix::params::mail_spool_directory_default,
    $mydestination                       = $postfix::params::mydestination_default,
    $mydomain                            = $::domain,
    $myhostname                          = $postfix::params::myhostname_default,
    $mynetworks                          = $postfix::params::mynetworks_default,
    $myorigin                            = $::domain,
    $opportunistictls                    = $postfix::params::opportunistictls_default,
    $readme_directory                    = $postfix::params::readme_directory_default,
    $recipient_delimiter                 = $postfix::params::recipient_delimiter_default,
    $relayhost                           = $postfix::params::relayhost_default,
    $relayhost_mx_lookup                 = $postfix::params::relayhost_mx_lookup_default,
    $smtpdbanner                         = $postfix::params::smtpdbanner_default,
    $subjectselfsigned                   = $postfix::params::subjectselfsigned_default,
    $tlscert                             = $postfix::params::tlscert_default,
    $tlspk                               = $postfix::params::tlspk_default,
    $install_mailclient                  = $postfix::params::install_mailclient_default,
    $default_process_limit               = $postfix::params::default_process_limit_default,
    $smtpd_client_connection_count_limit = $postfix::params::smtpd_client_connection_count_limit_default,
    $smtpd_client_connection_rate_limit  = $postfix::params::smtpd_client_connection_rate_limit_default,
    $in_flow_delay                       = $postfix::params::in_flow_delay_default,
    $setgid_group                        = $postfix::params::setgid_group_default,
    $smtp_fallback_relay                 = undef,
    $unknown_local_recipient_reject_code = '550',
    $postfix_username                    = 'postfix',
    $postfix_username_uid                = $postfix_username_uid_default,
    $postfix_username_gid                = $postfix_username_gid_default,
    $home_mailbox                        = 'Maildir/',
    $add_default_smtpd_instance          = true,
    $service_ensure                      = 'running',
    $service_enable                      = true,
    $manage_mastercf                     = $postfix::params::manage_mastercf_default,
    $resolve_null_domain                 = true,
    $alias_maps                          = '/etc/aliases',
    $debug_peer_level                    = '2',
    $debug_peer_list                     = undef,
    $smtpd_verbose                       = false,
    $syslog_name                         = undef,
    $daemon_directory                    = $postfix::params::daemon_directory_default,
    ) inherits postfix::params {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
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

  validate_re($home_mailbox, [ '^Maildir/$', '^Mailbox$', '^$' ], 'Not a supported home_mailbox - valid values: Mailbox, Maildir/ or empty string')

  user { $postfix_username:
    ensure  => 'present',
    uid     => $postfix_username_uid,
    gid     => $postfix_username_gid,
    require => Group[$postfix_username],
  }

  group { $postfix_username:
    ensure  => 'present',
    gid     => $postfix_username_gid,
    require => Package[$postfix::params::package_name],
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

    exec { 'eyp-postfix which openssl':
      command => 'which openssl',
      unless  => 'which openssl',
      require => Exec[ ['postfix mkdir /etc/pki/tls/certs', 'postfix mkdir /etc/pki/tls/certs' ] ]
    }

    if($generatecert)
    {
      if($subjectselfsigned)
      {
        exec { 'openssl pk':
          command => 'openssl genrsa -out /etc/pki/tls/private/postfix-key.key 2048',
          creates => '/etc/pki/tls/private/postfix-key.key',
          require => Exec['eyp-postfix which openssl'],
        }

        exec { 'openssl cert':
          command => "openssl req -new -key /etc/pki/tls/private/postfix-key.key -subj '${subjectselfsigned}' | openssl x509 -req -days 10000 -signkey /etc/pki/tls/private/postfix-key.key -out /etc/pki/tls/certs/postfix.pem",
          unless  => "openssl x509 -in /etc/pki/tls/certs/postfix.pem -noout -subject | grep '${subjectselfsigned}'",
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
          require => Exec['eyp-postfix which openssl'],
          notify  => Class['postfix::service'],
          audit   => 'content',
          source  => $tlspk
        }

        file { '/etc/pki/tls/certs/postfix.pem':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => Exec['eyp-postfix which openssl'],
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
      before => Package[$postfix::params::package_name],
    }
  }

  if($postfix::params::purge_default_mta!=undef)
  {
    package { $postfix::params::purge_default_mta:
      ensure  => 'absent',
      require => Package[$postfix::params::package_name],
    }
  }

  package { $postfix::params::package_name:
    ensure => 'installed',
  }

  concat { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Class['postfix::service'],
  }

  concat::fragment{ '/etc/postfix/main.cf base':
    target  => '/etc/postfix/main.cf',
    order   => '00',
    content => template("${module_name}/main.cf.erb"),
  }

  class { 'postfix::service':
    ensure         => $service_ensure,
    enable         => $service_enable,
    manage_service => true,
  }

  if($postfix::params::switch_to_postfix)
  {
    exec { 'switch_mta_to_postfix':
      command => $postfix::params::switch_to_postfix,
      unless  => $postfix::params::check_postfix_mta,
      require => Package[$postfix::params::package_name],
    }
  }

  #postmap /etc/postfix/transport
  exec { 'reload postfix transport':
    command     => "postmap ${postfix::params::baseconf}/transport",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/transport"] ],
  }

  concat { "${postfix::params::baseconf}/transport":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix transport'],
  }

  concat::fragment{ '/etc/postfix/transport header':
    target  => "${postfix::params::baseconf}/transport",
    order   => '00',
    content => template("${module_name}/transport/header.erb"),
  }

  exec { 'reload postfix local aliases':
    command     => "newaliases -oA${alias_maps}",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => [ Package[$postfix::params::package_name], Concat[$alias_maps] ],
  }

  concat { $alias_maps:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix local aliases'],
  }

  concat::fragment{ "${postfix::alias_maps} header":
    target  => $alias_maps,
    order   => '00',
    content => template("${module_name}/aliases/header.erb"),
  }

  concat::fragment{ "${postfix::alias_maps} base":
    target  => $alias_maps,
    order   => '01',
    content => template("${module_name}/aliases/aliases_base.erb"),
  }

  if($manage_mastercf)
  {
    #
    # master.cf
    #

    concat { '/etc/postfix/master.cf':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Class['::postfix::service'],
    }

    concat::fragment{ '/etc/postfix/master.cf header':
      target  => '/etc/postfix/master.cf',
      order   => '00',
      content => template("${module_name}/mastercf/header.erb"),
    }

    if($smtpd_verbose)
    {
      $smtpd_instance_args='-v'
    }
    else
    {
      $smtpd_instance_args=undef
    }

    class { '::postfix::mastercf':
      add_default_smtpd_instance => $add_default_smtpd_instance,
      default_smtpd_args         => $smtpd_instance_args,
    }
  }
}
