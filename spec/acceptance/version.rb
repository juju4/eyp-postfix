
_osfamily               = fact('osfamily')
_operatingsystem        = fact('operatingsystem')
_operatingsystemrelease = fact('operatingsystemrelease').to_f

case _osfamily
when 'Debian'
  $packagename     = 'postfix'
  $servicename     = 'postfix'
else
  $packagename     = '-_-'
  $servicename     = '-_-'
end
