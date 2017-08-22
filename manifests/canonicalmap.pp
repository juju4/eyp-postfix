define postfix::canonicalmap(
                              $to_addr           = $name,
                              $from_user         = undef,
                              $from_domain       = undef,
                              $from_address      = undef,
                              $order             = '55',
                              $include_to_maincf = true,
                              $target            = '/etc/postfix/canonical',
                            ) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(! defined(Concat::Fragment["/etc/postfix/main.cf canonicalmap ${target}"]))
  {
    # # transport
    # transport_maps = hash:/etc/postfix/transport
    if($include_to_maincf)
    {
      concat::fragment{ "/etc/postfix/main.cf canonicalmap ${target}":
        target  => '/etc/postfix/main.cf',
        order   => '01',
        content => "\n# canonical maps\ncanonical_maps = hash:${target}\n",
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
      notify  => Exec["reload postfix canonicalmaps ${target}"],
    }

    exec { "reload postfix canonicalmaps ${target}":
      command     => "postmap ${target}",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/transport"] ],
    }

    concat::fragment{ "${target} header":
      target  => $target,
      order   => '00',
      content => template("${module_name}/canonical/header.erb"),
    }
  }

  if($from_user!=undef)
  {
    if($from_domain!=undef or $from_address!=undef)
    {
      fail('from_user, from_domain and from_address are mutually exclusive')
    }

    concat::fragment{ "${target} ${from_user} map ${from_user}":
      target  => $target,
      order   => $order,
      content => "${from_user}  ${from_user}\n",
    }
  }

  if($from_domain!=undef)
  {
    if($from_user!=undef or $from_address!=undef)
    {
      fail('from_user, from_domain and from_address are mutually exclusive')
    }

    concat::fragment{ "${target} ${from_domain} map ${from_user}":
      target  => $target,
      order   => $order,
      content => "${from_domain}  ${from_user}\n",
    }
  }

  if($from_address!=undef)
  {
    if($from_user!=undef or $from_domain!=undef)
    {
      fail('from_user, from_domain and from_address are mutually exclusive')
    }

    concat::fragment{ "${target} ${from_domain} map ${from_user}":
      target  => $target,
      order   => $order,
      content => "${from_domain}  ${from_user}\n",
    }
  }
}
