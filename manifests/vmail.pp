class postfix::vmail(
                      $domains = undef,
                    ) inherits postfix::params {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  #
  # vmail base
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
    content => "\n# virtual mailboxes\nvirtual_alias_maps=hash:/etc/postfix/vmail_mailbox\n",
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
    content => "\n# virtual domains\virtual_mailbox_domains=hash:/etc/postfix/vmail_domains\n",
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

}
