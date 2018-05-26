# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe 'Dockerfile' do
  dockerfile_dir = File.basename(__FILE__)[/(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir("#{DOCKERFILES}/#{dockerfile_dir}/")

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/bin/dnscrypt-proxy -version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "2.0.14\n" }
  end

  describe file('/usr/local/bin/dnscrypt-proxy') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'd67964bfa9107bbccc799d75c5ea2c41e5edbe042873a1b7e8b75958261bc88a'
    }
  end

  describe file('/etc/dnscrypt-proxy.toml') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its(:sha256sum) {
      should eq \
        '55c0c2ddbb6f4592dacb7ad82ce2297d2731404e96b742082401fa6de0edf51e'
    }
    it { should contain('block_ipv6 = false') }
    it { should contain('cache = true') }
    it { should contain('cache_max_ttl = 86400') }
    it { should contain('cache_min_ttl = 600') }
    it { should contain('cache_neg_ttl = 60') }
    it { should contain('cache_size = 16000') }
    it { should contain('cert_refresh_delay = 240') }
    it { should contain('daemonize = false') }
    it { should contain('dnscrypt_servers = true') }
    it { should contain('doh_servers = true') }
    it { should contain("fallback_resolver = '1.0.0.1:53'") }
    it { should contain('force_tcp = false') }
    it { should contain('ignore_system_dns = true') }
    it { should contain('ipv4_servers = true') }
    it { should contain('ipv6_servers = false') }
    it { should contain('keepalive = 20') }
    it { should contain("lb_strategy = 'p2'") }
    it { should contain("listen_addresses = ['0.0.0.0:53']") }
    it { should contain('max_clients = 100') }
    it { should contain('require_dnssec = false') }
    it { should contain('require_nofilter = true') }
    it { should contain('require_nolog = true') }
    it { should contain('timeout = 3000') }
    it { should contain("blacklist_file = '/etc/dnscrypt-proxy-blacklist.txt'") }
    it { should contain("urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']") }
    it { should contain("cache_file = '/dev/shm/public-resolvers.md'") }
    it { should contain("format = 'v2'") }
    it { should contain("minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'") }
    it { should contain('refresh_delay = 72') }
    it { should contain("prefix = ''") }
  end

  describe port(53) do
    it { should be_listening.with('tcp') }
  end

  describe port(53) do
    it { should be_listening.with('udp') }
  end

  describe command('dig +time=5 +tries=1 @127.0.0.1 -p 53 localhost') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: NOERROR')
      should contain('QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1')
    }
  end

  describe command('dig +time=5 +tries=1 @127.0.0.1 -p 53 bds.io') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: NOERROR')
      should contain('QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1')
    }
  end

  describe command("dig +time=5 +tries=1 @127.0.0.1 -p 53 #{SecureRandom.hex}") do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: NXDOMAIN')
    }
    its(:stdout) {
      should contain('QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1')
    }
  end

  describe command('dig +time=5 +tries=1 @127.0.0.1 -p 53 $(shuf -n 1 /etc/dnscrypt-proxy-blacklist.txt)') do
    its(:exit_status) { should eq 0 }
    its(:stdout) {
      should contain('status: REFUSED')
    }
    its(:stdout) {
      should contain('QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0')
    }
  end
end
