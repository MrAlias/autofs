class { 'autofs':
  package_name   => 'autofs',
  extra_packages => ['autofs-ldap', 'autofs-hesiod'],
  auto_master    => '/auto.master',
  map_files_dir  => '/auto.master.d',
  service_name   => 'autofs',
}
