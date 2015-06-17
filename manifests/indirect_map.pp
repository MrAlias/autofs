# == Defined Type: autofs::indirect_map
#
# Defines a indirect map resource for autofs mounts.
#
# === Parameters
#
# [*location*]
#   Address of the filesystem to mount.
#
# [*mount_point*]
#   Absolute local path to the head of where the indirect map(s) are located.
#
# [*ensure*]
#   State the map should be.  Valid values are `present` and `absent`.
#
#   Defaults to `present`.
#
# [*key*]
#   Simple name for the map.
#
#   The indirect map will mount the `location` at `/mount_point/key`.
#
#   Defaults to `$name`.
#
# [*options*]
#   Array of mount options used in the map definition.
#
# [*map_file*]
#   Absolute path to file containing the map definition. If none is provided
#   the map will be defined in a create file named after the basename of the
#   mountpoint prefixed by **auto.** withing the `autofs::map_files_dir`.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
# === Copyright
#
# Copyright 2015 Tyler Yahn
#
define autofs::indirect_map (
  $location,
  $mount_point,
  $ensure      = 'present',
  $key         = $name,
  $options     = [],
  $map_file    = undef,
) {
  include autofs

  validate_string($location, $key)
  validate_absolute_path($mount_point)
  validate_re($ensure, ['^present$', '^absent$'])

  if $map_file {
    $map_path = $map_file
  } else {
    $basename = basename($mount_point)
    $map_path = "${autofs::map_files_dir}/auto.${basename}"
  }

  if $options != [] {
    $content = sprintf("${key} -%s ${location}", join($options, ','))
  } else {
    $content = "${key} ${location}"
  }

  autofs::map_file { "autofs::indirect_map ${map_path}:${content}":
    ensure  => $ensure,
    path    => $map_path,
    content => $content,
  }

  if ! defined(Autofs::Master_map["autofs::indirect_map ${map_path}"]) {
    autofs::master_map { "autofs::indirect_map ${map_path}":
      ensure      => $ensure,
      mount_point => $mount_point,
      map_name    => $map_path,
      require     => Autofs::Map_file["autofs::indirect_map ${map_path}:${content}"],
      notify      => Service['autofs'],
    }
  }
}
