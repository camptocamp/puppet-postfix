# == Definition: postfix::hash
#
# Creates postfix hashed "map" files. It will create "${name}", and then build
# "${name}.db" using the "postmap" command. The map file can then be referred to
# using postfix::config.
#
# === Parameters
#
# [*name*]    - the name of the map file.
# [*ensure*]  - present/absent, defaults to present.
# [*source*]  - file source. Mutially exclusive with "content".
# [*content*] - content of the file. Mutially exclusive with "source".
#
# === Requires
#
# - Class["postfix"]
#
# === Examples
#
#   postfix::hash { 'virtual':
#     ensure => present,
#   }
#   postfix::config { 'virtual_alias_maps':
#     value => 'hash:/etc/postfix/virtual',
#   }
#
define postfix::hash (
  Enum['present', 'absent']             $ensure='present',
  Variant[Array[String], String, Undef] $source=undef,
  Optional[Variant[Sensitive[String],String]] $content = undef,
  Variant[String[4,4], Undef]           $mode='0640',
) {
  include ::postfix::params

  assert_type(Stdlib::Absolutepath, $name)

  if (!defined(Class['postfix'])) {
    fail 'You must define class postfix before using postfix::config!'
  }

  if $source and $content {
    fail 'You must provide either \'source\' or \'content\', not both'
  }

  postfix::map {$name:
    ensure  => $ensure,
    source  => $source,
    content => $content,
    type    => 'hash',
    path    => $name,
    mode    => $mode,
  }
}
