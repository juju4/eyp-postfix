define postfix::alias(
                        $to,
                        $from    = $name,
                        $order   = '42',
                        $comment = undef,
                      ) {
  include ::postfix

  concat::fragment{ "${postfix::alias_maps} ${from} ${to}":
    target  => $postfix::alias_maps,
    order   => $order,
    content => template("${module_name}/aliases/alias.erb"),
  }
}
