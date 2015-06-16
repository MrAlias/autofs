# == Class: autofs
#
# Manages the autofs package, templates, and service.
#
# === Parameters
#
# [*package_name*]
#   Name of the distribution specific autofs package.
#
# [*extra_packages*]
#   Array of packages to install.  By default only the autofs packages is
#   manages by this module.  If extra support is desired for autofs
#   (like LDAP or Hesiod), then the needed packages (i.e. autofs-hesiod,
#   autofs-ldap, ... ) can be specified here.
#
# [*auto_master*]
#   Absolute file path where the master autofs template is located.
#
# [*map_files_dir*]
#   Absolute file path where the autofs map files are located.
#
#   Defaults to `/etc/auto.master.d`
#
# [*service_name*]
#   Name of the distribution specific autofs service.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
# === Copyright
#
# Copyright 2015 Tyler Yahn
#
class autofs (
  $package_name   = hiera("${module_name}::pacakge_name", 'autofs'),
  $extra_packages = hiera_array("${module_name}::extra_packages", []),
  $auto_master    = hiera("${module_name}::auto_master", '/etc/auto.master'),
  $map_files_dir  = hiera("${module_name}::map_files_dir", '/etc/auto.master.d'),
  $service_name   = hiera("${module_name}::service_name", 'autofs'),
) {
  validate_string($package_name, $service_name)
  validate_absolute_path($auto_master)

  package { $package_name :
    ensure => installed,
    alias  => 'autofs',
  }

  if $extra_packages != [] {
    ensure_packages($pacakges)
  }

  file { $map_files_dir :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  concat { $auto_master :
    ensure  => present,
    warn    => true,
    require => Package['autofs'],
    notify  => Service['autofs'],
  }

  service { $service_name :
    ensure => running,
    enable => true,
    alias  => 'autofs',
  }

  File<| tag == 'map_file' |> ~> Service['autofs']
}
