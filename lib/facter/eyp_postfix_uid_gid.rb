postfix_uid = Facter::Util::Resolution.exec('id -u postfix 2>/dev/null').to_s
postfix_gid = Facter::Util::Resolution.exec('id -g postfix 2>/dev/null').to_s

unless postfix_uid.nil? or postfix_uid.empty?
  Facter.add('eyp_postfix_uid') do
      setcode do
        postfix_uid
      end
  end
end

unless postfix_gid.nil? or postfix_gid.empty?
  Facter.add('eyp_postfix_gid') do
      setcode do
        postfix_gid
      end
  end
end
