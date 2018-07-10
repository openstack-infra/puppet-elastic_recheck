# Copyright 2013 Hewlett-Packard Development Company, L.P.
# Copyright 2013 Samsung Electronics
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Class to install and configure an instance of the elastic-recheck
# service.
#
class elastic_recheck::bot (
  $gerrit_host,
  $recheck_bot_nick,
  $recheck_bot_passwd,
  $daemon_args             = undef,
  $elastic_search_url      = 'http://logstash.openstack.org:80/elasticsearch',
  $gerrit_ssh_host_key     = undef,
  $logstash_url            = 'http://logstash.openstack.org',
  $recheck_gerrit_user     = 'elasticrecheck',
  $recheck_ssh_private_key = undef,
  $recheck_ssh_public_key  = undef,
  $subunit2sql_db_uri      = 'mysql+pymysql://query:query@logstash.openstack.org/subunit2sql',
) {
  include ::elastic_recheck

  file { '/etc/elastic-recheck/elastic-recheck.conf':
    ensure  => present,
    mode    => '0640',
    owner   => 'recheck',
    group   => 'recheck',
    content => template('elastic_recheck/elastic-recheck.conf.erb'),
    require => Class['elastic_recheck'],
  }

  file { '/home/recheck':
    ensure  => directory,
    mode    => '0700',
    owner   => 'recheck',
    group   => 'recheck',
    require => Class['elastic_recheck'],
  }

  file { '/home/recheck/.ssh':
    ensure  => directory,
    mode    => '0700',
    owner   => 'recheck',
    group   => 'recheck',
    require => Class['elastic_recheck'],
  }

  if $recheck_ssh_private_key != undef {
    file { '/home/recheck/.ssh/id_rsa':
      owner   => 'recheck',
      group   => 'recheck',
      mode    => '0600',
      content => $recheck_ssh_private_key,
      replace => true,
      require => File['/home/recheck/.ssh/']
    }
  }

  if $recheck_ssh_public_key != undef {
    file { '/home/recheck/.ssh/id_rsa.pub':
      owner   => 'recheck',
      group   => 'recheck',
      mode    => '0600',
      content => $recheck_ssh_public_key,
      replace => true,
      require => File['/home/recheck/.ssh/']
    }
  }

  if $gerrit_ssh_host_key != undef {
    file { '/home/recheck/.ssh/known_hosts':
      owner   => 'recheck',
      group   => 'recheck',
      mode    => '0600',
      content => "${gerrit_host} ${gerrit_ssh_host_key}",
      replace => true,
      require => File['/home/recheck/.ssh/']
    }
  }

  file { '/etc/init.d/elastic-recheck':
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('elastic_recheck/elastic-recheck.init.erb'),
  }

  if versioncmp($::operatingsystemmajrelease, '16.04') >= 0 {
    exec { 'elastic-recheck-systemd-daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      before      => Service['elastic-recheck'],
      subscribe   => File['/etc/init.d/elastic-recheck'],
      refreshonly => true,
    }
  }

  service { 'elastic-recheck':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/elastic-recheck/elastic-recheck.conf'],
      Exec['install_elastic-recheck'],
    ],
    require   => [
      Class['elastic_recheck'],
      File['/etc/init.d/elastic-recheck'],
      File['/etc/elastic-recheck/elastic-recheck.conf'],
    ],
  }
}
