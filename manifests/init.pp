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
                $smtpdbanner                         = "${::hostname} ESMTP",
                $mydestination                       = [ $::fqdn, 'localhost' ],
                $mydomain                            = $::domain,
                $myhostname                          = $::hostname,
                $mynetworks                          = [ '127.0.0.1' ],
                $myorigin                            = $::domain,
                $inetinterfaces                      = '127.0.0.1',
                $mail_spool_directory                = '/var/mail',
                $append_dot_mydomain                 = undef,
                $biff                                = false,
                $ipv6                                = false,
                $opportunistictls                    = false,
                $recipient_delimiter                 = undef,
                $relayhost                           = undef,
                $relayhost_mx_lookup                 = false,
                $generatecert                        = false,
                $subjectselfsigned                   = undef,
                $tlscert                             = undef,
                $tlspk                               = undef,
                $install_mailclient                  = true,
                $default_process_limit               = '100',
                $smtpd_client_connection_count_limit = '10',
                $smtpd_client_connection_rate_limit  = '30',
                $in_flow_delay                       = '1s',
                $setgid_group                        = $postfix::params::setgid_group_default,
                $readme_directory                    = $postfix::params::readme_directory_default,
                $smtp_fallback_relay                 = undef,
                $postfix_username_uid                = $postfix_username_uid_default,
                $postfix_username_gid                = $postfix_username_gid_default,
                $add_default_smtpd_instance          = true,
                $manage_mastercf                     = $postfix::params::manage_mastercf_default,
                $resolve_null_domain                 = true,
                $debug_peer_level                    = '2',
                $debug_peer_list                     = undef,
                $smtpd_verbose                       = false,
                $syslog_name                         = undef,
                $daemon_directory                    = $postfix::params::daemon_directory_default,
                $unknown_local_recipient_reject_code = '550',
                $postfix_username                    = 'postfix',
                $home_mailbox                        = 'Maildir/',
                $alias_maps                          = '/etc/aliases',
                $data_directory                      = '/var/lib/postfix',
                $service_ensure                      = 'running',
                $service_enable                      = true,
                $smtp_generic_maps                   = "${postfix::params::baseconf}/generic_maps",
                $smtpd_reject_footer                 = undef,
                $message_size_limit                  = undef, # @param message_size_limit The maximal size in bytes of a message, including envelope information. (default: undef)
                $compatibility_level                 = $postfix::params::compatibility_level_default,
                $mynetworks_style                    = 'subnet',
                $smtpd_helo_required                 = true,
                $disable_vrfy_command                = true,
                $smtp_sasl_auth_enable               = true,
                $smtp_sasl_security_options          = 'noanonymous',
                $smtpd_use_tls                       = true,
                $smtpd_tls_protocols                 = '!SSLv2,!SSLv3,!TLSv1,!TLSv1.1',
                $smtp_use_tls                        = true,
                $smtp_tls_exclude_ciphers            = 'EXPORT, LOW',
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

  #data_directory
  file { $data_directory:
    ensure  => 'directory',
    owner   => $postfix_username,
    group   => $postfix_username,
    mode    => '0755',
    require => Package[$postfix::params::package_name],
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

  #
  # smtp_generic_maps
  #

  exec { 'reload postfix smtp_generic_maps':
    command     => "postmap ${smtp_generic_maps}",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => [ Package[$postfix::params::package_name], Concat[$smtp_generic_maps] ],
  }

  concat { $smtp_generic_maps:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix smtp_generic_maps'],
  }

  concat::fragment{ "${smtp_generic_maps} header":
    target  => $smtp_generic_maps,
    order   => '00',
    content => template("${module_name}/header.erb"),
  }

  #
  # alias maps
  #

  exec { 'reload postfix local aliases':
    command     => "newaliases -oA${alias_maps}",
    refreshonly => true,
    notify      => [ File["${alias_maps}.db"], Class['postfix::service']],
    require     => [ Package[$postfix::params::package_name], Concat[$alias_maps] ],
  }

  file { "${alias_maps}.db":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    seltype => 'etc_aliases_t',
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
