# referencies:
# https://www.server-world.info/en/note?os=CentOS_7&p=mail&f=6
# https://www.server-world.info/en/note?os=CentOS_7&p=mail&f=6
class postfix::contentfilter(
                              $setup_amavis   = true,
                              $setup_clamav   = true,
                              $content_filter = 'smtp-amavis:[127.0.0.1]:10024',
                              $add_instances  = true,
                            ) inherits postfix::params {

  if($setup_amavis)
  {
    class { 'amavis':
      setup_clamav => $setup_clamav,
    }
  }

  concat::fragment{ '/etc/postfix/main.cf content filter':
    target  => '/etc/postfix/main.cf',
    order   => '60',
    content => template("${module_name}/contentfilter.erb"),
  }

  if($add_instances)
  {
    # service type  private unpriv  chroot  wakeup  maxproc command + args
    # smtp      inet  n       -       n       -       -       smtpd
    #  -o smtpd_sasl_auth_enable=yes
    #  -o receive_override_options=no_address_mappings
    #  -o content_filter=smtp-amavis:127.0.0.1:10024

    # no aplico

    #  service      type  private unpriv  chroot  wakeup  maxproc command + args
    #  smtp-amavis  unix  -          -       y       -       2       smtp
    #  -o smtp_data_done_timeout=1200
    #  -o disable_dns_lookups=yes
    #  -o smtp_send_xforward_command=yes

    postfix::instance { 'smtp-amavis':
      type => 'unix',
      chroot => 'y',
      maxproc => '2',
      command => 'smtp',
      opts => {
        'smtp_data_done_timeout'     => '1200',
        'disable_dns_lookups'        => 'yes',
        'smtp_send_xforward_command' => 'yes',
      },
      order => '98',
    }

    #  service        type  private unpriv  chroot  wakeup  maxproc command + args
    # 127.0.0.1:10025 inet    n        -       y       -       -       smtpd
    #  -o content_filter=
    #  -o smtpd_helo_restrictions=
    #  -o smtpd_sender_restrictions=
    # -o smtpd_recipient_restrictions=permit_mynetworks,reject
    # -o mynetworks=127.0.0.0/8
    # -o smtpd_error_sleep_time=0
    # -o smtpd_soft_error_limit=1001
    # -o smtpd_hard_error_limit=1000
    # -o receive_override_options=no_header_body_checks
    # -o smtpd_helo_required=no
    # -o smtpd_client_restrictions=
    # -o smtpd_restriction_classes=
    # -o disable_vrfy_command=no
    # -o strict_rfc821_envelopes=yes

    postfix::instance { '127.0.0.1:10025':
      type => 'inet',
      private => 'n',
      chroot => 'y',
      command => 'smtpd',
      opts => {
        'content_filter'               => '',
        'smtpd_helo_restrictions'      => '',
        'smtpd_sender_restrictions'    => '',
        'smtpd_recipient_restrictions' => 'permit_mynetworks,reject',
        'mynetworks'                   => '127.0.0.0/8',
        'smtpd_error_sleep_time'       => '0',
        'smtpd_soft_error_limit'       => '1001',
        'smtpd_hard_error_limit'       => '1000',
        'receive_override_options'     => 'no_header_body_checks',
        'smtpd_helo_required'          => 'no',
        'smtpd_client_restrictions'    => '0',
        'smtpd_restriction_classes'    => '',
        'disable_vrfy_command'         => 'no',
        'strict_rfc821_envelopes'      => 'yes',
      },
      order => '99',
    }

  }

}
