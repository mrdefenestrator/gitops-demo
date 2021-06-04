Vagrant.configure("2") do |config|
  config.vm.define "demo" do |demo|
    demo.vm.box = "centos/7"
    demo.vm.network "forwarded_port", guest: 8080, host: 8080
    demo.vm.hostname = "demo"
    demo.vm.provision "shell", inline: "/vagrant/demo.sh"
  end
end