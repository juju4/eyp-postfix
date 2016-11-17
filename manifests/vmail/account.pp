define postfix::vmail::account(
                                $accountname,
                                $domain,
                                $order = '42',
                              ) {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  concat::fragment{ "/etc/postfix/vmail_mailbox ${account} ${domain}":
    target  => '/etc/postfix/vmail_mailbox',
    order   => $order,
    content => template("${module_name}/vmail/mailbox/account.erb"),
  }

}
