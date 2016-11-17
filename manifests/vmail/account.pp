define postfix::vmail::account(
                                $account,
                                $domain,
                              ) {

  #virtual_mailbox_maps=hash:/etc/postfix/vmail_mailbox
  if(! defined(Concat::Fragment['/etc/postfix/main.cf virtual_mailbox_maps']))
  {
    concat::fragment{ '/etc/postfix/main.cf virtual_mailbox_maps':
      target  => '/etc/postfix/main.cf',
      order   => '52',
      content => "\n# virtual mailboxes\nvirtual_alias_maps=hash:virtual_mailbox_maps=hash:/etc/postfix/vmail_mailbox\n",
    }

    
  }

}
