# == Class: govuk::gor
#
# Setup gor traffic replay for GOV.UK
#
class govuk::gor(
  $enable_staging = false,
  $version = '0.7.0-9026155~ppa1~precise',
) {
  include govuk::ppa

  # Hardcoded, rather than hiera, because I don't want to create the
  # illusion that you can modify these on the fly. You will need to tidy
  # up old `host{}` records.
  $staging_ip     = '37.26.91.14'
  $staging_host   = 'www-origin-staging.production.alphagov.co.uk'

  $gor_target0 = $enable_staging ? {
    true    => ["https://${staging_host}"],
    default => [],
  }

  $gor_targets = flatten([$gor_target0])

  if $gor_targets == [] {
    $gor_hosts_ensure   = absent
    $gor_service_ensure = stopped
    $nagios_ensure      = absent
    $logstream_ensure   = absent
  } else {
    $gor_hosts_ensure   = present
    $gor_service_ensure = running
    $nagios_ensure      = present
    $logstream_ensure   = present
  }

  # FIXME: These "fake" host entries serve two purposes:
  #   1. Ensures that the SSL cert on staging, which thinks it is
  #   production, matches the hostname that we connect to.
  #   2. Prevents Gor/Go from performing DNS lookups, which occur once
  #   for *every* request/goroutine, and can be quite overwhelming.
  host {
    $staging_host:
      ensure  => $gor_hosts_ensure,
      ip      => $staging_ip,
      comment => 'Used by Gor. See comments in s_cache.';
  } ~>
  class { '::gor':
    package_ensure => $version,
    service_ensure => $gor_service_ensure,
    args           => {
      '-input-raw'          => 'localhost:7999',
      '-output-http'        => $gor_targets,
      '-output-http-method' => [
        'GET', 'HEAD', 'OPTIONS'
      ],
    },
  } ->
  govuk::logstream { 'gor_upstart_log':
    ensure  => $logstream_ensure,
    logfile => '/var/log/upstart/gor.log',
    tags    => ['stdout', 'stderr', 'upstart', 'gor'],
    fields  => {'application' => 'gor'},
  }

  @@icinga::check { "check_gor_running_${::hostname}":
    ensure              => $nagios_ensure,
    check_command       => 'check_nrpe!check_proc_running!gor',
    service_description => 'gor running',
    host_name           => $::fqdn,
  }
}
