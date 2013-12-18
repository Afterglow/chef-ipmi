#
# Cookbook Name:: ohai
# Plugin:: ipmi
#
# Copyright 2012, John Dewey
# Copyright 2013, Limelight Networks, Inc.
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

  # gather IPMI interface information
  cmd = 'ipmitool lan print'
  status, stdout, stderr = run_command(:command => cmd)

  if status == 0
    ipmi Mash.new
    stdout.each_line do |line|
      case line
      when /IP Address\s+: ([0-9.]+)/
        ipmi[:address] = $1
      when /Default Gateway IP\s+: ([0-9.]+)/
        ipmi[:gateway] = $1
      when /Subnet Mask\s+: ([0-9.]+)/
        ipmi[:mask] = $1
      when /MAC Address\s+: ([a-z0-9:]+)/
        ipmi[:mac_address] = $1
      when /IP Address Source\s+: (.+)/
        ipmi[:ip_source] = $1
      end
    end
  end

  # gather IPMI System Event Log information
  cmd = 'ipmitool sel info'
  status, stdout, stderr = run_command(:command => cmd)

  if status == 0
    ipmi[:sel] = Mash.new
    stdout.each_line do |line|
      case line
      when /^Version\s+: (\d+(\.\d+)+)/
        ipmi[:sel][:version] = $1
      when /^Entries\s+: (.+)/
        ipmi[:sel][:entries] = $1.to_i
      when /^Percent Used\s+: ([0-9]+)/
        ipmi[:sel][:percent_used] = $1.to_i
      when /^Overflow\s+: ([a-z]+)/
        ipmi[:sel][:overflow] = $1 == "true" ? true : false
      end
    end
  end


rescue
  Chef::Log.warn "Ohai ipmi plugin failed with: '#{e}'"
end
