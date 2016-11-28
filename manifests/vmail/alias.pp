define postfix::vmail::alias(
                              $aliasto,
                              $aliasfrom = $name,
                              $order     = '55',
                            ) {

  validate_array($aliasto)

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  concat::fragment{ "/etc/postfix/vmail_aliases ${aliasfrom} ${aliasto}":
    target  => '/etc/postfix/vmail_aliases',
    order   => $order,
    content => template("${module_name}/vmail/aliases/alias.erb"),
  }
}
