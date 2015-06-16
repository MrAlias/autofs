# == Defined Type: autofs::map_file
#
# Creates and manages content for an autofs map file.
#
# === Parameters
#
# [*ensure*]
#   State of the map file.  Valid values are `present` and `absent`.
#
#   Defaults to `present`.
#
# [*path*]
#   Absolute path to the location of the map file to manage.
#
#   Defaults to `$name`.
#
# [*content*]
#   Content to add to the map file.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
# === Copyright
#
# Copyright 2015 Tyler Yahn
#
define autofs::map_file (
  $ensure  = 'present',
  $path    = $name,
  $content = undef,
) {
  include autofs

  validate_absolute_path($path)
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($content)

  if ! defined(Concat[$path]) {
    concat { $path:
      ensure => $ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      warn   => true,
    }
  }

  if $content {
    concat::fragment { "Adding '${content}' to ${path}":
      ensure  => $ensure,
      target  => $path,
      content => $content,
      notify  => Service['autofs'],
    }
  }
}
