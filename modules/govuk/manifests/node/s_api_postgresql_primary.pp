# == Class: govuk::node::s_api_postgresql_primary
#
# PostgreSQL primary node for API cluster.
#
# === Parameters:
#
# [*standby_password*]
#   Proxied to `govuk_postgresql::server::primary` so that we can set
#   per-cluster passwords in a single hiera credentials file.
#
class govuk::node::s_api_postgresql_primary (
  $standby_password,
) inherits govuk::node::s_api_postgresql_base {
  class { 'govuk_postgresql::server::primary':
    slave_password => $standby_password,
  }
}
