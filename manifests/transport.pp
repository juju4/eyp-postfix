define postfix::transport(
                            $domain            = $name,
                            $includesubdomains = true,
                            $nexthop           = undef,
                          ) {

  concat::fragment{ '/etc/postfix/transport ${name} ${domain} ${nexthop}':
    target  => '/etc/postfix/transport',
    order   => '55',
    content => template("${module_name}/transport/nexthop.erb"),
  }
}
