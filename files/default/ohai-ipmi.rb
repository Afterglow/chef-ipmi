#
# Cookbook Name:: ohai
# Plugin:: ipmi
#
# "THE BEER-WARE LICENSE" (Revision 42):
# <john@dewey.ws> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return John-B Dewey Jr.
#
# Acquired from: https://bitbucket.org/retr0h/ohai.git

provides "ipmi"

begin
  cmd = "ipmitool lan print"
  status, stdout, stderr = run_command(:command => cmd)

  stdout =~ /IP Address\s+: ([0-9.]+).*MAC Address\s+: ([a-z0-9:]+)/m

  ipmi Mash.new
  ipmi[:address] = $1
  ipmi[:mac_address] = $2
rescue => e
  Chef::Log.warn "Ohai ipmi plugin failed with: '#{e}'"
end
