postfix_version = Facter::Util::Resolution.exec('postconf -d | grep "^mail_version" | head -n1 | awk \'{ print $NF }\'').to_s

unless postfix_version.nil? or postfix_version.empty?
  Facter.add('eyp_postfix_version') do
      setcode do
        postfix_version
      end
  end
end
