# frozen_string_literal: true

require 'spec_helper'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe file('/usr/bin/radicale') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '1fcaae49b3b7d820ac10fe47fcdaa969cf086fea12f9aa14faaafec79a756c5b'
    }
  end

  describe file('/config/radicale.cfg') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        'c60dbb07a5bfa69c020d1229409ce60c511629669d3f96650472cb8e0fd3cc37'
    }
    it { should contain('hosts = 0.0.0.0:5232, [::]:5232') }
    it { should contain('daemon = False') }
    it { should contain('pid =') }
    it { should contain('max_connections = 20') }
    it { should contain('max_content_length = 10000000') }
    it { should contain('timeout = 10') }
    it { should contain('dns_lookup = True') }
    it { should contain('type = htpasswd') }
    it { should contain('htpasswd_filename = /config/users') }
    it { should contain('htpasswd_encryption = bcrypt') }
    it { should contain('delay = 1') }
    it { should contain('type = owner_only') }
    it { should contain('type = multifilesystem') }
    it { should contain('filesystem_folder = /data/collections') }
    it { should contain('mask_passwords = True') }
  end

  describe command('curl --fail -s http://127.0.0.1:5232/.web') do
    its(:exit_status) { should eq 0 }
  end

  describe port(5232) do
    it { should be_listening.with('tcp') }
  end
end
