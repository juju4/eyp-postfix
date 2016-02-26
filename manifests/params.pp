class postfix::params {

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
