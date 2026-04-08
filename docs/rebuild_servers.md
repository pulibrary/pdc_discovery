# Rebuilding the servers
Rebuild the servers regularly to pick up new base images and ensure our rebuild procedure stays current. 

The general flow looks like: 
1. remove a node from the load balancer
2. rebuild it
3. return it to the load balancer
4. ensure all is well

By doing this in staging, then production, you can rebuild all the servers with no downtime.

### 1. Remove the node from the load balancer
Give it a few minutes to catch up.
```
bundle exec cap --hosts=[$HOSTNAME].princeton.edu [staging|production] application:remove_from_nginx
```

### 2. Rebuild it
* [Replace the VM via ansible tower](https://github.com/pulibrary/pul-it-handbook/blob/main/services/replace_rebuild_vm.md)
* From princeton_ansible, install the checkmk monitoring and run the project playbook:
    ```
    ansible-playbook playbooks/utils/checkmk_agent.yml --limit=pdc_discovery_[staging|production] -e checkmk_folder=linux/rdss -e checkmk_service=[staging|production] -e runtime_env=[staging|production]

    ansible-playbook playbooks/pdc_discovery.yml -e runtime_env=[staging|production]
    ```
* Deploy with capistrano or tower:
    ```
    bundle exec cap [staging|production] deploy
    ```

### 3. Return to load balancer 
bundle exec cap --hosts=[$HOSTNAME].princeton.edu [staging|production] application:serve_from_nginx

### 4. Go check everything looks right
Visit the site (make sure you reload several times) and if everything looks good, move on to the next one!