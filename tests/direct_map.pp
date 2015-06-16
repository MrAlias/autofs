autofs::direct_map { '/this/test/point':
  location   => '/dev/some_device',
  ensure     => 'absent',
  key        => '/another/mountpoint',
  options    => ['rw'],
  map_file   => '/etc/auto.test',
}

autofs::direct_map { '/that/test/point':
  location   => '/dev/some_other_device',
  ensure     => 'present',
  key        => '/a/mountpoint',
  options    => ['ro'],
  map_file   => '/etc/auto.test2',
}
