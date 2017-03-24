define postfix::genericmap(
                            $map_to,
                            $map_from = $name,
                            $order    = '55',
                          ) {

  concat::fragment{ "${postfix::smtp_generic_maps} ${map_from} ${map_to}":
    target  => $postfix::smtp_generic_maps,
    order   => $order,
    content => template("${module_name}/generic_map.erb"),
  }
}
