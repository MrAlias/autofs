# == Defined Type: autofs::indirect_map
#
# Defines a indirect map resource for autofs mounts.
#
# === Parameters
#
# [*location*]
#   Absolute path to location on the file system the map connects to.
#
# [*ensure*]
#   State the map should be.  Valid values are `present` and `absent`.
#
#   Defaults to `present`.
#
# [*key*]
#   Simple name for the map.
#
#   Defaults to `$name`.
#
# [*options*]
#   String of mount options used in the map definition.
#
# [*map_file*]
#   Absolute path to file containing the map definition. If none is provided
#   the map will be defined in the master autofs template.
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
  $ensure   = 'present',
  $key      = $name,
  $options  = undef,
  $map_file = undef,
) {
  include autofs

  validate_string($key)
  validate_absolute_path($location)
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($options)

  if $map_file {
    $master_content = "+${map_file}"
    autofs::map_file { "autofs::indirect_map ${map_file}:${key}":
      ensure  => $ensure,
      path    => $map_file,
      content => "${key} ${options} ${location}",
      before  => Concat::Fragment["autofs::indirect_map: ${master_content}"],
    }
  } else {
    $master_content = "${location} ${key} ${options}"
  }

  if ! defined(Concat::Fragment["autofs::indirect_map: ${master_content}"]) {
    concat::fragment { "autofs::indirect_map: ${master_content}":
      ensure  => $ensure,
      target  => $autofs::auto_master,
      content => $master_content,
      notify  => Service['autofs'],
    }
  }
}
