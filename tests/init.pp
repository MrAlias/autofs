class { 'autofs':
  package_name   => 'test_autofs',
  extra_packages => ['this_one', 'and_this_one'],
  auto_master    => '/auto.master',
  map_files_dir  => '/auto.master.d',
  service_name   => 'test_service_autofs',
}
