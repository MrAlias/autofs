autofs::indirect_map { 'test1':
  location => '/home',
  options  => '-rw',
}

autofs::indirect_map { 'test2':
  location => '/mnt',
  map_file => '/etc/auto.mnt',
}

autofs::indirect_map { 'test3':
  location => '/usr',
  ensure   => absent,
}
