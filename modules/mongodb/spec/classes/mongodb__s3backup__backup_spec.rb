require_relative '../../../../spec_helper'

describe 'mongodb::s3backup::backup', :type => :class do
  let(:params) {{
    :aws_access_key_id           => '123456789',
    :aws_secret_access_key       => 'ABCDEFGHIJKLMNOP',
    :aws_region                  => 'eu-west-1',
    :backup_dir                  => '/var/lib/foo',
    :env_dir                     => '/etc/foo',
    :private_gpg_key             => 'test-key-content',
    :private_gpg_key_fingerprint => 'CB77872D51ADD27CF75BD63CB60B50E6DBE2EAFF',
    :s3_bucket                   => 'foo-bucket',
    :server                      => 'localhost',
    :user                        => 'foo-user'
  }}

  context 'mongodb s3backups with AWS defined' do

    it { is_expected.to contain_file('/etc/foo/').with_ensure('directory') }
    it { is_expected.to contain_file('/etc/foo/env.d').with_ensure('directory') }
    it { is_expected.to contain_file('/etc/foo/env.d/AWS_ACCESS_KEY_ID').with_content(/123456789/) }
    it { is_expected.to contain_file('/etc/foo/env.d/AWS_SECRET_ACCESS_KEY').with_content(/ABCDEFGHIJKLMNOP/) }
    it { is_expected.to contain_file('/etc/foo/env.d/AWS_REGION').with_content(/eu-west-1/) }
  end

  context 'mongodb s3backups with GPG key defined' do

    it { is_expected.to contain_file('/home/foo-user/.gnupg').with_ensure('directory') }
    it { is_expected.to contain_file('/home/foo-user/.gnupg/gpg.conf').with_content(/trust-model\ always/) }
    it { is_expected.to contain_file('/home/foo-user/.gnupg/CB77872D51ADD27CF75BD63CB60B50E6DBE2EAFF_secret_key.asc').with_content('test-key-content') }
    it { is_expected.to contain_exec('import_gpg_secret_key')
         .with_refreshonly(true)
    }
  end
end
