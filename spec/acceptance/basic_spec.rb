require 'puppet-openstack_infra_spec_helper/spec_helper_acceptance'

describe 'elastic_recheck', if: os[:family] == 'ubuntu' do

  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures')
  end

  def puppet_manifest
    manifest_path = File.join(pp_path, 'default.pp')
    File.read(manifest_path)
  end

  def postconditions_puppet_manifest
    manifest_path = File.join(pp_path, 'postconditions.pp')
    File.read(manifest_path)
  end

  it 'should work with no errors' do
    apply_manifest(puppet_manifest, catch_failures: true)
  end

  it 'should be idempotent' do
    apply_manifest(puppet_manifest, catch_changes: true)
  end

  describe service('elastic-recheck') do
    it { should be_running }
  end

end
