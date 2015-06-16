autofs::map_file { 'test map file':
  ensure  => present,
  path    => '/etc/auto.test',
  content => 'this is test content',
}
