define postfix::vmail::account(
                                $accountname,
                                $domain,
                                $password,
                                $order = '42',
                              ) {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  include ::postfix::vmail

  if($postfix::vmail::setup_dovecot)
  {
    dovecot::account { "${accountname}@${domain}":
      password => $password,
    }
  }

  exec { "eyp-postfix mailbox ${accountname}@${domain}":
    command => "mkdir -p ${postfix::vmail::mailbox_base}/${domain}/${accountname}",
    creates => "${postfix::vmail::mailbox_base}/${domain}/${accountname}",
  }

  file { "${postfix::vmail::mailbox_base}/${domain}/${accountname}":
    ensure  => 'directory',
    owner   => $postfix::postfix_username,
    group   => $postfix::postfix_username,
    mode    => '0770',
    require => Exec["eyp-postfix mailbox ${accountname}@${domain}"],
    before  => Class['postfix::service'],
  }

  concat::fragment{ "/etc/postfix/vmail_mailbox ${accountname} ${domain}":
    target  => '/etc/postfix/vmail_mailbox',
    order   => $order,
    content => template("${module_name}/vmail/mailbox/account.erb"),
  }

  if(! defined(Concat::Fragment["/etc/postfix/vmail_domains ${domain}"]))
  {
    concat::fragment{ "/etc/postfix/vmail_domains ${domain}":
      target  => '/etc/postfix/vmail_domains',
      order   => $order,
      content => template("${module_name}/vmail/domains/domain.erb"),
    }

    file { "${postfix::vmail::mailbox_base}/${domain}":
      ensure  => 'directory',
      owner   => $postfix::postfix_username,
      group   => $postfix::postfix_username,
      mode    => '0770',
      require => Exec["eyp-postfix mailbox ${accountname}@${domain}"],
      before  => Class['postfix::service'],
    }
  }
}
