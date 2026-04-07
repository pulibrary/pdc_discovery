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
bundle exec cap --hosts=pdc-discovery-prod2.princeton.edu production application:remove_from_nginx
```

### 2. Rebuild it
* [Replace the VM via ansible tower](https://github.com/pulibrary/pul-it-handbook/blob/main/services/replace_rebuild_vm.md)
* From princeton_ansible, install the checkmk monitoring and run the project playbook:
    ```
    ansible-playbook playbooks/utils/checkmk_agent.yml --limit=pdc_discovery_staging -e checkmk_folder=linux/rdss -e checkmk_service=staging

    ansible-playbook playbooks/pdc_discovery.yml
    ```
* Deploy with capistrano or tower:
    ```
    bundle exec cap staging deploy
    ```

### Return to load balancer 
bundle exec cap --hosts=pdc-discovery-prod2.princeton.edu production application:serve_from_nginx
