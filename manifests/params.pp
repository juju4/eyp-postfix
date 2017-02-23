#
class postfix::params {

  $package_name='postfix'

  $mynetworks_default = [ '127.0.0.1' ]
  $inetinterfaces_default = '127.0.0.1'
  $smtpdbanner_default = "${::hostname} ESMTP"
  $ipv6_default = false
  $relayhost_default = undef
  $relayhost_mx_lookup_default = false
  $opportunistictls_default = false
  $tlscert_default = undef
  $tlspk_default = undef
  $myhostname_default = $::hostname
  $generatecert_default = false
  $subjectselfsigned_default = undef
  $biff_default = false
  $append_dot_mydomain_default = undef
  $recipient_delimiter_default = undef
  $mydestination_default = [ $::fqdn, 'localhost' ]
  $baseconf = '/etc/postfix'
  $mail_spool_directory_default = '/var/mail'
  $default_process_limit_default = '100'
  $smtpd_client_connection_count_limit_default = '10'
  $smtpd_client_connection_rate_limit_default = '30'
  $install_mailclient_default = true
  $in_flow_delay_default = '1s'

  case $::osfamily
  {
    'redhat':
    {
      $setgid_group_default='postdrop'

      case $::operatingsystemrelease
      {
        /^5.*$/:
        {
          $manage_mastercf_default=false
          $daemon_directory_default='/usr/libexec/postfix'
          #$dependencies=['chkconfig', 'grep']
          $switch_to_postfix='alternatives --set mta /usr/sbin/sendmail.postfix'
          $check_postfix_mta='alternatives --display mta | grep postfix'

          $purge_default_mta=[ 'exim', 'sendmail' ]

          $mailclient=[ 'mailx' ]

          $readme_directory_default = false

          $postfix_username_uid_default='89'
          $postfix_username_gid_default='89'

          $postfix_ver='2.3.3'
        }
        /^6.*$/:
        {
          $manage_mastercf_default=true
          $daemon_directory_default='/usr/libexec/postfix'
          #$dependencies=['chkconfig', 'grep']
          $switch_to_postfix='alternatives --set mta /usr/sbin/sendmail.postfix'
          $check_postfix_mta='alternatives --display mta | grep postfix'

          $purge_default_mta=[ 'exim', 'sendmail' ]

          $mailclient=[ 'mailx' ]

          $readme_directory_default = false

          $postfix_username_uid_default='89'
          $postfix_username_gid_default='89'

          $postfix_ver='2.6.6'
        }
        /^7.*$/:
        {
          $manage_mastercf_default=true
          $daemon_directory_default='/usr/libexec/postfix'
          #$dependencies=['chkconfig', 'grep']
          $switch_to_postfix='alternatives --set mta /usr/sbin/sendmail.postfix'
          $check_postfix_mta='alternatives --display mta | grep postfix'

          $purge_default_mta=[ 'exim', 'sendmail' ]

          $mailclient=[ 'mailx' ]

          $readme_directory_default = false

          $postfix_username_uid_default='89'
          $postfix_username_gid_default='89'

          $postfix_ver='2.10.1'
        }
        default: { fail('Unsupported RHEL/CentOS version!')  }
      }
    }
    'Debian':
    {
      case $::operatingsystem
      {
        'Ubuntu':
        {
          $setgid_group_default='postdrop'

          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
              $manage_mastercf_default=false
              $daemon_directory_default='/usr/lib/postfix'
              #$dependencies=['dpkg', 'grep' ]
              $switch_to_postfix=undef
              $check_postfix_mta=undef

              $purge_default_mta=undef

              $mailclient=[ 'mailutils' ]

              $readme_directory_default='/usr/share/doc/postfix'

              if($::facts!=undef)
              {
                if has_key($::facts, 'eyp_postfix_uid')
                {
                  # $postfix_username_uid_default=hiera('::eyp_postfix_uid', '89'),
                  $postfix_username_uid_default = $::facts['eyp_postfix_uid'] ? {
                    undef   => '89',
                    default => $::facts['eyp_postfix_uid'],
                  }
                }
                else
                {
                  $postfix_username_uid_default = '89'
                }

                if has_key($::facts, 'eyp_postfix_gid')
                {
                  # $postfix_username_gid_default=hiera('::eyp_postfix_gid', '89'),
                  $postfix_username_gid_default = $::facts['eyp_postfix_gid'] ? {
                    undef   => '89',
                    default => $::facts['eyp_postfix_gid'],
                  }
                }
                else
                {
                  $postfix_username_gid_default = '89'
                }
              }
              else
              {
                $postfix_username_uid_default = $::eyp_postfix_uid ? {
                  undef   => '89',
                  default => $::eyp_postfix_uid,
                }
                $postfix_username_gid_default = $::eyp_postfix_gid ? {
                  undef   => '89',
                  default => $::eyp_postfix_gid,
                }
              }

              $postfix_ver='2.11.0'
            }
            /^16.*$/:
            {
              $manage_mastercf_default=false
              $daemon_directory_default='/usr/lib/postfix/sbin'
              #$dependencies=['dpkg', 'grep' ]
              $switch_to_postfix=undef
              $check_postfix_mta=undef

              $purge_default_mta=undef

              $mailclient=[ 'mailutils' ]

              $readme_directory_default='/usr/share/doc/postfix'

              if($::facts!=undef)
              {
                if has_key($::facts, 'eyp_postfix_uid')
                {
                  # $postfix_username_uid_default=hiera('::eyp_postfix_uid', '89'),
                  $postfix_username_uid_default = $::facts['eyp_postfix_uid'] ? {
                    undef   => '89',
                    default => $::facts['eyp_postfix_uid'],
                  }
                }
                else
                {
                  $postfix_username_uid_default = '89'
                }

                if has_key($::facts, 'eyp_postfix_gid')
                {
                  # $postfix_username_gid_default=hiera('::eyp_postfix_gid', '89'),
                  $postfix_username_gid_default = $::facts['eyp_postfix_gid'] ? {
                    undef   => '89',
                    default => $::facts['eyp_postfix_gid'],
                  }
                }
                else
                {
                  $postfix_username_gid_default = '89'
                }
              }
              else
              {
                $postfix_username_uid_default = $::eyp_postfix_uid ? {
                  undef   => '89',
                  default => $::eyp_postfix_uid,
                }
                $postfix_username_gid_default = $::eyp_postfix_gid ? {
                  undef   => '89',
                  default => $::eyp_postfix_gid,
                }
              }

              $postfix_ver='3.1.0'
            }
            default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}")  }
          }
        }
        'Debian': { fail('Unsupported')  }
        default: { fail('Unsupported Debian flavour!')  }
      }
    }
    'Suse':
    {
      $setgid_group_default='maildrop'

      case $::operatingsystem
      {
        'SLES':
        {
          case $::operatingsystemrelease
          {
            '11.3':
            {
              $manage_mastercf_default=false
              $daemon_directory_default='/usr/lib/postfix'
              #$dependencies=['dpkg', 'grep' ]
              $switch_to_postfix=undef
              $check_postfix_mta=undef

              $purge_default_mta=[ 'sendmail' ]

              $mailclient=[ 'mailx' ]

              $readme_directory_default=false

              $postfix_username_uid_default='51'
              $postfix_username_gid_default='51'

              $postfix_ver='2.9.4'
            }
            default: { fail("Unsupported operating system ${::operatingsystem} ${::operatingsystemrelease}") }
          }
        }
        default: { fail("Unsupported operating system ${::operatingsystem}") }
      }
    }
    default: { fail('Unsupported OS!')  }
  }

}
