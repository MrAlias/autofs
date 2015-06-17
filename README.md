# autofs

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the autofs does and why it is useful](#module-description)
3. [Setup - The basics of getting started with autofs](#setup)
    * [What autofs affects](#what-autofs-affects)
    * [Beginning with autofs](#beginning-with-autofs)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)

## Overview

Manages the state and configuration of the autofs linux utility.

## Module Description

AutoFS is a linux package that manages the automount daemons.  It provides a unified way to manage removable media or network share when they are inserted or accessed.  This module, autofs, make sure the AutoFS package is installed, the service is running, and most importantly, it is configured correctly with appropriate maps.

## Setup

### What autofs affects

* The autofs package.
* The autofs service.
* Autofs master and secondary map files, and consequentially any mounted filesystems.

### Beginning with autofs

In order to get a basic instance of AutoFS running:

```puppet
include autofs
```

## Usage

### Extra support on Debian

You can specify additional packages for the main `autofs` class to install, thereby adding extra functionality to the autofs utility.  An example of this would be adding LDAP and hesiod support on Debian:

```puppet
class { 'autofs':
  extra_packages => ['autofs-ldap', 'autofs-hesiod'],
}
```

### Adding direct maps

AutoFS allows a direct map between a local mount point (`mount_point`), and a filesystem (`location`).

```puppet
autofs::direct_map { 'Backups Drive':
  location    => 'backups:/global_backups',
  options     => ['rw'],
  mount_point => '/backups',
}
```

This will add a map definition to the `/etc/auto.direct` map file by default.  If you want to specify a different map file:

```puppet
autofs::direct_map { '/private':
  location => 'castle:/secrets',
  options  => ['ro'],
  map_file => '/etc/auto.private',
}
```

### Adding indirect maps

Indirect maps use a key to associate a mount point with a directory.  In contrast to the `autofs::direct_map` resource, both a `key` (which defaults to `$name`) and `mount_point` need to be specified.

```puppet
autofs::indirect_map { 'kernel':
  mount_point => '/mnt',
  location    => 'ftp.kernel.org:/pub/linux',
  options     => ['ro', 'soft', 'intr'],
}

autofs::indirect_map { 'boot':
  mount_point => '/mnt',
  location    => ':/dev/hda1',
  options     => ['fstype=ext2'],
}
```

This will create two indirect maps in a default map file `/etc/auto.mnt` and setup the needed map definitions in the master map file.  If a different map file is wanted for either or both, similarly to the `autofs::direct_map` you can specify `map_file`.

### Custom master maps

In order to directly create a master map you can use the `autofs::master_map` defined type:

```puppet
autofs::master_map { 'include misc mounts':
  order       => '99',
  mount_point => '+',
  map_name    => '/etc/auto.misc',
}

autofs::master_map { 'LDAP mounts last':
  order       => '100',
  mount_point => '/home',
  map_name    => 'ou=home,ou=autofs,dc=ted',
  map_type    => 'ldap',
  format      => 'sun',
}
```

This will add the following entries into the master autofs map file:

```
...
+/etc/auto.misc
/home ldap,sun:ou=home,ou=autofs,dc=ted
...
```

### Going beyond

If for some reason you find this modules defined types to restrictive and need to add specific entries in map files that are not supported you can directly use the `autofs::map_file` defined type.

```puppet
autofs::master_map { 'include misc mounts':
  order       => '99',
  mount_point => '+',
  map_name    => '/etc/auto.misc',
}

autofs::map_file { 'Custom misc maps':
  ensure  => present,
  path    => '/etc/auto.misc',
  content => ' ... '
}
```

This example adds the custom content to the `/etc/auto.misc` map file and, similar to before, adds the appropriate master map entry.

This defined type is intended to account for unforseen use.  Likely you do not need to use this.

## Reference

### Classes

#### autofs

Manages the autofs package, templates, and service.

##### `autofs::direct_map::package_name`

Name of the distribution specific autofs package.

##### `autofs::direct_map::extra_packages`

Array of packages to install.

By default only the autofs packages is manages by this module.  If extra support is desired for autofs (like LDAP or Hesiod), then the needed packages (i.e. autofs-hesiod, autofs-ldap, ... ) can be specified here.

##### `autofs::direct_map::auto_master`

Absolute file path where the master autofs template is located.

##### `autofs::direct_map::map_files_dir`

Absolute file path where the autofs map files are located.

This directory is not managed by this module, but is assumed to exist and be accessable as autofs map file will be put there.

##### `autofs::direct_map::service_name`

Name of the distribution specific autofs service.

### Defined Types

#### autofs::direct_map

Defines an AutoFS direct map.

##### `autofs::direct_map::location`

String defining the location from where the file system is to be mounted.

##### `autofs::direct_map::ensure`

State to ensure of map.  Valid values are `present` and `absent`.

Defaults to `present`.

##### `autofs::direct_map::mount_point`

Absolute path where the direct map will mount the location.

Defaults to `$name`.

##### `autofs::direct_map::options`

Array of mount options used in the map definition.

##### `autofs::direct_map::map_file`

Absolute path to file containing the direct map definition.

#### autofs::indirect_map

Defines an AutoFS indirect map.

##### `autofs::direct_map::location`

Address of the filesystem to mount.

##### `autofs::direct_map::mount_point`

Absolute local path to the head of where the indirect map(s) are located.

##### `autofs::direct_map::ensure`

State the map should be.  Valid values are `present` and `absent`.

Defaults to `present`.

##### `autofs::direct_map::key`

Simple name for the map.

The indirect map will mount the `location` at `/mount_point/key`.

Defaults to `$name`.

##### `autofs::direct_map::options`

Array of mount options used in the map definition.

##### `autofs::direct_map::map_file`

Absolute path to file containing the map definition. If none is provided the map will be defined in a create file named after the basename of the mountpoint prefixed by **auto.** withing the `autofs::map_files_dir`.

#### autofs::master_map

Defines an autofs map in the master map file.

##### `autofs::direct_map::mount_point`

Required parameter defining the base location for the autofs filesystem to be mounted.

##### `autofs::direct_map::map_name`

Name of the map to use.

This is an absolute UNIX pathname for maps of types `file` or `program`, and the name of a database in the case for maps of type `yp`, `nisplus`, or `hesiod`, or the dn of an LDAP entry for maps of type `ldap` or `ldaps`.

Defaults to `$name`.

##### `autofs::direct_map::ensure`

State the specified map is in.  Valid values are `present` and `absent`.

Defaults to `present`.

##### `autofs::direct_map::order`

Relative order the map will appean in the master map file.

The ordering is numeric and any maps that share the same order number are ordered by name.

Valid values are a string or an integer.

Defaults to '10'.

##### `autofs::direct_map::map_type`

The autofs map type.

Valid values are: `file`, `program`, `yp`, `nisplus`, `hesiod`, `ldap`, or `ldaps'.

Defaults to `file`.

##### `autofs::direct_map::format`

The format of the map data.

Valid values are: `sun`, or `hesiod`.

Defaults to `sun`.

##### `autofs::direct_map::options`

Array of mount and map options.

Options without leading dashes (-) are taken as options (-o) to mount.  Options with leading dashes are considered options for the maps.

#### autofs::map_file

Creates and manages content for an autofs map file.

##### `autofs::direct_map::ensure`

State of the map file.  Valid values are `present` and `absent`.

Defaults to `present`.

##### `autofs::direct_map::path`

Absolute path to the location of the map file to manage.

Defaults to `$name`.

##### `autofs::direct_map::owner`

Specifies the user who owns the destination file.

Valid options: a string containing a user name.

Default value: `'root'`.

##### `autofs::direct_map::group`

Specifies the group owner of the destination file.

Valid options: a string containing a group name.

Default value: `'root'`.

##### `autofs::direct_map::mode`

Specifies the permissions mode of the map file.

Valid options: a string containing an octal notation mode.

Default value: `'0644'`.

##### `autofs::direct_map::order`

Relative order the content will appear in the map file.

The ordering is numeric and any maps that share the same order number
  are ordered by name.

Valid values are a string or an integer.

Defaults to '10'.

##### `autofs::direct_map::content`

Content to add to the map file.

##### `autofs::map_file::content`

Content to add to the map file.

## Limitations

This module is still in development and currently only being tested on Debian based systems.

It is planned to support all operating systems AutoFS is found on.
