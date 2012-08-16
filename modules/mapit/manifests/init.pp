class mapit {
  # # not needed now I have snapshotted the DB
  #   mapit::get_data{'get_recent_data':
  #     mapit_datadir => '/data/vhosts/mapit',
  #   }
  mapit::setup{'setup dirs and users':
    mapit_datadir => '/data/vhosts/mapit/',
  }
  package{['python-django-south','python-yaml','memcached','python-memcache',
          'python-django','python-psycopg2',
          'python-flup','python-gdal']:
    ensure => present,
  }

  class { 'nginx' : node_type => mapit }

  file { '/etc/init/mapit.conf':
    ensure  => file,
    source  => 'puppet:///modules/mapit/fastcgi_mapit.conf',
    require => [
        User['mapit'],
        Exec['unzip_mapit'],
      ]
  }
  file { '/data/vhosts/mapit/data/mapit.tar.gz':
    ensure  => file,
    source  => 'puppet:///modules/mapit/mapit.tar.gz',
    before  => Exec['unzip_mapit'],
  }
  exec {'unzip_mapit':
    command => 'tar -zxf /data/vhosts/mapit/data/mapit.tar.gz -C /data/vhosts/mapit',
    creates => '/data/vhosts/mapit/mapit/README',
    user    => 'mapit',
    require => [
        User['mapit'],
        File['/data/vhosts/mapit/'],
      ],
  }
  service { 'mapit':
    ensure    => running,
    provider  => upstart,
    subscribe => File['/etc/init/mapit.conf'],
    require   => [
      File['/etc/init/mapit.conf'],
      Exec['unzip_mapit'],
    ],
  }
}
