#
# Cookbook Name:: ipmi
# Recipe:: default
#
# Copyright 2012, LivingSocial
# Author: Paul Thomas <paul.thomas@livingsocial.com>
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

package "ipmitool" do
  action :install
end

kernel_module "ipmi_si" do
  action :install
end

kernel_module "ipmi_devintf" do
  action :install
end

kernel_module "ipmi_msghandler" do
  action :install
end

kernel_module "ipmi_watchdog" do
  action :install
end

service "ipmievd" do
  supports :restart => true
  action [ :enable, :start ]
end

cookbook_file "#{node[:ohai][:plugin_path]}/ipmi.rb" do
  owner "root"
  group "root"
  mode "0644"
  source "ohai-ipmi.rb"
end
