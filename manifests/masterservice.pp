define postfix::masterservice(
                                $service=$name,
                                $type,
                                $command,
                                $args = undef,
                                $private = '-',
                                $unpriv = '-',
                                $chroot = '-',
                                $wakeup = '-',
                                $maxproc = '-',
                                $comment = undef,
                                $order = '42',
  ) {

  #service type  private unpriv  chroot  wakeup  maxproc command + args

  if($args!=null)
  {
    validate_hash($args)
  }

  concat::fragment{ "/etc/postfix/master.cf ${service} ${type} ${command}":
    target  => '/etc/postfix/master.cf',
    order   => $order,
    content => template("${module_name}/mastercf/masterservice.erb"),
  }
}
