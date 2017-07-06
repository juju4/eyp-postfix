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
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(! defined(Concat::Fragment["/etc/postfix/main.cf transport_maps ${target}"]))
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

  if(! defined(Concat[$target]))
  {
    concat { $target:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec["reload postfix transport ${target}"],
    }

    exec { "reload postfix transport ${target}":
      command     => "postmap ${target}",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/transport"] ],
    }
  }

  if($transport_noop)
  {
    concat::fragment{ "${target} noop ${name} ${domain}":
      target  => $target,
      order   => $order,
      content => template("${module_name}/transport/noop.erb"),
    }
  }
  elsif($nexthop!=undef)
  {
    concat::fragment{ "${target} nexthop ${name} ${domain} ${nexthop}":
      target  => $target,
      order   => $order,
      content => template("${module_name}/transport/nexthop.erb"),
    }
  }
  elsif($error!=undef)
  {
    concat::fragment{ "${target} error ${name} ${domain}":
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
