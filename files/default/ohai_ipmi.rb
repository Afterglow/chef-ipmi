#
# Cookbook Name:: ohai
# Plugin:: ipmi
# Copyright:: 2012, John Dewey
# Copyright:: 2013-2014, Limelight Networks, Inc.
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

def string_to_bool(bool_string)
  !(bool_string =~ /^(?i)true$/).nil?
end

Ohai.plugin(:Ipmi) do
  provides 'ipmi'

  collect_data(:linux) do
    begin

      # gather IPMI interface information
      so = shell_out('ipmitool lan print')

      if so.exitstatus == 0
        ipmi Mash.new
        so.stdout.lines do |line|
          case line
          when /IP Address\s+: ([0-9.]+)/
            ipmi[:address] = Regexp.last_match[1]
          when /Default Gateway IP\s+: ([0-9.]+)/
            ipmi[:gateway] = Regexp.last_match[1]
          when /Subnet Mask\s+: ([0-9.]+)/
            ipmi[:mask] = Regexp.last_match[1]
          when /MAC Address\s+: ([a-z0-9:]+)/
            ipmi[:mac_address] = Regexp.last_match[1]
          when /IP Address Source\s+: (.+)/
            ipmi[:ip_source] = Regexp.last_match[1]
          end
        end
      end

      # gather IPMI System Event Log information
      so = shell_out('ipmitool sel info')

      if so.exitstatus == 0
        ipmi[:sel] = Mash.new
        so.stdout.lines do |line|
          case line
          when /^Version\s+: (\d+(\.\d+)+)/
            ipmi[:sel][:version] = Regexp.last_match[1]
          when /^Entries\s+: (.+)/
            ipmi[:sel][:entries] = Regexp.last_match[1].to_i
          when /^Percent Used\s+: ([0-9]+)/
            ipmi[:sel][:percent_used] = Regexp.last_match[1].to_i
          when /^Overflow\s+: ([a-z]+)/
            ipmi[:sel][:overflow] = Regexp.last_match[1] == 'true' ? true : false
          end
        end
      end

      # gather IPMI Management Controller information
      so = shell_out('ipmitool mc info')

      if so.exitstatus == 0
        ipmi[:mc] = Mash.new
        so.stdout.lines do |line|
          case line
          when /^Device Revision\s+: (.+)/
            ipmi[:mc][:device_revision] = Regexp.last_match[1]
          when /^Firmware Revision\s+: (.+)/
            ipmi[:mc][:firmware_revision] = Regexp.last_match[1]
          when /^IPMI Version\s+: (.+)/
            ipmi[:mc][:ipmi_version] = Regexp.last_match[1]
          when /^Manufacturer ID\s+: (.+)/
            ipmi[:mc][:manufacturer_id] = Regexp.last_match[1]
          when /^Product ID\s+: (.+)/
            ipmi[:mc][:product_id] = Regexp.last_match[1]
          end
        end
      end

      (0..15).each do |channel_id|
        so = shell_out("ipmitool channel info #{channel_id}")

        next unless so.exitstatus == 0
        ipmi[:channels] ||= Mash.new
        ipmi[:channels][channel_id] = Mash.new
        so.stdout.lines do |line|
          case line
          when /^\s*Channel Medium Type\s+: (.+)/
            ipmi[:channels][channel_id][:medium_type] = Regexp.last_match[1]
          when /^\s*Channel Protocol Type\s+: (.+)/
            ipmi[:channels][channel_id][:protocol_type] = Regexp.last_match[1]
          when /^\s*Session Support\s+: (.+)/
            ipmi[:channels][channel_id][:session_support] = Regexp.last_match[1]
          when /^\s*Active Session Count\s+: (.+)/
            ipmi[:channels][channel_id][:active_session_count] = Regexp.last_match[1]
          when /^\s*Protocol Vendor ID\s+: (.+)/
            ipmi[:channels][channel_id][:protocol_vendor_id] = Regexp.last_match[1]
          end
        end

        users_so = shell_out("ipmitool user list #{channel_id}")

        next unless users_so.exitstatus == 0
        ipmi[:channels][channel_id][:users] = Mash.new
        users_so.stdout.lines do |users_line|
          if users_line =~ /^\s*(\d+)\s+(\w+)\s+(true|false)\s+(true|false)\s+(true|false)\s+(?i)(callback|user|operator|administrator)$/
            ipmi[:channels][channel_id][:users][Regexp.last_match[1]] = { name: Regexp.last_match[2],
                                                                          callin: string_to_bool(Regexp.last_match[3]),
                                                                          link_auth: string_to_bool(Regexp.last_match[4]),
                                                                          ipmi_msg: string_to_bool(Regexp.last_match[5]),
                                                                          channel_priv: Regexp.last_match[6] }
          end
        end
      end
    rescue
      Chef::Log.warn 'Ohai ipmi plugin failed to run'
    end
  end
end
