define postfix::vmail::alias(
                              $aliasto,
                              $aliasfrom = $name,
                              $order     = '55',
                            ) {

  validate_array($aliasto)

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(! defined(Concat::Fragment['/etc/postfix/main.cf virtual_alias_maps']))
  {
    concat::fragment{ '/etc/postfix/main.cf virtual_alias_maps':
      target  => '/etc/postfix/main.cf',
      order   => '51',
      content => "\n# virtual aliases\nvirtual_alias_maps=hash:/etc/postfix/vmail_aliases\n",
    }

    concat { '/etc/postfix/vmail_aliases':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec['reload postfix aliases'],
    }

    concat::fragment{ '/etc/postfix/vmail_aliases header':
      target  => '/etc/postfix/vmail_aliases',
      order   => '00',
      content => template("${module_name}/vmail/aliases/header.erb"),
    }

    exec { 'reload postfix aliases':
      command     => "postmap ${postfix::params::baseconf}/vmail_aliases",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => Package[$postfix::params::package_name],
    }
  }

  concat::fragment{ "/etc/postfix/vmail_aliases ${aliasfrom} ${aliasto}":
    target  => '/etc/postfix/vmail_aliases',
    order   => $order,
    content => template("${module_name}/vmail/aliases/alias.erb"),
  }

}
