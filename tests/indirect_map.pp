# Should result in /etc/auto.test containing something like:
#
#   kernel    -ro,soft,intr       ftp.kernel.org:/pub/linux
#   boot      -fstype=ext2        :/dev/hda1
#   windoze   -fstype=smbfs       ://windoze/c
#   removable -fstype=ext2        :/dev/hdd
#   cd        -fstype=iso9660,ro  :/dev/hdc
#   floppy    -fstype=auto        :/dev/fd0
#   server    -rw,hard,intr       / -ro myserver.me.org:/ /usr myserver.me.org:/usr /home myserver.me.org:/home
#
# and /etc/auto.master containing:
#
#   /test /etc/auto.test

Autofs::Indirect_map {
  mount_point => '/test',
}

autofs::indirect_map { 'kernel':
  location => 'ftp.kernel.org:/pub/linux',
  options  => ['ro', 'soft', 'intr'],
}

autofs::indirect_map { 'boot':
  location => ':/dev/hda1',
  options  => ['fstype=ext2'],
}

autofs::indirect_map { 'windoze':
  location => '://windoze/c',
  options  => ['fstype=smbfs'],
}

autofs::indirect_map { 'removable':
  location => ':/dev/hdd',
  options  => ['fstype=ext2'],
}

autofs::indirect_map { 'cd':
  location => ':/dev/hdc',
  options  => ['fstype=iso9660', 'ro'],
}

autofs::indirect_map { 'floppy':
  location => ':/dev/fd0',
  options  => ['fstype=auto'],
}

autofs::indirect_map { 'server':
  location => '/ -ro myserver.me.org:/ /usr myserver.me.org:/usr /home myserver.me.org:/home',
  options  => ['rw', 'hard', 'intr'],
}

autofs::indirect_map { 'removed_key':
  ensure   => absent,
  location => 'should_not_exist',
}
