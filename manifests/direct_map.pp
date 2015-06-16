# == Defined Type: autofs::direct_map
#
# Defines a direct map resource for autofs mounts.
#
# === Parameters
#
# [*device*]
#   String defining the location from where the file system is to be mounted.
#
# [*ensure*]
#   State to ensure of map.  Valid values are `present` and `absent`.
#
#   Defaults to `present`.
#
# [*mountpoint*]
#   Absolute path where the direct map will mount the device.
#
#   Defaults to `$name`.
#
# [*options*]
#   String of mount options used in the map definition.
#
# [*map_file*]
#   Absolute path to file containing the direct map definition.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
# === Copyright
#
# Copyright 2015 Tyler Yahn
#
define autofs::direct_map (
  $device,
  $ensure     = 'present',
  $mountpoint = $name,
  $options    = undef,
  $map_file   = undef,
) {
  include autofs

  validate_string($device)
  validate_absolute_path($mountpoint)
  validate_re($ensure, ['^present$', '^absent$'])

  if $map_file {
    validate_absolute_path($map_file)
    $map_path = $map_file
    $_require = undef
  } else {
    $map_path = "${autofs::map_files_dir}/auto.direct"
    $_require = File[$autofs::map_files_dir]
  }

  if $options {
    validate_string($options)
    $content = "${mountpoint} ${options} ${device}"
  } else {
    $content = "${mountpoint} ${device}"
  }

  autofs::map_file { "autofs::direct_map $map_path":
    ensure  => $ensure,
    path    => $map_path,
    content => $content,
    require => $_require,
  }

  concat::fragment { "autofs::direct_map ${map_path}:${content}":
    ensure  => $ensure,
    target  => $autofs::auto_master,
    content => "/- ${map_path}",
    require => Autofs::Map_file["autofs::direct_map $map_path"],
    notify  => Service['autofs'],
  }
}
