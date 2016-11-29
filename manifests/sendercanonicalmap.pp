define postfix::sendercanonicalmap(
                                    $scm_to,
                                    $scm_from = $name,
                                    $order    = '42',
                                  ) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if(!defined(Concat['/etc/postfix/sender_canonical_maps']))
  {
    concat { '/etc/postfix/sender_canonical_maps':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$postfix::params::package_name],
      notify  => Exec['reload postfix sender_canonical_maps'],
    }

    concat::fragment{ '/etc/postfix/sender_canonical_maps header':
      target  => '/etc/postfix/sender_canonical_maps',
      order   => '00',
      content => template("${module_name}/generic_header.erb"),
    }

    exec { 'reload postfix sender_canonical_maps':
      command     => "postmap ${postfix::params::baseconf}/sender_canonical_maps",
      refreshonly => true,
      notify      => Class['postfix::service'],
      require     => Package[$postfix::params::package_name],
    }

    concat::fragment{ '/etc/postfix/main.cf sender_canonical_maps':
      target  => '/etc/postfix/main.cf',
      order   => '61',
      content => "\n# sender_canonical_maps\nsender_canonical_maps = hash:/etc/postfix/sender_canonical_maps\n",
    }
  }

  concat::fragment{ "/etc/postfix/sender_canonical_maps ${scm_from} ${scm_to}":
    target  => '/etc/postfix/sender_canonical_maps',
    order   => $order,
    content => template("${module_name}/sender_canonical_maps.erb"),
  }

}
