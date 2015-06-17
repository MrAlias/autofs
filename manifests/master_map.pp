# == Defined Type: autofs::master_map
#
# Defines an autofs map in the master map file.
#
# === Parameters
#
# [*mount_point*]
#   Required parameter defining the base location for the autofs filesystem
#   to be mounted.
#
# [*map_name*]
#   Name of the map to use.
#
#   This is an absolute UNIX pathname for maps of types `file` or `program`,
#   and the name of a database in the case for maps of type `yp`, `nisplus`,
#   or `hesiod`, or the dn of an LDAP entry for maps of type `ldap` or
#   `ldaps`.
#
#   Defaults to `$name`.
#
# [*ensure*]
#   State the specified map is in.  Valid values are `present` and `absent`.
#
#   Defaults to `present`.
#
# [*order*]
#   Relative order the map will appean in the master map file.
#
#   The ordering is numeric and any maps that share the same order number
#   are ordered by name.
#
#   Valid values are a string or an integer.
#
#   Defaults to '10'.
#
# [*map_type*]
#   The autofs map type.
#
#   Valid values are: `file`, `program`, `yp`, `nisplus`, `hesiod`, `ldap`,
#   or `ldaps'.
#
#   Defaults to `file`.
#
# [*format*]
#   The format of the map data.
#
#   Valid values are: `sun`, or `hesiod`.
#
#   Defaults to `sun`.
#
# [*options*]
#   Array of mount and map options.
#
#   Options without leading dashes (-) are taken as options (-o) to mount.
#   Options with leading dashes are considered options for the maps.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
# === Copyright
#
# Copyright 2015 Tyler Yahn
#
define autofs::master_map (
  $ensure      = 'present',
  $map_name    = $name,
  $mount_point = undef,
  $order       = '10',
  $map_type    = undef,
  $format      = undef,
  $options     = [],
) {
  include autofs

  validate_string($map_name)
  validate_re($ensure, ['^present$', '^absent$'])

  if ($mount_point != '/-') and ($mount_point != '+') and ($mount_point != '') {
    validate_absolute_path($mount_point)
    $_mnt_pt = "$mount_point "
  } elsif $mount_point == '/-' {
    $_mnt_pt = "$mount_point "
  } elsif $mount_point == '+' {
    $_mnt_pt = $mount_point
  } else {
    fail('Must specify mount_point')
  }

  $_format = $format ? {
    undef    => '',
    'sun'    => ',sun',
    'hesiod' => ',hesiod',
    default  => fail("Invalid format: ${format}"),
  }

  $_map_type = $map_type ? {
    undef     => '',
    'file'    => "file${_format}:",
    'program' => "program${_format}:",
    'yp'      => "yp${_format}:",
    'nisplus' => "nisplus${_format}:",
    'hesiod'  => "hesiod${_format}:",
    'ldap'    => "ldap${_format}:",
    'ldaps'   => "ldaps${_format}:",
    default   => fail("Invalid map_type: ${map_type}"),
  }

  if $options != [] {
    $_opts = sprintf(' %s', join($options, ' '))
  } else {
    $_opts = ''
  }

  concat::fragment { "autofs::master_map ${mount_point}:${map_name}":
    ensure  => $ensure,
    target  => $autofs::auto_master,
    content => "${_mnt_pt}${_map_type}${map_name}${_opts}",
    order   => $order,
    notify  => Service['autofs'],
  }
}
