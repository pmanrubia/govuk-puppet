# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class postfix::package {
  package { 'postfix':
    ensure => installed,
  }
}
