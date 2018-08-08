class { 'postfix': }

class { 'postfix::vmail': }

postfix::vmail::alias { 'example@systemadmin.es':
  aliasto => [ 'exemple@systemadmin.es' ],
}

postfix::vmail::alias { 'example@saltait.com':
  aliasto       => [ 'exemple@saltait.com' ],
  instance_name => 'instance_2',
}
