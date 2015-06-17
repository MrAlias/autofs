autofs::direct_map { '/this/test/point':
  location    => '/dev/some_device',
  ensure      => 'absent',
  mount_point => '/another/mountpoint',
  options     => ['rw'],
  map_file    => '/etc/auto.test',
}

autofs::direct_map { '/that/test/point':
  location    => '/dev/some_other_device',
  ensure      => 'present',
  mount_point => '/a/mountpoint',
  options     => ['ro', 'nobrowse'],
  map_file    => '/etc/auto.test2',
}
