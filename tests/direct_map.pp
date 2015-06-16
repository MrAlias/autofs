autofs::direct_map { '/this/test/point':
  device     => '/dev/some_device',
  ensure     => 'absent',
  mountpoint => '/another/mountpoint',
  options    => '-rw',
  map_file   => '/etc/auto.test',
}

autofs::direct_map { '/that/test/point':
  device     => '/dev/some_other_device',
  ensure     => 'present',
  mountpoint => '/a/mountpoint',
  options    => '-ro',
  map_file   => '/etc/auto.test2',
}
