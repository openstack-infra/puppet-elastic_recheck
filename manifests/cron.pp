# Copyright 2013 Hewlett-Packard Development Company, L.P.
# Copyright 2014 Samsung Electronics
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

class elastic_recheck::cron (
  $graph_all_cmd_options  = undef,
  $graph_gate_cmd_options = undef,
  $uncat_cmd_options      = undef,
) {
  $er_state_path = '/var/lib/elastic-recheck'
  $graph_all_cmd = "elastic-recheck-graph /opt/elastic-recheck/queries -o all-new.json ${graph_all_cmd_options} && mv all-new.json all.json"
  $graph_gate_cmd = "elastic-recheck-graph /opt/elastic-recheck/queries -o gate-new.json -q gate ${graph_gate_cmd_options} && mv gate-new.json gate.json"
  $uncat_cmd = "elastic-recheck-uncategorized -d /opt/elastic-recheck/queries -t /usr/local/share/elastic-recheck/templates -o new ${uncat_cmd_options} && mv new/*.html ."

  cron { 'elastic-recheck-all':
    user        => 'recheck',
    minute      => ['0', '30'],
    hour        => '*',
    command     => "cd ${er_state_path} && er_safe_run.sh ${graph_all_cmd}",
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
    require     => Class['elastic_recheck']
  }

  cron { 'elastic-recheck-gate':
    user        => 'recheck',
    minute      => ['10', '40'],
    hour        => '*',
    command     => "cd ${er_state_path} && er_safe_run.sh ${graph_gate_cmd}",
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
    require     => Class['elastic_recheck']
  }


  cron { 'elastic-recheck-uncat':
    user        => 'recheck',
    minute      => ['20', '50'],
    hour        => '*',
    command     => "cd ${er_state_path} && mkdir new && er_safe_run.sh ${uncat_cmd} && rm -r new",
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin',
    require     => Class['elastic_recheck']
  }
}
