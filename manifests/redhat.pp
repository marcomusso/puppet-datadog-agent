# Class: datadog_agent::redhat
#
# This class contains the DataDog agent installation mechanism for Red Hat derivatives
#
# Parameters:
#   $baseurl:
#       Baseurl for the datadog yum repo
#       Defaults to http://yum.datadoghq.com/rpm/${::architecture}/
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#
class datadog_agent::redhat(
  $baseurl = "https://yum.datadoghq.com/rpm/${::architecture}/",
  $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public',
  $manage_repo = true,
  $agent_version = 'latest'
) inherits datadog_agent::params {

  validate_bool($manage_repo)
  if $manage_repo {

    validate_string($baseurl)

    yumrepo {'datadog':
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public',
      descr    => 'Datadog, Inc.',
      baseurl  => $baseurl,
    }

    Package { require => Yumrepo['datadog']}
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$datadog_agent::params::package_name],
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
  }

  service { $datadog_agent::params::service_name:
    ensure    => $::datadog_agent::service_ensure,
    enable    => $::datadog_agent::service_enable,
    hasstatus => false,
    pattern   => 'dd-agent',
    provider  => 'redhat',
    require   => Package[$datadog_agent::params::package_name],
  }

}
