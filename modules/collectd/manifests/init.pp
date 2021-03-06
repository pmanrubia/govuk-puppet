# == Class: collectd
#
# Installs and sets up collectd on a machine.
#
class collectd {
  anchor { 'collectd::begin':
    notify => Class['collectd::service'];
  }

  class { 'collectd::package':
    notify  => Class['collectd::service'],
    require => Anchor['collectd::begin'],
  }

  class { 'collectd::config':
    notify  => Class['collectd::service'],
    require => Class['collectd::package'],
  }

  class { 'collectd::plugins':
    require => Class['collectd::config'],
  }

  class { 'collectd::service': }

  anchor { 'collectd::end':
    subscribe => Class['collectd::service'],
  }
}
