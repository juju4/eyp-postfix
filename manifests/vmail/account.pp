define postfix::vmail::account(
                                $accountname,
                                $domain,
                                $order = '42',
                              ) {

  #virtual_mailbox_maps=hash:/etc/postfix/vmail_mailbox
  if(! defined(Concat::Fragment['/etc/postfix/main.cf virtual_mailbox_maps']))
  {
    concat::fragment{ '/etc/postfix/main.cf virtual_mailbox_maps':
      target  => '/etc/postfix/main.cf',
      order   => '52',
      content => "\n# virtual mailboxes\nvirtual_alias_maps=hash:virtual_mailbox_maps=hash:/etc/postfix/vmail_mailbox\n",
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
  }

  concat::fragment{ "/etc/postfix/vmail_mailbox ${account} ${domain}":
    target  => '/etc/postfix/vmail_mailbox',
    order   => $order,
    content => template("${module_name}/vmail/mailbox/account.erb"),
  }

}
