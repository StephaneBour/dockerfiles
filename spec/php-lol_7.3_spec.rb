# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe 'Dockerfile' do
  PHP_VERSION = File.basename(__FILE__)[/php-lol_(.*)_spec.rb/, 1]
  image = Docker::Image.build_from_dir(
    "#{DOCKERFILES}/php-lol/",
    'dockerfile' => "Dockerfile.#{PHP_VERSION}"
  )

  set :os, family: :debian
  set :backend, :docker
  set :docker_image, image.id

  describe command('/usr/local/sbin/php-fpm -t') do
    its(:exit_status) { should eq 0 }
  end

  describe command('/usr/sbin/nginx -t') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should contain("nginx: the configuration file /etc/nginx/nginx.conf syntax is ok\n") }
    its(:stderr) { should contain("nginx: configuration file /etc/nginx/nginx.conf test is successful\n") }
  end

  describe file('/usr/sbin/nginx') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '90c22501f528e4fa0b7d4b34ce5735b803b92e3f71a2865cb262bc69fcc908e8'
    }
  end

  describe file('/usr/local/bin/php') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        '813ee0156ad1b14222c5d28b05a881593d547e6c9c6133dd590024c5495cf768'
    }
  end

  describe file('/usr/local/sbin/php-fpm') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 755 }
    its(:sha256sum) {
      should eq \
        'e623f07ddd7114210ed53f0b2a05058386cf5334bdbefecc169b3f4f0d9f847d'
    }
  end

  describe file('/usr/local/etc/php/php.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '9abf58040f2f63c848e5db146603f53ef85c7df43182856141867eb5fe5fb957'
    }
  end

  describe file('/usr/local/etc/php/conf.d/zzz-opcache.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'e1137b3fe6413c11f9991ee422ad36d811d622b0eabdc055cc63871ad9bff52a'
    }
  end

  describe file('/usr/local/etc/php-fpm.d/zzz-php-fpm-tuning.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '0e2525ba3f120894e99bb7beebc0f41cf949361731b2d90fa8bbe273b49864d4'
    }
  end

  describe file('/usr/local/etc/php/conf.d/zzz-php-hardening.ini') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '3380e78d2cf8d6eb007677377b5634b04c6235de4b1cbda477c77b7cddf59fb9'
    }
  end

  describe file('/etc/nginx/nginx.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'c2a3b30907df02546789c3ecdb6702d83e8500d95c74f91f6cc95c6fc276fbff'
    }
  end

  describe file('/etc/nginx/mime.types') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'ac27e1f587ecebc46ded3265479efdc6cb2f711c22e8221dadb00b7b4db55369'
    }
  end

  describe file('/etc/supervisor/supervisord.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        '09c212cf4d63c17845b7d626a4ddfe8462207e8e056c893fb357a8284c64f21d'
    }
  end

  describe file('/etc/supervisor/conf.d/app.conf') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 444 }
    its(:sha256sum) {
      should eq \
        'be6a906880879641e05c8719e9d1f7f7daeb7556ab37a7bae3eae4b118506b0f'
    }
  end

  %w[
    bcmath
    exif
    gd
    geoip
    iconv
    igbinary
    intl
    mbstring
    memcached
    pdo_mysql
    pdo_pgsql
    pgsql
    posix
    redis
    soap
    sockets
    tidy
    zip
  ].each do |extension|
    describe command("php -m | grep -i #{extension}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) {
        should contain(extension)
      }
    end
  end

  %w[
    GeoIP.dat
    GeoIPv6.dat
    GeoLite2-ASN.mmdb
    GeoLite2-City.mmdb
    GeoLite2-Country.mmdb
  ].each do |geoip|
    describe file("/usr/share/GeoIP/#{geoip}") do
      it { should be_file }
      it { should be_mode 644 }
    end
  end
end
