#
# TODO RBL
# reject_rbl_client rbl_domain=d.d.d.d
# smtpd_recipient_restrictions = ... reject_unauth_destination reject_rbl_client zen.smaphaus.org
#
# LOCAL caching DNS server required
#
# filtering
# http://www.postfix.org/FILTER_README.html
#
# amavis-new
# http://forums.sentora.org/showthread.php?tid=1132
#
class postfix::vmail(
                      $mailbox_base                 = '/var/vmail',
                      $setup_dovecot                = true,
                      #TODO: rewrite
                      $smtpd_recipient_restrictions = [ 'permit_inet_interfaces',
                                                        'permit_mynetworks',
                                                        'reject_authenticated_sender_login_mismatch',
                                                        'permit_sasl_authenticated',
                                                        'reject_unauth_destination',
                                                        'reject'
                                                        ],
                      $smtpd_relay_restrictions     = [ 'permit_inet_interfaces',
                                                        'permit_mynetworks',
                                                        'reject_authenticated_sender_login_mismatch',
                                                        'permit_sasl_authenticated',
                                                        'reject_unauth_destination',
                                                        'reject'
                                                        ],
                    ) inherits postfix::params {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if($setup_dovecot)
  {
    class { 'dovecot':
      default_login_user => $postfix::postfix_username,
      first_valid_uid    => $postfix::postfix_username_uid,
      first_valid_gid    => $postfix::postfix_username_gid,
      mail_location      => "maildir:${mailbox_base}/%d/%n",
    }

    class { 'dovecot::userdb':
      uid  => $postfix::postfix_username_uid,
      gid  => $postfix::postfix_username_gid,
      home => "${mailbox_base}/%d/%n",
    }

    class { 'dovecot::passdb': }

    class { 'dovecot::auth': }

    class { 'dovecot::auth::unixlistener':
      user  => $postfix::postfix_username,
      group => $postfix::postfix_username,
    }

    class { 'dovecot::imaplogin':
      user => $postfix::postfix_username,
    }

    class { 'postfix::vmail::sasl':
      smtpd_sasl_type => 'dovecot',
    }
  }

  exec { 'eyp-postfix mailbox base':
    command => "mkdir -p ${mailbox_base}",
    creates => $mailbox_base,
  }

  file { $mailbox_base:
    ensure   => 'directory',
    owner    => $postfix::postfix_username,
    group    => $postfix::postfix_username,
    mode     => '0770',
    selrange => 's0',
    selrole  => 'object_r',
    seltype  => 'mail_spool_t',
    seluser  => 'system_u',
    require  => Exec['eyp-postfix mailbox base'],
    before   => Class['postfix::service'],
  }

  #
  # vmail base config
  #

  concat::fragment{ '/etc/postfix/main.cf vmail base':
    target  => '/etc/postfix/main.cf',
    order   => '50',
    content => template("${module_name}/vmail/vmail.erb"),
  }

  #
  # virtual mailboxes
  #

  concat::fragment{ '/etc/postfix/main.cf virtual_mailbox_maps':
    target  => '/etc/postfix/main.cf',
    order   => '52',
    content => "\n# virtual mailboxes\nvirtual_mailbox_maps=hash:/etc/postfix/vmail_mailbox\n",
  }

  concat { "${postfix::params::baseconf}/vmail_mailbox":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix mailbox'],
  }

  concat::fragment{ '/etc/postfix/vmail_mailbox header':
    target  => "${postfix::params::baseconf}/vmail_mailbox",
    order   => '00',
    content => template("${module_name}/vmail/mailbox/header.erb"),
  }

  exec { 'reload postfix mailbox':
    command     => "postmap ${postfix::params::baseconf}/vmail_mailbox",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/vmail_mailbox"] ],
  }

  #
  # virtual domains
  #
  #virtual_mailbox_domains=hash:/etc/postfix/vmail_domains

  concat::fragment{ '/etc/postfix/main.cf virtual_mailbox_domains':
    target  => '/etc/postfix/main.cf',
    order   => '53',
    content => "\n# virtual domains\nvirtual_mailbox_domains=hash:/etc/postfix/vmail_domains\n",
  }

  concat { "${postfix::params::baseconf}/vmail_domains":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix domains'],
  }

  concat::fragment{ '/etc/postfix/vmail_domains header':
    target  => "${postfix::params::baseconf}/vmail_domains",
    order   => '00',
    content => template("${module_name}/vmail/domains/header.erb"),
  }

  exec { 'reload postfix domains':
    command     => "postmap ${postfix::params::baseconf}/vmail_domains",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/vmail_domains"] ],
  }

  #
  # smtpd restrictions
  #

  concat::fragment{ '/etc/postfix/main.cf smtpd_restrictions':
    target  => '/etc/postfix/main.cf',
    order   => '55',
    content => template("${module_name}/smtpd_restrictions.erb"),
  }
}
