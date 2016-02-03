# == Class: barbican
#

class barbican
{

  $devstack_dir = '/home/stack/devstack'
  $barbican_dir = '/home/stack/barbican'
  $user = $user::stack::username

  if $barbican_git {
    $source = $barbican_git
  } else {
    $source = 'https://github.com/openstack/barbican.git'
  }

  $libs = [ "python-pip", "python-dev", "libffi-dev",
            "libssl-dev", "libldap2-dev", "libsasl2-dev" ]

  package { $libs:
    ensure => latest
  }

  if $barbican_branch {
    $branch = $barbican_branch
  } elsif $devstack_branch {
    $branch = $devstack_branch
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

  file { "/etc/profile.d/Z99-barbican.sh":
    owner => 'root',
    group => 'root',
    mode => '0755',
    content => template('barbican/Z99-barbican.erb'),
  }

  if $hostname_manager {
    $barbican_host = $hostname_manager
  } else {
    $barbican_host = 'localhost'
  }

  exec { 'barbican_set_host_href':
    require => Exec['barbican_clone'],
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:.',
    user => 'stack',
    group => 'stack',
    command => "sed -i 's/localhost:9311/$barbican_host:9311/g' $barbican_dir/etc/barbican/*.conf",
    logoutput => true,
    timeout => 10,
  }

}
