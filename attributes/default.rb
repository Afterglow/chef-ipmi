#
# Cookbook Name:: ipmi
# Attributes:: default
#

default['ipmi']['kernel_modules'] = %w{ipmi_si ipmi_devintf ipmi_msghandler ipmi_watchdog}
