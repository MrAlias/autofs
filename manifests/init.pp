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
#   This directory is not managed by this module, but is assumed to exist and
#   be accessable as autofs map file will be put there.
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
  $map_files_dir  = hiera("${module_name}::map_files_dir", '/etc'),
  $service_name   = hiera("${module_name}::service_name", 'autofs'),
) {
  validate_string($package_name, $service_name)
  validate_absolute_path($auto_master)

  package { $package_name:
    ensure => installed,
    alias  => 'autofs',
  }

  if $extra_packages != [] {
    ensure_packages($extra_packages)
  }

  concat { $auto_master:
    ensure         => present,
    owner          => 'root',
    group          => 'root',
    mode           => '0644',
    warn           => true,
    ensure_newline => true,
    force          => true,
    order          => 'numeric',
    require        => Package['autofs'],
    notify         => Service['autofs'],
  }

  service { $service_name:
    ensure => running,
    enable => true,
    alias  => 'autofs',
  }
}
