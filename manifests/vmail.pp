class postfix::vmail(
                    ) inherits postfix::params {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  concat::fragment{ '/etc/postfix/main.cf virtual_alias_maps':
    target  => '/etc/postfix/main.cf',
    order   => '50',
    content => template("${module_name}/vmail/vmail.erb"),
  }

}
