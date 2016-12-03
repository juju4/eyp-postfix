class postfix::contentfilter(
                              $install_amavis = true,
                              $install_clamav = true,
                              $content_filter = 'smtp-amavis:[127.0.0.1]:10024'
                            ) inherits postfix::params {

  if($install_amavis)
  {
    class { 'amavis':
      install_clamav => $install_clamav,
    }
  }

  concat::fragment{ '/etc/postfix/main.cf content filter':
    target  => '/etc/postfix/main.cf',
    order   => '60',
    content => template("${module_name}/contentfilter.erb"),
  }

  # service type  private unpriv  chroot  wakeup  maxproc command + args
  # smtp      inet  n       -       n       -       -       smtpd
  #  -o smtpd_sasl_auth_enable=yes
  #  -o receive_override_options=no_address_mappings
  #  -o content_filter=smtp-amavis:127.0.0.1:10024
  #
  #  smtp-amavis  unix  -    -       y       -       2       smtp
  #  -o smtp_data_done_timeout=1200
  #  -o disable_dns_lookups=yes
  #  -o smtp_send_xforward_command=yes
  # 127.0.0.1:10025 inet n  -       y       -       -       smtpd
  #  -o content_filter=
  #  -o smtpd_helo_restrictions=
  #  -o smtpd_sender_restrictions=
}
