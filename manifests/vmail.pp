class postfix::vmail(
                      $domains = undef,
                    ) inherits postfix::params {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  concat::fragment{ '/etc/postfix/main.cf vmail base':
    target  => '/etc/postfix/main.cf',
    order   => '50',
    content => template("${module_name}/vmail/vmail.erb"),
  }

}
