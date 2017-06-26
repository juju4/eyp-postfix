define postfix::transport(
                            $domain            = $name,
                            $includesubdomains = true,
                            $nexthop           = undef,
                            $error             = undef,
                            $transport_noop    = false,
                            $order             = '55',
                            $target            = '/etc/postfix/transport',
                          ) {

  if(! defined(Concat::Fragment['/etc/postfix/main.cf transport_maps']))
  {
    # # transport
    # transport_maps = hash:/etc/postfix/transport
    if($target == '/etc/postfix/transport')
    {
      concat::fragment{ '/etc/postfix/main.cf transport_maps':
        target  => '/etc/postfix/main.cf',
        order   => '01',
        content => "\n# transport\ntransport_maps = hash:/etc/postfix/transport\n",
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
