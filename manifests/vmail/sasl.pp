class postfix::vmail::sasl(
                            $smtpd_sasl_path = '/var/run/dovecot/auth-client',
                            $smtpd_sasl_type = 'dovecot',
                          ) inherits postfix::params {

  concat::fragment{ '/etc/postfix/main.cf SASL':
    target  => '/etc/postfix/main.cf',
    order   => '54',
    content => template("${module_name}/vmail/sasl.erb"),
  }
}
