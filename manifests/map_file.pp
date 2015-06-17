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
# [*owner*]
#   Specifies the user who owns the destination file.
#
#   Valid options: a string containing a user name.
#
#   Default value: `'root'`.
#
# [*group*]
#   Specifies the group owner of the destination file.
#
#   Valid options: a string containing a group name.
#
#   Default value: `'root'`.
#
# [*mode*]
#   Specifies the permissions mode of the map file.
#
#   Valid options: a string containing an octal notation mode.
#
#   Default value: `'0644'`.
#
# [*order*]
#   Relative order the content will appear in the map file.
#
#   The ordering is numeric and any maps that share the same order number
#   are ordered by name.
#
#   Valid values are a string or an integer.
#
#   Defaults to '10'.
#
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
  $path    = $name,
  $ensure  = 'present',
  $owner   = 'root',
  $group   = 'root',
  $mode    = '0644',
  $order   = '10',
  $content = undef,
) {
  include autofs

  validate_absolute_path($path)
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($content)

  if ! defined(Concat[$path]) {
    concat { $path:
      ensure         => $ensure,
      owner          => $owner,
      group          => $group,
      mode           => $mode,
      warn           => true,
      ensure_newline => true,
      force          => true,
      order          => 'numeric',
    }
  }

  if $content {
    concat::fragment { "Adding '${content}' to ${path}":
      ensure  => $ensure,
      target  => $path,
      content => $content,
      order   => $order,
      notify  => Service['autofs'],
    }
  }
}
