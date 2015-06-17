autofs::master_map { 'demos':
  mount_point => '/demo',
}

autofs::master_map { 'direct mounts':
  mount_point => '/-',
  map_name    => '/etc/auto.direct',
  options     => ['rw', 'hard', 'intr'],
}

autofs::master_map { 'include misc mounts':
  mount_point => '+',
  map_name    => '/etc/auto.misc',
}

autofs::master_map { 'make sure there are no /usr mounts':
  ensure      => absent,
  mount_point => '/usr',
  map_name    => 'auto.user',
}

autofs::master_map { 'LDAP mounts last':
  order       => '100',
  mount_point => '/home',
  map_name    => 'ou=home,ou=autofs,dc=ted',
  map_type    => 'ldap',
  format      => 'sun',
}
