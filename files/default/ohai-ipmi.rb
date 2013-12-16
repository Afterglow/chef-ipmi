#
# Cookbook Name:: ohai
# Plugin:: ipmi
#
# Copyright 2012, John Dewey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Acquired from: https://bitbucket.org/retr0h/ohai.git

provides 'ipmi'

begin
  cmd = 'ipmitool lan print'
  status, stdout, stderr = run_command(:command => cmd)

  stdout =~ /IP Address\s+: ([0-9.]+).*MAC Address\s+: ([a-z0-9:]+)/m

  ipmi Mash.new
  ipmi[:address] = Regexp.last_match[1]
  ipmi[:mac_address] = Regexp.last_match[2]
rescue => e
  Chef::Log.warn "Ohai ipmi plugin failed with: '#{e}'"
end
