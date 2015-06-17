# == Defined Type: autofs::master_map
#
# Defines an autofs map in the master map file.
#
# === Parameters
#
# [*mount_point*]
#   Requrired parameter defining the base location for the autofs filesystem
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
#   Any maps that share the same order number are ordered by name.
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
# [*mount_options*]
#   Array of mount options.
#
# [*variable_substitutions*]
#   Hash of variables with substitutions values to replace in map.
#
# [*strict*]
#   Specifies whether to treat errors when mounting file systems as fatal.
#
# [*random_multimount_selection*]
#   Specifies whether to use a ramdom selection when choosing a host from a
#   list of replicated servers.
#
# [*use_weight_only*]
#   Specifies whether to use only specified weights for server selection
#   where more than one server is specified in the map entry.
#
# [*timeout*]
#   Time in seconds to wait for map entries before expiring.
#
# [*negative_timeout*]
#   Time in seconds to cache failed key lookups
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
  $mount_point,
  $map_name                    = $name,
  $ensure                      = 'present',
  $order                       = '10',
  $map_type                    = undef,
  $format                      = undef,
  $mount_options               = [],
  $variable_substitutions      = {},
  $strict                      = undef,
  $random_multimount_selection = undef,
  $use_weight_only             = undef,
  $timeout                     = undef,
  $negative_timeout            = undef,
) {
  include autofs

  validate_string($map_name)
  validate_re($ensure, ['^present$', '^absent$'])

  if ($mount_point != '/-') and ($mount_point != '+') {
    validate_absolute_path($mount_point)
    $_mnt_pt = "$mount_point "
  } elsif $mount_point == '/-' {
    $_mnt_pt = "$mount_point "
  } else {
    $_mnt_pt = $mount_point
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

  if $mount_options != [] {
    $_mount_opts = sprintf(' %s', join($mount_options, ','))
  } else {
    $_mount_opts = ''
  }

  if $variable_substitutions != {} {
    $_subs = sprintf(' -D%s', join(join_keys_to_values($variable_substitutions, '='), ' -D'))
  } else {
    $_subs = ''
  }

  $_strict = $strict ? {
    true    => ' -strict',
    false   => '',
    undef   => '',
    default => fail("Invalid strict value: ${strict}"),
  }

  $_rnd = $random_multimount_selection ? {
    true    => ' -r',
    false   => '',
    undef   => '',
    default => fail("Invalid random_multimount_selection value: ${random_multimount_selection}"),
  }

  $_weights = $use_weight_only ? {
    true    => ' -w',
    false   => '',
    undef   => '',
    default => fail("Invalid use_weight_only value: ${use_weight_only}"),
  }

  if $timeout {
    validate_integer($timeout)
    $_timeout = " -t $timeout"
  } else {
    $_timeout = ''
  }

  if $negative_timeout{
    validate_integer($negative_timeout)
    $_neg_timeout = " -n $negative_timeout"
  } else {
    $_neg_timeout = ''
  }

  $content = "${_mnt_pt}${_map_type}${map_name}${_mount_opts}${_subs}${_strict}${_rnd}${_weights}${_timeout}${_neg_timeout}"

  concat::fragment { "autofs::master_map ${mount_point}:${map_name}":
    ensure  => $ensure,
    target  => $autofs::auto_master,
    content => $content,
    order   => $order,
    notify  => Service['autofs'],
  }
}
