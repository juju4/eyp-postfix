require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'postfix class' do

  context 'vmail setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'postfix': }

    	class { 'postfix::vmail': }

    	postfix::transport { 'example.com':
    		error => 'email to this domain is not allowed',
    	}

      postfix::transport { 'systemadmin.es':
        transport_noop => true,
      }

    	postfix::vmail::alias { 'd9abea179bca9c44bdafd19c43c8ad55@d9abea179bca9c44bdafd19c43c8ad55.com':
    		aliasto => [ 'd9abea179bca9c44bdafd19c43c8ad55@6cf31108ba1c3fb808e9a276623e87ed.com' ],
    	}

    	postfix::vmail::account { 'd9abea179bca9c44bdafd19c43c8ad55@6cf31108ba1c3fb808e9a276623e87ed.com':
    		accountname => 'd9abea179bca9c44bdafd19c43c8ad55',
    		domain => '6cf31108ba1c3fb808e9a276623e87ed.com',
    		password => 'd59f50bcb24e81f8eb4d6a0ac438729e',
    	}

    	postfix::vmail::account { '6cf31108ba1c3fb808e9a276623e87ed@6cf31108ba1c3fb808e9a276623e87ed.com':
    		accountname => '6cf31108ba1c3fb808e9a276623e87ed',
    		domain => '6cf31108ba1c3fb808e9a276623e87ed.com',
    		password => 'd59f50bcb24e81f8eb4d6a0ac438729e',
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

    # entrega mail
    #
    it "send test mail" do
      expect(shell("echo \"Testing rspec puppet DUI\" | mail d9abea179bca9c44bdafd19c43c8ad55@d9abea179bca9c44bdafd19c43c8ad55.com").exit_code).to be_zero
    end

    it "send test mail" do
      expect(shell("echo \"Testing rspec puppet IN INDE INDEPENDENCIA\" | mail d9abea179bca9c44bdafd19c43c8ad55@6cf31108ba1c3fb808e9a276623e87ed.com").exit_code).to be_zero
    end

    it "sleep 10 to make sure mesage is delivered" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    it "check account" do
      expect(shell("grep \"Testing rspec puppet DUI\" /var/vmail/ -R").exit_code).to be_zero
    end

    it "check alias" do
      expect(shell("grep \"Testing rspec puppet IN INDE INDEPENDENCIA\" /var/vmail/ -R").exit_code).to be_zero
    end

    #
    describe file("/etc/postfix/transport") do
      it { should be_file }
      its(:content) { should match 'email to this domain is not allowed' }
    end

  end

end
