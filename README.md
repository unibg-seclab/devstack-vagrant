devstack-vagrant
================

This is an attempt to build an easy to use tool to bring up a 2 node
devstack environment for local testing using Vagrant + Puppet.

It is *almost* fully generic, but still hard codes a few things about
my environment for lack of a way to figure out how to do this
completely generically (puppet templates currently hate me under
vagrant).

This will build a vagrant cluster that is L2 bridged to the interface
that you specify in ``config.yaml``. All devstack guests (2nd
level) will also be L2 bridged to that network as well. That means
that once you bring up this environment you will be able to ssh
stack@api (or whatever your hostname is) from any machines on your
network.

Getting Started
------------------------

- Install vagrant & virtual box

- Configure a base ``~/.vagrant.d/Vagrantfile`` to set your VM size. If you
  have enough horsepower you should make the file something like:

      VAGRANTFILE_API_VERSION = "2"

      Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
          config.vm.provider :virtualbox do |vb|

               # Use VBoxManage to customize the VM. For example to change memory:
               vb.customize ["modifyvm", :id, "--memory", "8192"]
               vb.customize ["modifyvm", :id, "--cpus", "4"]
           end
      end

  For our tests, ``2048`` for the memory and ``2`` for cpus should be enough.

- Install the ``vagrant-hostmanager`` and ``vagrant-cachier`` plugins:

        vagrant plugin install vagrant-hostmanager
        vagrant plugin install vagrant-cachier

- Check the configuration defined in the ``config.yaml`` file. You have to
  change at least the ``bridge_int`` value, setting the interface name
  on which you want the devstack nodes to get bridged (the one you are
  connected to; use ``ifconfig`` and use exactly the name showed there).

- Start the vagrant boxes:

        vagrant up

- Check that the boxes are working. From inside the repository directory:

  - get the status of the boxes with:

          vagrant status

  - connect via ssh to the machines using:

          vagrant ssh BOXNAME

- If everything worked correctly you should be able to open the page
  <http://manager.openstack.site> .


- You can stop the boxes with ``vagrant halt`` and destroy them with
  ``vagrant destroy``.


Local Setup
--------------------
Copy ``config.yaml.sample`` to ``config.yaml`` and provide the
hostnames you want, and password hash (not password), and sshkey for
the stack user.

Then run vagrant up.

On a 32 GB Ram, 4 core i7 haswell, on an SSD, with Fios, this takes
25 - 30 minutes. So it's not quick. However it is repeatable.

If you want to speed-up the process, install the
[vagrant-cachier](https://github.com/fgrehm/vagrant-cachier) plugin in order
to let vagrant cache files, such as apt packages, with:

    vagrant plugin install vagrant-cachier


What you should get
-----------------------------------
A 2 node devstack that includes cirros mini cloud image populated in glance.
You can get other images population such as fedora 20, ubuntu 12.04,
and ubuntu 14.04, just with a small addtion to ``extra_images`` part
in ``config.yaml.sample``.

Default security group with ssh and ping opened up.

Installation of the stack user ssh key as the default keypair.

Enable additional services
------------------------
The devstack environment created by this `Vagrantfile` includes just the basic
services to get started with OpenStack. If you want to try more services, you
can enable them on the manager node through the ``config.yaml`` file.

For example if you want to enable [Swift](http://swift.openstack.org), you can
add the following line to your ``config.yaml``:

    manager_extra_services: s-proxy s-object s-container s-account
