require "spec_helper"

package = "squid"
service = "squid"
config  = "/etc/squid/squid.conf"
user    = "squid"
group   = "squid"
ports   = [ 3128, 3180 ]
seliux_ports_udp = [ 3180, 3401, 4827 ]
log_dir = "/var/log/squid"
cache_dir  = "/var/spool/squid"
coredump_dir = "/var/spool/squid"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/squid/squid.conf"
  cache_dir = "/var/squid/cache"
  coredump_dir = "/var/squid/cache"
  default_group = "wheel"
when "ubuntu"
  user = "proxy"
  group = "proxy"
when "openbsd"
  config = "/etc/squid/squid.conf"
  cache_dir = "/var/squid/cache"
  log_dir = "/var/squid/logs"
  user = "_squid"
  group = "_squid"
  default_group = "wheel"
  coredump_dir = "/var/squid/cache"
  ports = [ 3128 ]
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
  it { should be_grouped_into os[:family] == "redhat" ? group : default_group }
  it { should be_mode os[:family] == "redhat" ? 640 : 644 }
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
    its(:content) { should match(/^squid_flags=" -u 3180"$/) }
  end
when "ubuntu"
  describe file("/etc/default/squid") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^SQUID_ARGS="-YC -f \$CONFIG -u 3180"/) }
  end
when "redhat"
  [ "libselinux-python", "policycoreutils-python" ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe file("/etc/sysconfig/squid") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^SQUID_OPTS=" -u 3180"/) }
    its(:content) { should match(/^SQUID_CONF="\/etc\/squid\/squid\.conf"/) }
  end

  describe command("semanage port -l") do
    its(:stdout) { should match(/^squid_port_t\s+udp\s+#{ Regexp.escape(seliux_ports_udp.sort.join(", ")) }$/) }
    its(:stderr) { should match(/^$/) }
    its(:exit_status) { should eq 0 }
  end
when "openbsd"
  describe file("/etc/rc.conf.local") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    # XXX service module for OpenBSD has a bug that removes lines starting with
    # service name
    # its(:content) { should match(/^squid_flags=" -u 3180"$/) }
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

describe command("env http_proxy=http://127.0.0.1:3128 HTTPS_PROXY=http://127.0.0.1:3128 curl -sL -o /dev/null -D - http://example.org") do
  its(:stdout) { should match (/^HTTP\/1\.\d 200 OK/) }
  its(:stderr) { should match (/^$/) }
  its(:exit_status) { should eq 0 }
end
