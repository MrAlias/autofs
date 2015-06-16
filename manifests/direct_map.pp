# == Defined Type: autofs::direct_map
#
# Defines a direct map resource for autofs mounts.
#
# === Parameters
#
# [*location*]
#   String defining the location from where the file system is to be mounted.
#
# [*ensure*]
#   State to ensure of map.  Valid values are `present` and `absent`.
#
#   Defaults to `present`.
#
# [*key*]
#   Absolute path where the direct map will mount the location.
#
#   Defaults to `$name`.
#
# [*options*]
#   Array of mount options used in the map definition.
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
  $location,
  $ensure     = 'present',
  $key        = $name,
  $options    = [],
  $map_file   = undef,
) {
  include autofs

  validate_string($location)
  validate_absolute_path($key)
  validate_re($ensure, ['^present$', '^absent$'])

  if $map_file {
    $map_path = $map_file
  } else {
    $map_path = "${autofs::map_files_dir}/auto.direct"
  }

  if $options != [] {
    $content = sprintf("${key} -%s ${location}", join($options, ','))
  } else {
    $content = "${key} ${location}"
  }

  autofs::map_file { "autofs::direct_map ${map_path}":
    ensure  => $ensure,
    path    => $map_path,
    content => $content,
  }

  concat::fragment { "autofs::direct_map ${map_path}:${content}":
    ensure  => $ensure,
    target  => $autofs::auto_master,
    content => "/- ${map_path}",
    require => Autofs::Map_file["autofs::direct_map ${map_path}"],
    notify  => Service['autofs'],
  }
}
