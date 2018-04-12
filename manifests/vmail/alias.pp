define postfix::vmail::alias(
                              $aliasto   = [],
                              $aliasfrom = $name,
                              $order     = '42',
                              $regex     = false,
                            ) {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(!defined(Concat["${postfix::params::baseconf}/vmail_aliases"]))
  {
    #
    # virtual aliases
    #
    concat::fragment{ '/etc/postfix/main.cf virtual_alias_maps':
      target  => '/etc/postfix/main.cf',
      order   => '51',
      content => "\n# virtual aliases\nvirtual_alias_maps=hash:${postfix::params::baseconf}/vmail_aliases, regexp:${postfix::params::baseconf}/vmail_aliases_regex\n",
    }

    concat { "${postfix::params::baseconf}/vmail_aliases":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec['reload postfix aliases'],
    }

    concat::fragment{ '/etc/postfix/vmail_aliases header':
      target  => "${postfix::params::baseconf}/vmail_aliases",
      order   => '00',
      content => template("${module_name}/vmail/aliases/header.erb"),
    }

    exec { 'reload postfix aliases':
      command     => "postmap ${postfix::params::baseconf}/vmail_aliases",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/vmail_aliases"] ],
    }

    #
    # virtual_alias_maps - regex
    #

    exec { 'reload postfix virtual_alias_maps regex':
      command     => "postmap ${postfix::params::baseconf}/vmail_aliases_regex",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => Package[$postfix::params::package_name],
    }

    concat { "${postfix::params::baseconf}/vmail_aliases_regex":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec['reload postfix virtual_alias_maps regex'],
    }

    concat::fragment { "${postfix::params::baseconf}/vmail_aliases_regex header":
      target  => "${postfix::params::baseconf}/vmail_aliases_regex",
      order   => '00',
      content => template("${module_name}/header.erb"),
    }
  }

  if($regex)
  {
    $target_file='/etc/postfix/vmail_aliases_regex'
  }
  else
  {
    $target_file='/etc/postfix/vmail_aliases'
  }

  concat::fragment{ "/etc/postfix/vmail_aliases ${aliasfrom} ${aliasto}":
    target  => $target_file,
    order   => $order,
    content => template("${module_name}/vmail/aliases/alias.erb"),
  }
}
