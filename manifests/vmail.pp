class postfix::vmail(
                      $mailbox_base                 = '/var/vmail',
                      $setup_dovecot                = true,
                      $smtpd_recipient_restrictions = [ 'permit_mynetworks', 'permit_sasl_authenticated', 'reject_unauth_destination' ],
                      $smtpd_relay_restrictions     = [ 'permit_mynetworks', 'permit_sasl_authenticated', 'reject_unauth_destination' ],
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
    ensure  => 'directory',
    owner   => $postfix::postfix_username,
    group   => $postfix::postfix_username,
    mode    => '0770',
    require => Exec['eyp-postfix mailbox base'],
    before  => Class['postfix::service'],
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

  concat { '/etc/postfix/vmail_mailbox':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix mailbox'],
  }

  concat::fragment{ '/etc/postfix/vmail_mailbox header':
    target  => '/etc/postfix/vmail_mailbox',
    order   => '00',
    content => template("${module_name}/vmail/mailbox/header.erb"),
  }

  exec { 'reload postfix mailbox':
    command     => "postmap ${postfix::params::baseconf}/vmail_mailbox",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => Package[$postfix::params::package_name],
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

  concat { '/etc/postfix/vmail_domains':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix domains'],
  }

  concat::fragment{ '/etc/postfix/vmail_domains header':
    target  => '/etc/postfix/vmail_domains',
    order   => '00',
    content => template("${module_name}/vmail/domains/header.erb"),
  }

  exec { 'reload postfix domains':
    command     => "postmap ${postfix::params::baseconf}/vmail_domains",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => Package[$postfix::params::package_name],
  }

  #
  # virtual aliases
  #

  concat::fragment{ '/etc/postfix/main.cf virtual_alias_maps':
    target  => '/etc/postfix/main.cf',
    order   => '51',
    content => "\n# virtual aliases\nvirtual_alias_maps=hash:/etc/postfix/vmail_aliases\n",
  }

  concat { '/etc/postfix/vmail_aliases':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$postfix::params::package_name],
    notify  => Exec['reload postfix aliases'],
  }

  concat::fragment{ '/etc/postfix/vmail_aliases header':
    target  => '/etc/postfix/vmail_aliases',
    order   => '00',
    content => template("${module_name}/vmail/aliases/header.erb"),
  }

  exec { 'reload postfix aliases':
    command     => "postmap ${postfix::params::baseconf}/vmail_aliases",
    refreshonly => true,
    notify      => Class['postfix::service'],
    require     => Package[$postfix::params::package_name],
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
