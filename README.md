# ansible-role-squid

Configures  `squid` proxy.

## Notes for OpenBSD

Currently, `squid_flags` does not work.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `squid_user` | user name of `squid` | `{{ __squid_user }}` |
| `squid_group` | group name of `squid` | `{{ __squid_group }}` |
| `squid_log_dir` | log directory | `{{ __squid_log_dir }}` |
| `squid_cache_dir` | cache directory | `{{ __squid_cache_dir }}` |
| `squid_coredump_dir` | core dump directory | `{{ __squid_coredump_dir }}` |
| `squid_package` | package name of `squid` | `{{ __squid_package }}` |
| `squid_bin` | `basename` of `squid` binary | `{{ __squid_bin }}` |
| `squid_service` | service name of `squid` | `{{ __squid_service }}` |
| `squid_conf_dir` path to config directory | | `{{ __squid_conf_dir }}` |
| `squid_conf_file` | path to `squid.conf` | `{{ __squid_conf_dir }}/squid.conf` |
| `squid_flags` | flags to pass `squid` | `{{ __squid_flags }}` |
| `squid_selinux_port_tcp` | list of TCP `squid_port_t` (SELinux) | `[3128, 3401, 4827]` |
| `squid_selinux_port_udp` | list of UDP `squid_port_t` (SELinux) | `[3401, 4827]` |
| `squid_selinux_squid_connect_any` | enable `squid_connect_any` (SELinux) | `yes` |
| `squid_config` | content of `squid.conf` | `""` |


## Debian

| Variable | Default |
|----------|---------|
| `__squid_user` | `proxy` |
| `__squid_group` | `proxy` |
| `__squid_package` | `{% if ansible_distribution == 'Debian' %}squid3{% else %}squid{% endif %}` |
| `__squid_service` | `{{ __squid_package }}` |
| `__squid_bin` | `{{ __squid_package }}` |
| `__squid_cache_dir` | `/var/spool/{{ __squid_package }}` |
| `__squid_conf_dir` | `/etc/{{ __squid_package }}` |
| `__squid_coredump_dir` | `/var/spool/{{ __squid_package }}` |
| `__squid_log_dir` | `/var/log/{{ __squid_package }}` |
| `__squid_flags` | `-YC -f $CONFIG` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__squid_user` | `squid` |
| `__squid_group` | `squid` |
| `__squid_package` | `squid` |
| `__squid_service` | `squid` |
| `__squid_bin` | `squid` |
| `__squid_cache_dir` | `/var/squid/cache` |
| `__squid_conf_dir` | `/usr/local/etc/squid` |
| `__squid_coredump_dir` | `/var/squid/cache` |
| `__squid_log_dir` | `/var/log/squid` |
| `__squid_flags` | `""` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__squid_user` | `_squid` |
| `__squid_group` | `_squid` |
| `__squid_package` | `squid` |
| `__squid_service` | `squid` |
| `__squid_bin` | `squid` |
| `__squid_cache_dir` | `/var/squid/cache` |
| `__squid_conf_dir` | `/etc/squid` |
| `__squid_coredump_dir` | `/var/squid/cache` |
| `__squid_log_dir` | `/var/squid/logs` |
| `__squid_flags` | `""` |

## RedHat

| Variable | Default |
|----------|---------|
| `__squid_user` | `squid` |
| `__squid_group` | `squid` |
| `__squid_package` | `squid` |
| `__squid_service` | `squid` |
| `__squid_bin` | `squid` |
| `__squid_cache_dir` | `/var/spool/squid` |
| `__squid_conf_dir` | `/etc/squid` |
| `__squid_coredump_dir` | `/var/spool/squid` |
| `__squid_log_dir` | `/var/log/squid` |
| `__squid_flags` | `""` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-squid
  vars:
    squid_flags: "{{ __squid_flags }} -u 3180"
    squid_config: |
      acl localnet src 10.0.0.0/8
      acl localnet src 172.16.0.0/12
      acl localnet src 192.168.0.0/16
      acl localnet src fc00::/7
      acl localnet src fe80::/10
      acl SSL_ports port 443
      acl Safe_ports port 80
      acl Safe_ports port 21
      acl Safe_ports port 443
      acl CONNECT method CONNECT
      http_access deny !Safe_ports
      http_access deny CONNECT !SSL_ports
      http_access allow localhost manager
      http_access deny manager
      http_access deny to_localhost
      http_access allow localnet
      http_access allow localhost
      http_access deny all
      http_port 3128
      cache_dir ufs {{ squid_cache_dir }} 100 16 256
      coredump_dir {{ squid_coredump_dir }}
    squid_selinux_port_udp: [ 3401, 4827, 3180 ]
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
