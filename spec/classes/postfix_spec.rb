require 'spec_helper'

describe 'postfix' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:postfix_main_cf_path) do
        case facts[:osfamily]
        when 'FreeBSD' then '/usr/local/etc/postfix/main.cf'
        else '/etc/postfix/main.cf'
        end
      end
      let(:postfix_master_cf_path) do
        case facts[:osfamily]
        when 'FreeBSD' then '/usr/local/etc/postfix/master.cf'
        else '/etc/postfix/master.cf'
        end
      end
      let(:postfix_transport_path) do
        case facts[:osfamily]
        when 'FreeBSD' then '/usr/local/etc/postfix/transport'
        else '/etc/postfix/transport'
        end
      end
      let(:postfix_virtual_path) do
        case facts[:osfamily]
        when 'FreeBSD' then '/usr/local/etc/postfix/virtual'
        else '/etc/postfix/virtual'
        end
      end

      let(:facts) do
        facts.merge(augeasversion: '1.2.0',
                    puppetversion: Puppet.version)
      end

      context 'when using defaults' do
        it { is_expected.to contain_package('postfix') }
        it { is_expected.to contain_exec('newaliases').with_refreshonly('true') }
        it { is_expected.to contain_postfix__config('myorigin').with_value('foo.example.com') }
        it { is_expected.to contain_postfix__config('alias_maps').with_value('hash:/etc/aliases') }
        it { is_expected.to contain_postfix__config('inet_interfaces').with_value('all') }
        it { is_expected.to contain_postfix__config('inet_protocols').with_value('all') }
        it { is_expected.to contain_mailalias('root').with_recipient('nobody') }

        context 'when on Debian family', excl: facts[:osfamily] != 'Debian' do
          it { is_expected.to contain_package('mailx') }
          it { is_expected.to contain_file('/etc/mailname').without('seltype').with_content("foo.example.com\n") }
          it { is_expected.to contain_file('/etc/aliases').without('seltype').with_content("# file managed by puppet\n") }
          it { is_expected.to contain_file(postfix_master_cf_path).without('seltype') }
          it { is_expected.to contain_file(postfix_main_cf_path).without('seltype') }

          it {
            is_expected.to contain_service('postfix').with(
              ensure: 'running',
              enable: 'true',
              hasstatus: 'true',
              restart: '/etc/init.d/postfix reload',
            )
          }
        end

        context 'when on RedHat family', excl: facts[:osfamily] != 'RedHat' do
          it { is_expected.to contain_package('mailx') }
          it { is_expected.to contain_file('/etc/mailname').with_seltype('postfix_etc_t').with_content("foo.example.com\n") }
          it { is_expected.to contain_file(postfix_master_cf_path).with_seltype('postfix_etc_t') }
          it { is_expected.to contain_file(postfix_main_cf_path).with_seltype('postfix_etc_t') }

          it { is_expected.to contain_postfix__config('sendmail_path') }
          it { is_expected.to contain_postfix__config('newaliases_path') }
          it { is_expected.to contain_postfix__config('mailq_path') }

          context 'when on release 8', excl: (facts[:osfamily] != 'RedHat' || facts[:operatingsystemmajrelease] != '8') do
            it { is_expected.to contain_file('/etc/aliases').with_seltype('etc_aliases_t').with_content("# file managed by puppet\n") }
            it {
              is_expected.to contain_service('postfix').with(
                ensure: 'running',
                enable: 'true',
                hasstatus: 'true',
                restart: '/bin/systemctl reload postfix',
              )
            }
          end

          context 'when on release 7', excl: (facts[:osfamily] != 'RedHat' || facts[:operatingsystemmajrelease] != '7') do
            it { is_expected.to contain_file('/etc/aliases').with_seltype('etc_aliases_t').with_content("# file managed by puppet\n") }
            it {
              is_expected.to contain_service('postfix').with(
                ensure: 'running',
                enable: 'true',
                hasstatus: 'true',
                restart: '/bin/systemctl reload postfix',
              )
            }
          end

          context 'when on release 6', excl: (facts[:osfamily] != 'RedHat' || facts[:operatingsystemmajrelease] != '6') do
            it { is_expected.to contain_file('/etc/aliases').with_seltype('etc_aliases_t').with_content("# file managed by puppet\n") }
            it {
              is_expected.to contain_service('postfix').with(
                ensure: 'running',
                enable: 'true',
                hasstatus: 'true',
                restart: '/etc/init.d/postfix reload',
              )
            }

            context 'when on Fedora', excl: facts[:operatingsystem] != 'Fedora' do
              it { is_expected.to contain_file('/etc/aliases').with_seltype('etc_aliases_t').with_content("# file managed by puppet\n") }
              it {
                is_expected.to contain_service('postfix').with(
                  ensure: 'running',
                  enable: 'true',
                  hasstatus: 'true',
                  restart: '/bin/systemctl reload postfix',
                )
              }
            end

            context('when on other', excl: (facts[:osfamily] != 'RedHat' || facts[:operatingsystem] == 'Fedora' || ['6', '7', '8'].include?(facts[:operatingsystemmajrelease]))) do
              context('on Linux', excl: facts[:osfamily] != 'Linux') do
                it { is_expected.to contain_file('/etc/aliases').with_seltype('postfix_etc_t').with_content("# file managed by puppet\n") }
              end
              it {
                is_expected.to contain_service('postfix').with(
                  ensure: 'running',
                  enable: 'true',
                  hasstatus: 'true',
                  restart: '/etc/init.d/postfix reload',
                )
              }
            end
          end
        end
      end

      context 'when setting parameters' do
        case facts[:osfamily]
        when 'Debian'
          context "when setting smtp_listen to 'all'" do
            let(:params) do
              {
                smtp_listen: 'all',
                root_mail_recipient: 'foo',
                use_amavisd: true,
                use_dovecot_lda: true,
                use_schleuder: true,
                use_sympa: true,
                mail_user: 'bar',
                myorigin: 'localhost',
                inet_interfaces: 'localhost2',
                master_smtp: "smtp      inet  n       -       -       -       -       smtpd
    -o smtpd_client_restrictions=check_client_access,hash:/etc/postfix/access,reject",
                master_smtps: 'smtps     inet  n       -       -       -       -       smtpd',
                master_submission: 'submission inet n       -       -       -       -       smtpd',
              }
            end

            it { is_expected.to contain_package('postfix') }
            it { is_expected.to contain_package('mailx') }

            it { is_expected.to contain_file('/etc/mailname').without('seltype').with_content("foo.example.com\n") }
            it { is_expected.to contain_file('/etc/aliases').without('seltype').with_content("# file managed by puppet\n") }
            it { is_expected.to contain_exec('newaliases').with_refreshonly('true') }
            it {
              is_expected.to contain_file(postfix_master_cf_path).without('seltype').with_content(
                %r{smtp      inet  n       -       -       -       -       smtpd},
              ).with_content(
                %r{amavis unix},
              ).with_content(
                %r{dovecot.*\n.* user=bar:bar },
              ).with_content(
                %r{schleuder},
              ).with_content(
                %r{sympa},
              ).with_content(
                %r{user=bar},
              ).with_content(
                %r{^smtp.*\n.*smtpd_client_restrictions=check_client_access,hash:},
              ).with_content(
                %r{^smtps     inet  n},
              ).with_content(
                %r{^submission inet n},
              )
            }
            it { is_expected.to contain_file(postfix_main_cf_path).without('seltype') }

            it { is_expected.to contain_postfix__config('myorigin').with_value('localhost') }
            it { is_expected.to contain_postfix__config('alias_maps').with_value('hash:/etc/aliases') }
            it { is_expected.to contain_postfix__config('inet_interfaces').with_value('localhost2') }

            it { is_expected.to contain_mailalias('root').with_recipient('foo') }

            it {
              is_expected.to contain_service('postfix').with(
                ensure: 'running',
                enable: 'true',
                hasstatus: 'true',
                restart: '/etc/init.d/postfix reload',
              )
            }
          end
        else
          context 'when specifying inet_interfaces' do
            let(:params) do
              {
                inet_interfaces: 'localhost2',
              }
            end

            it 'creates a postfix::config defined type with inet_interfaces specified properly' do
              is_expected.to contain_postfix__config('inet_interfaces').with_value('localhost2')
            end
          end
          context 'when enabling ldap' do
            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when a custom mail_user is specified' do
            let(:params) do
              {
                mail_user: 'bar',
              }
            end

            it 'adjusts the content of /etc/postfix/master.cf specifying the user' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(%r{user=bar})
            end
          end
          context 'when mailman is true' do
            let(:params) do
              {
                mailman: true,
              }
            end

            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying a custom mastercf_source' do
            let(:params) do
              {
                mastercf_source: 'testy',
              }
            end

            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying a custom mastercf_content' do
            let(:params) do
              {
                mastercf_content: 'testy',
              }
            end

            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying a custom mastercf_template' do
            let(:params) do
              {
                mastercf_template: 'testy',
              }
            end

            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying a custom mastercf_source and mastercf_content' do
            let(:params) do
              {
                mastercf_source: 'testy_1',
                mastercf_content: 'testy_2',
              }
            end

            it 'fails' do
              expect { is_expected.to compile }.to raise_error(%r{mutually exclusive})
            end
          end
          context 'when specifying a custom mastercf_source and mastercf_template' do
            let(:params) do
              {
                mastercf_source: 'testy_1',
                mastercf_template: 'testy_2',
              }
            end

            it 'fails' do
              expect { is_expected.to compile }.to raise_error(%r{mutually exclusive})
            end
          end
          context 'when specifying a custom mastercf_content and mastercf_template' do
            let(:params) do
              {
                mastercf_content: 'testy_1',
                mastercf_template: 'testy_2',
              }
            end

            it 'fails' do
              expect { is_expected.to compile }.to raise_error(%r{mutually exclusive})
            end
          end
          context 'when specifying a mastercf_source and custom mastercf_content and mastercf_template' do
            let(:params) do
              {
                mastercf_source: 'testy_1',
                mastercf_content: 'testy_2',
                mastercf_template: 'testy_3',
              }
            end

            it 'fails' do
              expect { is_expected.to compile }.to raise_error(%r{mutually exclusive})
            end
          end
          context 'when specifying a custom master_smtp' do
            let(:params) do
              {
                master_smtp: "smtp      inet  n       -       -       -       -       smtpd
      -o smtpd_client_restrictions=check_client_access,hash:/etc/postfix/access,reject",
              }
            end

            it 'updates master.cf with the specified flags to smtp' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(
                %r{smtp      inet  n       -       -       -       -       smtpd},
              ).with_content(
                %r{^smtp.*\n.*smtpd_client_restrictions=check_client_access,hash:},
              )
            end
          end
          context 'when specifying a custom master_smtps' do
            let(:params) do
              {
                master_smtps: 'smtps     inet  n       -       -       -       -       smtpd',
              }
            end

            it 'updates master.cf with the specified flags to smtps' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(%r{^smtps     inet  n})
            end
          end
          context 'when mta is enabled' do
            let(:params) { { mta: true, mydestination: '1.2.3.4', relayhost: '2.3.4.5' } }

            it 'configures postfix as a minimal MTA, delivering mail to the mydestination param' do
              is_expected.to contain_postfix__config('mydestination').with_value('1.2.3.4')
              is_expected.to contain_postfix__config('mynetworks').with_value('127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128')
              is_expected.to contain_postfix__config('relayhost').with_value('2.3.4.5')
              is_expected.to contain_postfix__config('virtual_alias_maps').with_value("hash:#{postfix_virtual_path}")
              is_expected.to contain_postfix__config('transport_maps').with_value("hash:#{postfix_transport_path}")
            end
            it { is_expected.to contain_class('postfix::mta') }
            context 'and satellite is also enabled' do
              let(:params) { { mta: true, satellite: true, mydestination: '1.2.3.4', relayhost: '2.3.4.5' } }

              it 'fails' do
                expect { is_expected.to compile }.to raise_error(%r{Please disable one})
              end
            end
          end
          context 'when specifying mydestination' do
            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying mynetworks' do
            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying myorigin' do
            let(:params) { { myorigin: 'localhost' } }

            it 'creates a postfix::config defined type with myorigin specified properly' do
              is_expected.to contain_postfix__config('myorigin').with_value('localhost')
            end
          end
          context 'when specifying relayhost' do
            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when specifying a root_mail_recipient' do
            let(:params) { { root_mail_recipient: 'foo' } }

            it 'contains a Mailalias resource directing roots mail to the required user' do
              is_expected.to contain_mailalias('root').with_recipient('foo')
            end
          end
          context 'when specifying satellite' do
            let(:params) { { satellite: true, mydestination: '1.2.3.4', relayhost: '2.3.4.5' } }
            let :pre_condition do
              "class { 'augeas': }"
            end

            it 'configures all local email to be forwarded to $root_mail_recipient delivered through $relayhost' do
              is_expected.to contain_postfix__config('mydestination').with_value('1.2.3.4')
              is_expected.to contain_postfix__config('mynetworks').with_value('127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128')
              is_expected.to contain_postfix__config('relayhost').with_value('2.3.4.5')
              is_expected.to contain_postfix__config('virtual_alias_maps').with_value("hash:#{postfix_virtual_path}")
              is_expected.to contain_postfix__config('transport_maps').with_value("hash:#{postfix_transport_path}")
            end
            context 'and mta is also enabled' do
              let(:params) { { mta: true, satellite: true, mydestination: '1.2.3.4', relayhost: '2.3.4.5' } }

              it 'fails' do
                expect { is_expected.to compile }.to raise_error(%r{Please disable one})
              end
            end
          end
          context 'when specifying smtp_listen' do
            let(:params) { { smtp_listen: 'all' } }

            it 'does stuff' do
              skip 'need to write this still'
            end
          end
          context 'when use_amavisd is true' do
            let(:params) { { use_amavisd: true } }

            it 'updates master.cf with the specified flags to amavis' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(%r{amavis unix})
            end
          end
          context 'when use_dovecot_lda is true' do
            let(:params) { { use_dovecot_lda: true } }

            it 'updates master.cf with the specified flags to dovecot' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(%r{dovecot.*\n.* user=vmail:vmail })
            end
          end
          context 'when use_schleuder is true' do
            let(:params) { { use_schleuder: true } }

            it 'updates master.cf with the specified flags to schleuder' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(%r{schleuder})
            end
          end
          context 'when use_sympa is true' do
            let(:params) { { use_sympa: true } }

            it 'updates master.cf to include sympa' do
              is_expected.to contain_file(postfix_master_cf_path).with_content(%r{sympa})
            end
          end
          context 'when manage_root_alias is false' do
            let(:params) { { manage_root_alias: false } }

            it 'does not manage root mailalias' do
              is_expected.not_to contain_mailalias('root')
            end
          end
          context 'when manage_mailx is false' do
            let(:params) { { manage_mailx: false } }

            it 'does not have mailx package' do
              is_expected.not_to contain_package('mailx')
            end
          end
          context 'when config hash is used' do
            let(:params) do
              {
                configs: {
                  'message_size_limit' => {
                    'value' => '51200000',
                  },
                },
              }
            end

            it 'updates master.cf with the specified contents' do
              is_expected.to contain_postfix__config('message_size_limit').with_value('51200000')
            end
          end
          context 'when hash hash is used' do
            let(:params) do
              {
                hash: {
                  '/etc/postfix/transport' => {
                    'ensure' => 'present',
                  },
                },
              }
            end

            it 'updates master.cf with the specified contents' do
              is_expected.to contain_postfix__hash('/etc/postfix/transport').with_ensure('present')
            end
          end
          context 'when transport hash is used' do
            let(:params) do
              {
                transport: {
                  'local_relay' => {
                    'nexthop' => '[10.12.0.2]:9925',
                  },
                },
              }
            end

            it 'updates master.cf with the specified contents' do
              is_expected.to contain_postfix__transport('local_relay').with_nexthop('[10.12.0.2]:9925')
            end
          end
          context 'when virtual hash is used' do
            let(:params) do
              {
                virtual: {
                  'someone@somedomain.tld' => {
                    'destination' => 'internal@ourdomain.tld',
                  },
                },
              }
            end

            it 'updates master.cf with the specified contents' do
              is_expected.to contain_postfix__virtual('someone@somedomain.tld').with_destination('internal@ourdomain.tld')
            end
          end
          context 'when conffile hash is used' do
            let(:params) do
              {
                conffile: {
                  'ldapoptions.cf' => {
                    'mode'    => '0640',
                    'options' => {
                      'server_host'      => 'ldap.mydomain.com',
                      'bind'             => 'yes',
                      'bind_dn'          => 'cn=admin,dc=mydomain,dc=com',
                      'bind_pw'          => 'password',
                      'search_base'      => 'dc=example, dc=com',
                      'query_filter'     => 'mail=%s',
                      'result_attribute' => 'uid',
                    },
                  },
                },
              }
            end

            it 'creates ldapoptions.cf with the specified contents' do
              is_expected.to contain_postfix__conffile('ldapoptions.cf').with(
                'mode'    => '0640',
                'options' => {
                  'server_host'      => 'ldap.mydomain.com',
                  'bind'             => 'yes',
                  'bind_dn'          => 'cn=admin,dc=mydomain,dc=com',
                  'bind_pw'          => 'password',
                  'search_base'      => 'dc=example, dc=com',
                  'query_filter'     => 'mail=%s',
                  'result_attribute' => 'uid',
                }
              )
            end
          end
        end
      end
    end
  end
end
