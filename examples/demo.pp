class { 'postfix':
  mynetworks           => [ '127.0.0.0/8' ],
  ipv6                 => false,
  inetinterfaces       => 'all',
  smtpdbanner          => "\\${myhostname} ESMTP \\${mail_name}",
  biff                 => false,
  append_dot_mydomain  => false,
  readme_directory     => false,
  myorigin             => 'test.es',
  recipient_delimiter  => '+',
  mail_spool_directory => '/tmp',
  home_mailbox         => '',
}
