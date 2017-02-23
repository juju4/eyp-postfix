
_osfamily               = fact('osfamily')
_operatingsystem        = fact('operatingsystem')
_operatingsystemrelease = fact('operatingsystemrelease').to_f

case _osfamily
when 'RedHat'
  $packagename = 'postfix'
  $servicename = 'postfix'
  $maillog = '/var/log/maillog'
when 'Debian'
  $packagename = 'postfix'
  $servicename = 'postfix'
  $maillog = '/var/log/mail.log'
else
  $packagename = '-_-'
  $servicename = '-_-'
end
