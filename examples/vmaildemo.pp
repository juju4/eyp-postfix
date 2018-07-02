class { 'postfix': }

class { 'postfix::vmail': }

postfix::vmail::alias { 'example@systemadmin.es':
  aliasto => [ 'exemple@systemadmin.es' ],
}

postfix::vmail::account { 'example@systemadmin.es':
  accountname => 'example',
  domain      => 'systemadmin.es',
  password    => 'secretpassw0rd',
}

postfix::vmail::account { 'silvia@systemadmin.es':
  accountname => 'silvia',
  domain      => 'systemadmin.es',
  password    => 'secretpassw0rd2',
}

postfix::vmail::account { 'marc@systemadmin.es':
  accountname => 'marc',
  domain      => 'systemadmin.es',
  password    => 'secretpassw0rd3',
}
