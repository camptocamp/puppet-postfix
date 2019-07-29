# Postfix Puppet Module

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/postfix.svg)](https://forge.puppetlabs.com/camptocamp/postfix)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/postfix.svg)](https://forge.puppetlabs.com/camptocamp/postfix)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-postfix/master.svg)](https://travis-ci.org/camptocamp/puppet-postfix)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

This module requires Augeas.

## Simple usage
```puppet
include postfix

postfix::config { 'relay_domains':
  ensure  => present,
  value   => 'localhost host.foo.com',
}
```

## Classes

### postfix

The top-level class, to install and configure Postfix.

#### Parameters

##### `alias_maps`

A string defining the location of the alias map file.  
Default: 'hash:/etc/aliases'.  
Example: 'hash:/etc/other_aliases'.

##### `configs`

A hash containing optional configuration values for main.cf. The values are configured using postfix::config.  
Default: An empty hash.  
Example: '{message_size_limit': {'value': '51200000'}}.

##### `inet_interfaces`

A string defining the network interfaces that Postfix will listen on.  
Default: 'all'.  
Example: '127.0.0.1, [::1]'.

##### `inet_protocols`


A string defining the internet protocols that Postfix will use.  
Default: 'all'.  
Example: 'ipv4'.

##### `ldap`

A Boolean defining whether to configure Postfix for LDAP use.  
Default: false.

##### `ldap_base`

A string defining the LDAP search base to use. This parameter maps to the search_base parameter (ldap_table(5)).  
Default: Undefined.  
Example 'cn=Users,dc=example,dc=com'.

##### `ldap_host`

A string defining the LDAP host. This parameter maps to the server_host parameter (ldap_table(5)).  
Default: Undefined.  
Example: 'ldaps://ldap.example.com:636 ldap://ldap2.example.com'.

##### `ldap_options`

A free form string that can define any ldap options to be passed through (ldap_table(5)).  
Default: Undefined.  
Example: 'start_tls = yes'.

##### `mail_user`

A string defining the mail user, and optionally group, to execute external commands as. This parameter maps to the user parameter (pipe(8)).  
Default: 'vmail'.  
Example: 'vmail:vmail'.

##### `mailman`

A Boolean defining whether to configure a basic smtp server that is able to work for the mailman mailing list manager.  
Default: false.

##### `maincf_source`

A string defining the location of a skeleton main.cf file to be used. The default file supplied is blank. However, if the main.cf file already exists on the system the contents will **NOT** be replaced by the contents from maincf_source.  
Default: "puppet:///modules/${module_name}/main.cf".  
Example: 'puppet:///modules/some/other/location/main.cf'.

##### `manage_conffiles`

A Boolean defining whether the puppet module should replace the configuration files for postfix.  
**This setting currently effects only the following files:**
* /etc/mailname
* /etc/postfix/master.cf  


**This setting does NOT effect the following files:**
* /etc/aliases
* /etc/postfix/main.cf

Default: true.

##### `manage_mailx`

A Boolean defining whether the puppet module should manage the mailx package. See also $mailx_ensure.

Default: true.

##### `mastercf_source`
A string defining the location of a skeleton master.cf file to be used.  
Default: Undefined.  
Example: 'puppet:///modules/some/other/location/master.cf'.

##### `master_smtp`
A string to define the smtp line in the /etc/postfix/master.cf file. If this is defined the smtp_listen parameter will be ignored.  
Default: Undefined.  
Example: 'smtp      inet  n       -       n       -       -       smtpd'.

##### `master smtps`
A string to define the smtps line in the /etc/postfix/master.cf file.  
Default: Undefined.  
Example: 'smtps     inet  n       -       n       -       -       smtpd'.

##### `master_submission`
A string to define the submission line in the /etc/postfix/master.cf file.  
Default: Undefined.  
Example: 'submission inet n       -       n       -       -       smtpd'.

##### `master_entries`
Array of strings containing additional entries for the /etc/postfix/master.cf file.
Default: Undefined.
Example: 'submission inet n       -       n       -       -       smtpd'.

##### `mta`
A Boolean to define whether to configure Postfix as a mail transfer agent. This option is mutually exclusive with the satellite Boolean.  
Default: False.

##### `mydestination`
A string to define the mydestination parameter in main.cf (postconf(5)).  
Default: $myhostname, localhost.$mydomain, localhost
Example: 'example.com, foo.example.com'.

##### `mynetworks`
A string to define the mynetworks parameter that holds trusted remote smtp clients (postconf(5)).  
Default: '127.0.0.0/8'.  
Example: '127.0.0.0/8, [::1]/128'.  

##### `myorigin`
A string to define the myorigin parameter that holds the domain name that mail appears to come from (postconf(5)).  
Default: The FQDN of the host.  
Example: 'example.com'

##### `relayhost`
A string to define the relayhost parameter (postconf(5)).  
Default: Undefined.  
Example: 'smtp.example.com'. 

##### `root_mail_recipient`
A string to define the e-mail address to which all mail directed to root should go (aliases(5)).  
Default: 'nobody'.  
Example: 'root_catch@example.com'.

##### `chroot`
A boolean to define if postfix should be run in a chroot jail or not. If not defined, '-' is used (OS dependant)
Default: Undefined.
Example: true

##### `satellite`
A Boolean to define whether to configure postfix as a satellite relay host.  This setting is mutually exclusive with the mta Boolean.  
Default: False.

##### `smtp_listen`
A string to define the IP on which to listen in master.cf. This can also be set to 'all' to listen on all interfaces. If master_smtp is defined smtp_listen will not be used.  
Default: '127.0.0.1'.  
Example: '::1'.

##### `use_amavisd`
A Boolean to define whether to configure master.cf to allow the use of the amavisd scanner.  
Default: False.

##### `use_dovecot_lda`
A Boolean to define whether to configure master.cf to use dovecot as the local delivery agent.  
Default: False.

##### `use_schleuder`
A Boolean to define whether to configure master.cf to use the Schleuder GPG-enabled mailing list.  
Default: False.

##### `use_sympa`
A Boolean to define whether to configure master.cf to use the Sympa mailing list management software.  
Default: False.

#### Examples
##### Include
```puppet
include postfix
```
or
##### Class Resource
```puppet
class { 'postfix':
  inet_interfaces     => 'localhost',
  inet_protocols      => 'ipv4',
  relayhost           => "mail.${facts['domain']}",
  root_mail_recipient => 'dont_bother_the_sysadmins@example.com',
}
```

### postfix::config

Add/alter/remove options in Postfix main configuration file (main.cf). This uses Augeas to do the editing of the configuration file, as such any configuration value can be used.

#### Parameters

##### `ensure`
A string whose value can be any of 'present', 'absent', 'blank'.  
Default: present.  
Example: blank.  

##### `value`
A string that can contain any text to be used as the configuration value.  
Default: Undefined.  
Example: 'btree:${data_directory}/smtp_tls_session_cache'.

#### Examples
##### Configure Postfix to use TLS as a client
```puppet
postfix::config {
  'smtp_tls_mandatory_ciphers':       value   => 'high';
  'smtp_tls_security_level':          value   => 'secure';
  'smtp_tls_CAfile':                  value   => '/etc/pki/tls/certs/ca-bundle.crt';
  'smtp_tls_session_cache_database':  value   => 'btree:${data_directory}/smtp_tls_session_cache';
}
```

##### Configure Postfix to disable the vrfy command
```puppet
postfix::config { 'disable_vrfy_command':
  ensure  => present,
  value   => 'yes',
}
```

### postfix::hash
Creates Postfix hashed "map" files, and builds the corresponding db file.

#### Parameters

##### `ensure`
Defines whether the hash map file is present or not. Value can either be present or absent.  
Default: present.  
Example: absent.

##### `content`
A free form string that defines the contents of the file. This parameter is mutually exclusive with the source parameter.  
Default: Undefined.  
Example: '#Destination                Credentials\nsmtp.example.com            gssapi:nopassword'. 

##### `source`
A string whose value is a location for the source file to be used. This parameter is mutually exclusive with the content parameter, one or the other must be present, but both cannot be present.  
Default: Undefined.  
Example: 'puppet:///modules/some/location/sasl_passwd'.

#### Examples
##### Create a sasl_passwd hash from a source file
```puppet
postfix::hash { '/etc/postfix/sasl_passwd':
  ensure  => 'present',
  source  => 'puppet:///modules/profile/postfix/client/sasl_passwd',
}
```
##### Create a sasl_passwd hash with contents defined in the manifest
```puppet
postfix::hash { '/etc/postfix/sasl_passwd':
  ensure  => 'present',
  content => '#Destination                Credentials\nsmtp.example.com            gssapi:nopassword',
}
```
### postfix::transport

Manages content of the /etc/postfix/transport map.

#### Requirements

Augeas is, of course, required.

The following code is required to use transport maps.
```puppet
include postfix

postfix::hash { '/etc/postfix/transport':
  ensure  => present,
}

postfix::config { 'transport_maps'
  ensure  => present,
  value   => 'hash:/etc/postfix/transport',
}
```
#### Parameters

##### `ensure`
Defines whether the transport entry is present or not. Value can either be present or absent.  
Default: present.  
Example: absent.

##### `destination`
The destination to be delivered to (transport(5)).  
Default: Undefined.  
Example: 'mailman'.

##### `nexthop`
A string to define where and how to deliver the mail (transport(5)).  
Default: Undefined.  
Example: '[smtp.google.com]:25'.

#### Examples

### postfix::virtual

Manages the contents of the virtual map.

#### Requirements
Augeas is, of course, required.

The following code is necessary to make virtual maps work:
```puppet
include postfix

postfix::hash { '/etc/postfix/virtual':
  ensure => present,
}

postfix::config { 'virtual_alias_maps':
  ensure  => present,
  value   => 'hash:/etc/postfix/virtual',
}
```
#### Parameters
##### `ensure`
A string whose valid values are present or absent.  
Default: present.  
Example: absent.

##### `file`
A string defining the location of the virtual map, pre hash.  
Default: '/etc/postfix/virtual'.  
Example: '/etc/postfix/my_virtual_map'.

##### `destination`
A string defining where the e-mails will be delivered to, (virtual(8)).  
Default: Undefined.  
Example: 'root'

#### Examples

##### Route mail bound for 'user@example.com' to root.
```puppet
postfix::virtual {'user@example.com':
    ensure      => present,
    destination => 'root',
}
```

### postfix::conffile

Manages postfix configuration files. With it, you could create configuration files (other than, main.cf, master.cf, etc.) restarting postfix when necessary.

#### Parameters
##### `ensure`
A string whose valid values are present, absent or directory.  
Default: present.  
Example: absent.

##### `source`
A string with the source of the file. This is the `source` parameter of the underlying file resource.  
Default: `undef`  
Example: 'puppet:///modules/postfix/configfile.cf'  

##### `content`
The content of the postfix configuration file. This is an alternative to the `source` parameter. If you don't provide `source` neither `content` parameters a default template is used and the content is created with values in the `options` hash.  
Default: `undef`  

##### `path`
Path where to create the configuration file.  
Default: '/etc/postfix/${name}'

##### `mode`
Permissions of the configuration file. This option is useful if you want to create the file with specific permissions (for example, because you have passwords in it).  
Default: '0644'  
Example: '0640'

##### `options`
Hash with the options used in the default template that is used when neither `source` neither `content`parameters are provided.  
Default: {}  
Example:
```
 postfix::conffile { 'ldapoptions.cf':
   options            => {
     server_host      => ldap.mydomain.com,
     bind             => 'yes',
     bind_dn          => 'cn=admin,dc=mydomain,dc=com',
     bind_pw          => 'password',
     search_base      => 'dc=example, dc=com',
     query_filter     => 'mail=%s',
     result_attribute => 'uid',
   }
 }
```

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-postfix/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](http://puppet-lint.com/) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).
