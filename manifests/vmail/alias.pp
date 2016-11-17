define postfix::vmail::alias(
                              $aliasto,
                              $aliasfrom = $name,
                              $order     = '55',
                            ) {

  validate_array($aliasto)

  if(! defined(Concat::Fragment['/etc/postfix/main.cf virtual_alias_maps']))
  {
    concat::fragment{ '/etc/postfix/main.cf virtual_alias_maps':
      target  => '/etc/postfix/main.cf',
      order   => '01',
      content => "\n# virtual aliases\nvirtual_alias_maps=hash:/etc/postfix/vmail_aliases\n",
    }
  }

  concat::fragment{ "/etc/postfix/vmail_aliases ${aliasfrom} ${aliasto}":
    target  => '/etc/postfix/vmail_aliases',
    order   => $order,
    content => template("${module_name}/aliases/alias.erb"),
  }

}
