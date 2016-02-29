class postfix::params {

  $mynetworks_default = [ '127.0.0.1' ]
  $inetinterfaces_default = '127.0.0.1'
  $smtpdbanner_default = "${::hostname} ESMTP"
  $ipv6_default = false
  $relayhost_default = undef
  $opportunistictls_default = false
  $tlscert_default = undef
  $tlspk_default = undef
  $myhostname_default = $::hostname
  $generatecert_default = false
  $subjectselfsigned_default = undef
  $biff_default = undef
  $append_dot_mydomain_default = undef
  $readme_directory_default = '/usr/share/doc/postfix-2.6.6/README_FILES'
  $myorigin_default = $::domain
  $mydomain_default = $::domain
  $recipient_delimiter_default = undef
  $mydestination_default = [ $::fqdn, 'localhost' ]
  $virtual_alias_default = undef
  $baseconf = '/etc/postfix'
  $mail_spool_directory = '/var/mail'

  case $::osfamily
  {
    'redhat':
    {
      case $::operatingsystemrelease
      {
        /^[6-7].*$/:
        {
          $daemondirectory='/usr/libexec/postfix'
          $dependencies=['chkconfig', 'grep']
          $switch_to_postfix='alternatives --set mta /usr/sbin/sendmail.postfix'
          $check_postfix_mta='alternatives --display mta | grep postfix'
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
          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
              $daemondirectory='/usr/lib/postfix'
              $dependencies=['dpkg', 'grep', 'mailutils' ]
              $switch_to_postfix=undef
              $check_postfix_mta=undef
            }
            default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}")  }
          }
        }
        'Debian': { fail('Unsupported')  }
        default: { fail('Unsupported Debian flavour!')  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }

}
