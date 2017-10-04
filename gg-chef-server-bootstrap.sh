#!/bin/bash
# install chef-solo
curl -L https://www.chef.io/chef/install.sh | sudo bash
# create required bootstrap dirs/files
sudo mkdir -p /var/chef/cache /var/chef/cookbooks
# pull down this chef-server cookbook
wget -qO- https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks
# pull down dependency cookbooks
for dep in yum-chef yum apt-chef apt packagecloud line chef-sugar git ssh_keygen
do
  wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | sudo tar xvzC /var/chef/cookbooks
done
# pull down specific chef-ingredient version
knife cookbook site download chef-ingredient 1.1.0
sudo tar -xvzf chef-ingredient-1.1.0.tar.gz -C /var/chef/cookbooks
rm -f chef-ingredient-1.1.0.tar.gz
# GO GO GO!!!
#sudo chef-solo -o 'recipe[chef_server::setup-single]'
#sudo chef-solo -o 'recipe[chef-server::default]'
cd /var/chef/cookbooks
sudo chef-client --local-mode --runlist 'recipe[chef-server::default]'
#sudo chef-client -j ~/.chef/dna.json --local-mode --runlist 'recipe[chef-server::default]'
