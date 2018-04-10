define postfix::virtualaliasmapsregex (
                                        $to,
                                        $from    = $name,
                                        $order   = '42',
                                        $target = $postfix::virtual_alias_maps_regex,
                                      ) {
  include ::postfix

  concat::fragment{ "virtual alias maps regex: ${target} ${from} ${to}":
    target  => $target,
    order   => $order,
    content => template("${module_name}/aliases/alias.erb"),
  }
}
