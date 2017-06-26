define postfix::transport(
                            $domain            = $name,
                            $includesubdomains = true,
                            $nexthop           = undef,
                            $error             = undef,
                            $transport_noop    = false,
                            $order             = '55',
                            $include_to_maincf = true,
                            $target            = '/etc/postfix/transport',
                          ) {

  if(! defined(Concat::Fragment['/etc/postfix/main.cf transport_maps']))
  {
    # # transport
    # transport_maps = hash:/etc/postfix/transport
    if($include_to_maincf)
    {
      concat::fragment{ "/etc/postfix/main.cf transport_maps ${target}":
        target  => '/etc/postfix/main.cf',
        order   => '01',
        content => "\n# transport\ntransport_maps = hash:${target}\n",
      }
    }
  }

  if($transport_noop)
  {
    concat::fragment{ "/etc/postfix/transport noop ${name} ${domain}":
      target  => $target,
      order   => $order,
      content => template("${module_name}/transport/noop.erb"),
    }
  }
  elsif($nexthop!=undef)
  {
    concat::fragment{ "/etc/postfix/transport ${name} ${domain} ${nexthop}":
      target  => $target,
      order   => $order,
      content => template("${module_name}/transport/nexthop.erb"),
    }
  }
  elsif($error!=undef)
  {
    concat::fragment{ "/etc/postfix/transport error ${name} ${domain}":
      target  => $target,
      order   => $order,
      content => template("${module_name}/transport/error.erb"),
    }
  }
  else
  {
    fail('no action configured for this transport rule')
  }

}
