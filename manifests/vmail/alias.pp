define postfix::vmail::alias(
                              $aliasto                     = [],
                              $aliasfrom                   = $name,
                              $order                       = '42',
                              $regex                       = false,
                              $add_config_default_instance = true,
                              $instance_name               = 'vmail',
                            ) {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(!defined(Concat["${postfix::params::baseconf}/${instance_name}_aliases"]))
  {
    #
    # virtual aliases
    #
    if($add_config_default_instance)
    {
      concat::fragment{ "/etc/postfix/main.cf virtual_alias_maps ${instance_name}":
        target  => '/etc/postfix/main.cf',
        order   => '51',
        content => "\n# virtual aliases\nvirtual_alias_maps=hash:${postfix::params::baseconf}/${instance_name}_aliases, regexp:${postfix::params::baseconf}/${instance_name}_aliases_regex\n",
      }
    }

    concat { "${postfix::params::baseconf}/${instance_name}_aliases":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec['reload postfix aliases'],
    }

    concat::fragment{ '/etc/postfix/${instance_name}_aliases header':
      target  => "${postfix::params::baseconf}/${instance_name}_aliases",
      order   => '00',
      content => template("${module_name}/vmail/aliases/header.erb"),
    }

    exec { "reload postfix aliases ${instance_name}":
      command     => "postmap ${postfix::params::baseconf}/${instance_name}_aliases",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => [ Package[$postfix::params::package_name], Concat["${postfix::params::baseconf}/${instance_name}_aliases"] ],
    }

    #
    # virtual_alias_maps - regex
    #

    exec { "reload postfix virtual_alias_maps regex ${instance_name}":
      command     => "postmap ${postfix::params::baseconf}/${instance_name}_aliases_regex",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => Package[$postfix::params::package_name],
    }

    concat { "${postfix::params::baseconf}/${instance_name}_aliases_regex":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec["reload postfix virtual_alias_maps regex ${instance_name}"],
    }

    concat::fragment { "${postfix::params::baseconf}/${instance_name}_aliases_regex header":
      target  => "${postfix::params::baseconf}/${instance_name}_aliases_regex",
      order   => '00',
      content => template("${module_name}/header.erb"),
    }
  }

  if($regex)
  {
    $target_file="/etc/postfix/${instance_name}_aliases_regex"
  }
  else
  {
    $target_file="/etc/postfix/${instance_name}_aliases"
  }

  concat::fragment{ "/etc/postfix/${instance_name}_aliases ${aliasfrom} ${aliasto}":
    target  => $target_file,
    order   => $order,
    content => template("${module_name}/vmail/aliases/alias.erb"),
  }
}
