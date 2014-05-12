# encoding: UTF-8
#
########################################################################
# Toggles - These can be overridden at the environment level
default['enable_monit'] = false  # OS provides packages
########################################################################

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['compute']['custom_template_banner'] = '
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
'

# The name of the Chef role that knows about the message queue server
# that Nova uses
default['openstack']['compute']['rabbit_server_chef_role'] = 'os-ops-messaging'

default['openstack']['compute']['verbose'] = 'False'
default['openstack']['compute']['debug'] = 'False'

default['openstack']['compute']['state_path'] = '/var/lib/nova'
default['openstack']['compute']['instances_path'] =
  "#{node['openstack']['compute']['state_path']}/instances"
default['openstack']['compute']['network_allocate_retries'] = 0
default['openstack']['compute']['instance_name_template'] = 'instance-%08x'

# The lock_path normally uses /var/lock/nova, but it's not allowed in openSUSE,
# so setting lock_path to $state_path/lock like in Neutron.
default['openstack']['compute']['lock_path'] =
  "#{node['openstack']['compute']['state_path']}/lock"

# The name of the Chef role that sets up the Keystone Service API
default['openstack']['compute']['identity_service_chef_role'] = 'os-identity'

# Common rpc definitions
default['openstack']['compute']['rpc_thread_pool_size'] = 64
default['openstack']['compute']['rpc_conn_pool_size'] = 30
default['openstack']['compute']['rpc_response_timeout'] = 60
case node['openstack']['mq']['service_type']
when 'rabbitmq'
  default['openstack']['compute']['rpc_backend'] = 'nova.openstack.common.rpc.impl_kombu'
when 'qpid'
  default['openstack']['compute']['rpc_backend'] = 'nova.openstack.common.rpc.impl_qpid'
end

default['openstack']['compute']['service_tenant_name'] = 'service'
default['openstack']['compute']['service_user'] = 'nova'
default['openstack']['compute']['service_role'] = 'admin'

case platform_family
when 'fedora', 'rhel', 'debian'
  default['openstack']['compute']['user'] = 'nova'
  default['openstack']['compute']['group'] = 'nova'
when 'suse'
  default['openstack']['compute']['user'] = 'openstack-nova'
  default['openstack']['compute']['group'] = 'openstack-nova'
end

# Logging stuff
default['openstack']['compute']['log_dir'] = '/var/log/nova'

default['openstack']['compute']['syslog']['use'] = false
default['openstack']['compute']['syslog']['facility'] = 'LOG_LOCAL1'
default['openstack']['compute']['syslog']['config_facility'] = 'local1'

default['openstack']['compute']['region'] = node['openstack']['region']

default['openstack']['compute']['floating_cmd'] = '/usr/local/bin/add_floaters.py'

# Support multiple network types.  Default network type is 'nova'
# with the other option supported being 'neutron'
default['openstack']['compute']['network']['service_type'] = 'nova'

# if the network type is not nova, we will load the following
# plugins from openstack-network
default['openstack']['compute']['network']['plugins'] = ['openvswitch']

# Neutron options
default['openstack']['compute']['network']['neutron']['network_api_class'] = 'nova.network.neutronv2.api.API'
default['openstack']['compute']['network']['neutron']['auth_strategy'] = 'keystone'
default['openstack']['compute']['network']['neutron']['admin_tenant_name'] = 'service'
default['openstack']['compute']['network']['neutron']['admin_username'] = 'neutron'
default['openstack']['compute']['network']['neutron']['libvirt_vif_driver'] = 'nova.virt.libvirt.vif.LibvirtGenericVIFDriver'
default['openstack']['compute']['network']['neutron']['linuxnet_interface_driver'] = 'nova.network.linux_net.LinuxOVSInterfaceDriver'
default['openstack']['compute']['network']['neutron']['security_group_api'] = 'neutron'
default['openstack']['compute']['network']['neutron']['service_neutron_metadata_proxy'] = true
default['openstack']['compute']['network']['neutron']['metadata_secret_name'] = 'neutron_metadata_shared_secret'
default['openstack']['compute']['network']['neutron']['public_network_name'] = 'public'
default['openstack']['compute']['network']['neutron']['dns_server'] = '8.8.8.8'

# TODO(shep): This should probably be ['openstack']['compute']['network']['fixed']
default['openstack']['compute']['networks'] = [
  {
    'label' => 'public',
    'ipv4_cidr' => '192.168.100.0/24',
    'num_networks' => '1',
    'network_size' => '255',
    'bridge' => 'br100',
    'bridge_dev' => 'eth2',
    'dns1' => '8.8.8.8',
    'dns2' => '8.8.4.4',
    'multi_host' => 'T'
  },
  {
    'label' => 'private',
    'ipv4_cidr' => '192.168.200.0/24',
    'num_networks' => '1',
    'network_size' => '255',
    'bridge' => 'br200',
    'bridge_dev' => 'eth3',
    'dns1' => '8.8.8.8',
    'dns2' => '8.8.4.4',
    'multi_host' => 'T'
  }
]

# For VLAN Networking, do the following:
#
# default['openstack']['compute']['network']['network_manager'] = 'nova.network.manager.VlanManager'
# default['openstack']['compute']['network']['vlan_interface'] = 'eth1'  # Or 'eth2', 'bond1', etc...
#
# In addition to the above, you typically either want to do one of the following:
#
# 1) Set default['openstack']['compute']['networks'] to an empty Array ([]) and create your
#    VLAN networks (using nova-manage network create) **when you create a tenant**.
#
# 2) Set default['openstack']['compute']['networks'] to an Array of VLAN networks that get created
#    **without a tenant assignment** for tenants to use when they are created later.
#    Such an array might look like this:
#
#    default['openstack']['compute']['networks'] = [
#       {
#         'label': 'vlan100',
#         'vlan': '100',
#         'ipv4_cidr': '10.0.100.0/24'
#       },
#       {
#         'label': 'vlan101',
#         'vlan': '101',
#         'ipv4_cidr': '10.0.101.0/24'
#       },
#       {
#         'label': 'vlan102',
#         'vlan': '102',
#         'ipv4_cidr': '10.0.102.0/24'
#       },
#   ]

default['openstack']['compute']['network']['multi_host'] = false
# DMZ CIDR is a range of IP addresses that should not
# have their addresses SNAT'ed by the nova network controller
default['openstack']['compute']['network']['dmz_cidr'] = '10.128.0.0/24'
default['openstack']['compute']['network']['network_manager'] = 'nova.network.manager.FlatDHCPManager'
default['openstack']['compute']['network']['public_interface'] = 'eth0'
default['openstack']['compute']['network']['vlan_interface'] = 'eth0'
default['openstack']['compute']['network']['auto_assign_floating_ip'] = false
# https://bugs.launchpad.net/nova/+bug/1075859
default['openstack']['compute']['network']['use_single_default_gateway'] = false

default['openstack']['compute']['scheduler']['scheduler_driver'] = 'nova.scheduler.filter_scheduler.FilterScheduler'
default['openstack']['compute']['scheduler']['default_filters'] = %W(
  AvailabilityZoneFilter
  RamFilter
  ComputeFilter
  CoreFilter
  SameHostFilter
  DifferentHostFilter)

default['openstack']['compute']['driver'] = 'libvirt.LibvirtDriver'
default['openstack']['compute']['libvirt']['virt_type'] = 'kvm'
default['openstack']['compute']['libvirt']['auth_tcp'] = 'none'
default['openstack']['compute']['libvirt']['remove_unused_base_images'] = true
default['openstack']['compute']['libvirt']['remove_unused_resized_minimum_age_seconds'] = 3600
default['openstack']['compute']['libvirt']['remove_unused_original_minimum_age_seconds'] = 3600
default['openstack']['compute']['libvirt']['checksum_base_images'] = false
# libvirt.max_clients (default: 20)
default['openstack']['compute']['libvirt']['max_clients'] = 20
# libvirt.max_workers (default: 20)
default['openstack']['compute']['libvirt']['max_workers'] = 20
# libvirt.max_requests (default: 20)
default['openstack']['compute']['libvirt']['max_requests'] = 20
# libvirt.max_client_requests (default: 5)
default['openstack']['compute']['libvirt']['max_client_requests'] = 5
if node['platform'] == 'suse'
  default['openstack']['compute']['libvirt']['group'] = 'libvirt'
else
  default['openstack']['compute']['libvirt']['group'] = 'libvirtd'
end
default['openstack']['compute']['libvirt']['libvirt_inject_key'] = true
default['openstack']['compute']['libvirt']['libvirt_inject_password'] = false
# VM Images format. Acceptable values are: raw, qcow2, lvm,
# rbd, default. If default is specified, then use_cow_images
# flag is used instead of this one. (string value)
# (The cookbook doesn't set that value, so if you want cow, set qcow2 here.)
default['openstack']['compute']['libvirt']['images_type'] = 'default'
# lvm
default['openstack']['compute']['libvirt']['volume_group'] = nil
default['openstack']['compute']['libvirt']['sparse_logical_volumes'] = false
# rbd
default['openstack']['compute']['libvirt']['images_rbd_pool'] = 'rbd'
default['openstack']['compute']['libvirt']['images_rbd_ceph_conf'] = '/etc/ceph/ceph.conf'
# use a different backend for volumes, allowed options: rbd
default['openstack']['compute']['libvirt']['volume_backend'] = nil
default['openstack']['compute']['libvirt']['rbd']['rbd_secret_name'] = 'rbd_secret_uuid'
default['openstack']['compute']['libvirt']['rbd']['rbd_user'] = 'cinder'
default['openstack']['compute']['config']['availability_zone'] = 'nova'
default['openstack']['compute']['config']['storage_availability_zone'] = 'nova'
default['openstack']['compute']['config']['default_schedule_zone'] = 'nova'
default['openstack']['compute']['config']['force_raw_images'] = false
default['openstack']['compute']['config']['allow_same_net_traffic'] = true
default['openstack']['compute']['config']['osapi_max_limit'] = 1000
default['openstack']['compute']['config']['cpu_allocation_ratio'] = 16.0
default['openstack']['compute']['config']['ram_allocation_ratio'] = 1.5
default['openstack']['compute']['config']['disk_allocation_ratio'] = 1.0
default['openstack']['compute']['config']['snapshot_image_format'] = 'qcow2'
default['openstack']['compute']['config']['allow_resize_to_same_host'] = false
# `start` will cause nova-compute to error out if a VM is already running, where
# `resume` checks to see if it is running first.
default['openstack']['compute']['config']['start_guests_on_host_boot'] = false
# requires https://review.openstack.org/#/c/8423/
default['openstack']['compute']['config']['resume_guests_state_on_host_boot'] = true

# force_config_drive can be nil or 'always',
# if it's 'always', nova will create a config drive regardless of if the user specified --config-drive true in their nova boot call
default['openstack']['compute']['config']['force_config_drive'] = nil
default['openstack']['compute']['config']['mkisofs_cmd'] = 'genisoimage'
default['openstack']['compute']['config']['injected_network_template'] = '$pybasedir/nova/virt/interfaces.template'

# Volume API class (driver)
default['openstack']['compute']['config']['volume_api_class'] = 'nova.volume.cinder.API'

# quota settings
default['openstack']['compute']['config']['quota_security_groups'] = 50
default['openstack']['compute']['config']['quota_security_group_rules'] = 20
# (StrOpt) default driver to use for quota checks (default: nova.quota.DbQuotaDriver)
default['openstack']['compute']['config']['quota_driver'] = 'nova.quota.DbQuotaDriver'
# number of instance cores allowed per project (default: 20)
default['openstack']['compute']['config']['quota_cores'] = 20
# number of fixed ips allowed per project (this should be at least the number of instances allowed) (default: -1)
default['openstack']['compute']['config']['quota_fixed_ips'] = -1
# number of floating ips allowed per project (default: 10)
default['openstack']['compute']['config']['quota_floating_ips'] = 10
# number of bytes allowed per injected file (default: 10240)
default['openstack']['compute']['config']['quota_injected_file_content_bytes'] = 10240
# number of bytes allowed per injected file path (default: 255)
default['openstack']['compute']['config']['quota_injected_file_path_bytes'] = 255
# number of injected files allowed (default: 5)
default['openstack']['compute']['config']['quota_injected_files'] = 5
# number of instances allowed per project (defailt: 10)
default['openstack']['compute']['config']['quota_instances'] = 10
# number of key pairs per user (default: 100)
default['openstack']['compute']['config']['quota_key_pairs'] = 100
# number of metadata items allowed per instance (default: 128)
default['openstack']['compute']['config']['quota_metadata_items'] = 128
# megabytes of instance ram allowed per project (default: 51200)
default['openstack']['compute']['config']['quota_ram'] = 51200
# disk cache modes
default['openstack']['compute']['config']['disk_cache_modes'] = nil

default['openstack']['compute']['ratelimit']['settings'] = {
  'generic-post-limit' => { 'verb' => 'POST', 'uri' => '*', 'regex' => '.*', 'limit' => '10', 'interval' => 'MINUTE' },
  'create-servers-limit' => { 'verb' => 'POST', 'uri' => '*/servers', 'regex' => '^/servers', 'limit' => '50', 'interval' => 'DAY' },
  'generic-put-limit' => { 'verb' => 'PUT', 'uri' => '*', 'regex' => '.*', 'limit' => '10', 'interval' => 'MINUTE' },
  'changes-since-limit' => { 'verb' => 'GET', 'uri' => '*changes-since*', 'regex' => '.*changes-since.*', 'limit' => '3', 'interval' => 'MINUTE' },
  'generic-delete-limit' => { 'verb' => 'DELETE', 'uri' => '*', 'regex' => '.*', 'limit' => '100', 'interval' => 'MINUTE' }
}

# Metering settings
default['openstack']['compute']['metering'] = false

# Notification settings
if node['openstack']['compute']['metering']
  default['openstack']['compute']['config']['notification_drivers'] = ['nova.openstack.common.notifier.rpc_notifier', 'ceilometer.compute.nova_notifier']
  default['openstack']['compute']['config']['instance_usage_audit'] = 'True'
  default['openstack']['compute']['config']['instance_usage_audit_period'] = 'hour'
  default['openstack']['compute']['config']['notify_on_state_change'] = 'vm_and_task_state'
else
  default['openstack']['compute']['config']['notification_drivers'] = []
  default['openstack']['compute']['config']['instance_usage_audit'] = 'False'
  default['openstack']['compute']['config']['instance_usage_audit_period'] = 'month'
  default['openstack']['compute']['config']['notify_on_state_change'] = ''
end

# Keystone settings
default['openstack']['compute']['api']['auth_strategy'] = 'keystone'

default['openstack']['compute']['api']['auth']['version'] = node['openstack']['api']['auth']['version']

# Keystone PKI signing directories
default['openstack']['compute']['api']['auth']['cache_dir'] = '/var/cache/nova/api'

# Perform nova-conductor operations locally (boolean value)
default['openstack']['compute']['conductor']['use_local'] = 'False'

default['openstack']['compute']['network']['force_dhcp_release'] = true

case platform_family
when 'fedora', 'rhel', 'suse' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['compute']['platform'] = {
    'mysql_python_packages' => ['MySQL-python'],
    'db2_python_packages' => ['python-ibm-db', 'python-ibm-db-sa'],
    'postgresql_python_packages' => ['python-psycopg2'],
    'api_ec2_packages' => ['openstack-nova-api'],
    'api_ec2_service' => 'openstack-nova-api',
    'api_os_compute_packages' => ['openstack-nova-api'],
    'api_os_compute_service' => 'openstack-nova-api',
    'neutron_python_packages' => ['python-neutronclient', 'pyparsing'],
    'memcache_python_packages' => ['python-memcached'],
    'compute_api_metadata_packages' => ['openstack-nova-api'],
    'compute_api_metadata_service' => 'openstack-nova-api',
    'compute_client_packages' => ['python-novaclient'],
    'compute_compute_packages' => ['openstack-nova-compute'],
    'qemu_compute_packages' => [],
    'kvm_compute_packages' => [],
    'compute_compute_service' => 'openstack-nova-compute',
    'compute_network_packages' => ['iptables', 'openstack-nova-network'],
    'compute_network_service' => 'openstack-nova-network',
    'compute_scheduler_packages' => ['openstack-nova-scheduler'],
    'compute_scheduler_service' => 'openstack-nova-scheduler',
    'compute_conductor_packages' => ['openstack-nova-conductor'],
    'compute_conductor_service' => 'openstack-nova-conductor',
    'compute_vncproxy_packages' => ['openstack-nova-novncproxy'],
    'compute_vncproxy_service' => 'openstack-nova-novncproxy',
    'compute_vncproxy_consoleauth_packages' => ['openstack-nova-console'],
    'compute_vncproxy_consoleauth_service' => 'openstack-nova-consoleauth',
    'libvirt_packages' => ['libvirt'],
    'libvirt_service' => 'libvirtd',
    'libvirt_ceph_packages' => ['ceph-common'],
    'dbus_service' => 'messagebus',
    'compute_cert_packages' => ['openstack-nova-cert'],
    'compute_cert_service' => 'openstack-nova-cert',
    'mysql_service' => 'mysqld',
    'common_packages' => ['openstack-nova-common'],
    'iscsi_helper' => 'ietadm',
    'nfs_packages' => ['nfs-utils', 'nfs-utils-lib'],
    'package_overrides' => ''
  }
  if platform_family == 'suse'
    default['openstack']['compute']['platform']['mysql_python_packages'] = ['python-mysql']
    default['openstack']['compute']['platform']['dbus_service'] = 'dbus'
    default['openstack']['compute']['platform']['neutron_python_packages'] = ['python-neutronclient', 'python-pyparsing']
    default['openstack']['compute']['platform']['common_packages'] = ['openstack-nova']
    default['openstack']['compute']['platform']['kvm_packages'] = ['kvm']
    default['openstack']['compute']['platform']['xen_packages'] = ['kernel-xen', 'xen', 'xen-tools']
    default['openstack']['compute']['platform']['lxc_packages'] = ['lxc']
    default['openstack']['compute']['platform']['nfs_packages'] = ['nfs-utils']
  end
  # Since the bug (https://bugzilla.redhat.com/show_bug.cgi?id=788485) not released in epel yet
  # For 'fedora', 'redhat', 'centos', we need set the default value of force_dhcp_release is 'false'
  default['openstack']['compute']['network']['force_dhcp_release'] = false
when 'debian'
  default['openstack']['compute']['platform'] = {
    'mysql_python_packages' => ['python-mysqldb'],
    'postgresql_python_packages' => ['python-psycopg2'],
    'api_ec2_packages' => ['nova-api-ec2'],
    'api_ec2_service' => 'nova-api-ec2',
    'api_os_compute_packages' => ['nova-api-os-compute'],
    'api_os_compute_service' => 'nova-api-os-compute',
    'memcache_python_packages' => ['python-memcache'],
    'neutron_python_packages' => ['python-neutronclient', 'python-pyparsing'],
    'compute_api_metadata_packages' => ['nova-api-metadata'],
    'compute_api_metadata_service' => 'nova-api-metadata',
    'compute_client_packages' => ['python-novaclient'],
    'compute_compute_packages' => ['nova-compute'],
    'qemu_compute_packages' => ['nova-compute-qemu'],
    'kvm_compute_packages' => ['nova-compute-kvm'],
    'compute_compute_service' => 'nova-compute',
    'compute_network_packages' => ['iptables', 'nova-network'],
    'compute_network_service' => 'nova-network',
    'compute_scheduler_packages' => ['nova-scheduler'],
    'compute_scheduler_service' => 'nova-scheduler',
    'compute_conductor_packages' => ['nova-conductor'],
    'compute_conductor_service' => 'nova-conductor',
    # Websockify is needed due to https://bugs.launchpad.net/ubuntu/+source/nova/+bug/1076442
    'compute_vncproxy_packages' => ['novnc', 'websockify', 'nova-novncproxy'],
    'compute_vncproxy_service' => 'nova-novncproxy',
    'compute_vncproxy_consoleauth_packages' => ['nova-consoleauth'],
    'compute_vncproxy_consoleauth_service' => 'nova-consoleauth',
    'libvirt_packages' => ['libvirt-bin'],
    'libvirt_service' => 'libvirt-bin',
    'libvirt_ceph_packages' => ['ceph-common'],
    'dbus_service' => 'dbus',
    'compute_cert_packages' => ['nova-cert'],
    'compute_cert_service' => 'nova-cert',
    'mysql_service' => 'mysql',
    'common_packages' => ['nova-common'],
    'iscsi_helper' => 'tgtadm',
    'nfs_packages' => ['nfs-common'],
    'package_overrides' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end

# plugins
default['openstack']['compute']['plugins'] = nil
default['openstack']['compute']['misc_nova'] = nil
default['openstack']['compute']['misc_paste'] = nil

# To disable the EC2 API endpoint, simply remove 'ec2,' from the list
# of enabled API services.
default['openstack']['compute']['enabled_apis'] = 'ec2,osapi_compute,metadata'

# VMware driver
default['openstack']['compute']['vmware']['secret_name'] = 'openstack_vmware_secret_name'
# URL for connection to VMware ESX/VC host. (string value)
default['openstack']['compute']['vmware']['host_ip'] = ''
# Username for connection to VMware ESX/VC host. (string value)
default['openstack']['compute']['vmware']['host_username'] = ''
# Name of a VMware Cluster ComputeResource. Used only if compute_driver is vmwareapi.VMwareVCDriver. (multi valued)
default['openstack']['compute']['vmware']['cluster_name'] = []
# Regex to match the name of a datastore. (string value)
default['openstack']['compute']['vmware']['datastore_regex'] = nil
# The interval used for polling of remote tasks. (floating point value, default 0.5)
default['openstack']['compute']['vmware']['task_poll_interval'] = 0.5
# The number of times we retry on failures, e.g., socket error, etc. (integer value, default 10)
default['openstack']['compute']['vmware']['api_retry_count'] = 10
# VNC starting port (integer value, default 5900)
default['openstack']['compute']['vmware']['vnc_port'] = 5900
# Total number of VNC ports (integer value, default 10000)
default['openstack']['compute']['vmware']['vnc_port_total'] = 10000
# Whether to use linked clone (boolean value, default true)
default['openstack']['compute']['vmware']['use_linked_clone'] = true
# Physical ethernet adapter name for vlan networking (string value, default vmnic0)
default['openstack']['compute']['vmware']['vlan_interface'] = 'vmnic0'
# Optional VIM Service WSDL Location, you must specify this location of the WSDL files when you try to connect vSphere vCenter versions 5.0 and earlier.
default['openstack']['compute']['vmware']['wsdl_location'] = nil
# The maximum number of ObjectContent data objects that should be returned in a single result. (integer value, default 100)
default['openstack']['compute']['vmware']['maximum_objects'] = 100
# Name of Integration Bridge (string value, default br-int)
default['openstack']['compute']['vmware']['integration_bridge'] = 'br-int'
