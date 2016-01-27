# == Class: barbican
#

class barbican
{
  $source = 'https://github.com/openstack/barbican.git'
  $devstack_dir = '/home/stack/devstack'
  $barbican_dir = '/home/stack/barbican'
  $user = $user::stack::username

  $libs = [ "python-pip", "python-dev", "libffi-dev",
            "libssl-dev", "libldap2-dev", "libsasl2-dev" ]

  package { $libs:
    ensure => latest
  }

  if $devstack_branch {
    $branch = $barbican_branch
  } else {
    $branch = 'stable/kilo'
  }

  exec { 'barbican_clone':
    require => [
      File['/usr/local/bin/git_clone.sh'],
      Exec['devstack_clone'],
    ],
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.',
    environment => "HOME=/home/$user",
    user => 'stack',
    group => 'stack',
    command => "/usr/local/bin/git_clone.sh ${source} ${branch} ${barbican_dir}",
    logoutput => true,
    timeout => 1200,
  }

  file { "$devstack_dir/lib/barbican":
    ensure => present,
    source  => "$barbican_dir/contrib/devstack/lib/barbican",
    require => Exec['barbican_clone'],
  }

  file { "$devstack_dir/extras.d/70-barbican.sh":
    ensure => present,
    source  => "$barbican_dir/contrib/devstack/extras.d/70-barbican.sh",
    require => Exec['barbican_clone'],
  }

}
