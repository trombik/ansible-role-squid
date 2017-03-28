require "spec_helper"

package = "squid"
service = "squid"
config  = "/etc/squid/squid.conf"
user    = "squid"
group   = "squid"
ports   = [ 3128 ]
log_dir = "/var/log/squid"
cache_dir  = "/var/lib/squid/cache"
coredump_dir = "/var/squid/cache"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/squid/squid.conf"
  cache_dir = "/var/squid/cache"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end 

describe file(cache_dir) do
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 750 }
end

describe file("#{ cache_dir }/00") do
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 750 }
end

describe file(config) do
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 644 }
  its(:content) { should match(/^http_port\s+3128$/) }
  its(:content) { should match(/^cache_dir ufs #{ Regexp.escape(cache_dir) } 100 16 256$/) }
  its(:content) { should match(/^coredump_dir #{ Regexp.escape(coredump_dir) }$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/squid") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^squid_flags="-u 3180"$/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
