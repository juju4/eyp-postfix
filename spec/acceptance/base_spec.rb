require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'postfix class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

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
           smtpd_tls_protocols  => '!SSLv2,!SSLv3,!TLSv1,!TLSv1.1',
           smtp_tls_exclude_ciphers => 'aNULL, eNULL, EXP, MD5, IDEA, KRB5, RC2, SEED, SRP',
           smtpd_tls_mandatory_ciphers => 'medium',
           tls_medium_cipherlist => 'AES128+EECDH:AES128+EDH',
        }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    it "sleep 10 to make sure postfix is started" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    describe port(25) do
      it { should be_listening }
    end

    describe package($packagename) do
      it { is_expected.to be_installed }
    end

    describe service($servicename) do
      it { should be_enabled }
      it { is_expected.to be_running }
    end

    describe file('/etc/postfix/main.cf') do
      its(:content) { should match /smtp_use_tls = yes/ }
      its(:content) { should match /smtpd_use_tls = yes/ }
      its(:content) { should match /disable_vrfy_command = yes/ }
      its(:content) { should match /smtpd_helo_required = yes/ }
      its(:content) { should match /smtpd_tls_protocols = !SSLv2,!SSLv3,!TLSv1,!TLSv1.1/ }
      its(:content) { should match /smtp_tls_exclude_ciphers = aNULL, eNULL, EXP, MD5, IDEA, KRB5, RC2, SEED, SRP/ }
      its(:content) { should match /smtpd_tls_mandatory_ciphers = medium/ }
      its(:content) { should match /tls_medium_cipherlist = AES128+EECDH:AES128+EDH/ }
    end

    it "send test mail" do
      expect(shell("echo \"Testing rspec puppet DUI\" | mail root@localhost").exit_code).to be_zero
    end

    it "sleep 10 to make sure mesage is delivered" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    it "check mail reception" do
      expect(shell("grep \"Testing rspec puppet DUI\" /tmp/root").exit_code).to be_zero
    end

  end

end
