#
# Cookbook Name:: ipmi
# Attributes:: default
#

default['ipmi_cookbook']['packages']  = %w(ipmitool openipmi freeipmi-tools)

default['ipmi_cookbook']['kernel_modules'] = %w(ipmi_si ipmi_devintf ipmi_msghandler ipmi_watchdog)

default['ipmi_cookbook']['users'] = {}
default['ipmi_cookbook']['lan'] = {}
