This script launches an ec2 instance with a chef-server.
The bash script uses aws user data to build the chef server, to which a terminate-instance.sh script and instance-details.json file are generated in this directory upon completion.

# Manually runs recipe
sudo chef-client --local-mode recipe.rb

# Manually runs cookbook
sudo chef-client --local-mode --runlist 'recipe[learn_chef_apache2]'

You also saw the run-list. The run-list lets you specify which recipes to run, and the order in which to run them. This is handy once you have lots of cookbooks, and the order in which they run is important.

# Manually run multiple cookbooks/recipes
sudo chef-client -j ~/.chef/dna.json --local-mode --runlist 'recipe[system::default],recipe[chef_server::default],recipe[chef-server::addons]'

# Manually run  
sudo chef-client -j ~/.chef/dna.json --local-mode --runlist 'recipe[chef-server::default]'


https://docs.chef.io/ctl_chef_client.html
https://docs.chef.io/ctl_chef_client.html#run-in-local-mode
https://docs.chef.io/ctl_chef_client.html#about-chef-zero
