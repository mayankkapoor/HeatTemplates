# heat-kubeadm

Heat stack template for installing Kubernetes with kubeadm.

## Installation

On the machine that will be used to install this stack we need
following packages:

Basic steps are:


1. Prepare template config
2. Create stack
3. Wait for it to finish


### Prepare template config

Here is an example of environment file (lets call it `env.yaml`) that can be
used to create the stack:

```yaml
parameters:
    key_name: XXXXX
    image: Ubuntu1604
    master_flavor: m1.large
    slave_flavor: m1.large
    availability_zone: XXXXX
    public_network_id: XXXXX
    proxy_host: XXXXX
    proxy_port: XXXXX
    volume_size: XXXXX
    dns_nameservers: XXXXX,XXXXX
```

You must  specify name of your SSH key in OpenStack in `key_name`,
name or ID of image to use for nodes in `image` and availability zone for
VMs in `availability_zone`.

If you need to use proxy with your environment, you can add these options:

```yaml
    proxy_host: XXXXX
    proxy_port: XXXXX
```

All other options and their descriptions can be found at the top of
`stack_full.yaml` file.

Note that if you would like to deploy stack in existing network, you can
specify `internal_net` parameter in environment file and then use template
`stack.yaml`.

### Create Heat stack


To create Heat stack, issue command:

```bash
$ openstack --insecure stack create -t stack_full.yaml -e env.yaml k8s-stack3 --wait                                                                                
```

If you do specify `--wait` flag, output should look like this:
```
2019-06-12 13:46:40Z [k8s-stack3]: CREATE_IN_PROGRESS  Stack CREATE started
2019-06-12 13:46:41Z [random_string]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:46:41Z [random_string]: CREATE_COMPLETE  state changed
2019-06-12 13:46:41Z [prefix_random]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:46:41Z [prefix_random]: CREATE_COMPLETE  state changed
2019-06-12 13:46:41Z [internal_net]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:46:41Z [security_group]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:46:50Z [internal_net]: CREATE_COMPLETE  state changed
2019-06-12 13:46:51Z [internal_subnet]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:46:56Z [internal_subnet]: CREATE_COMPLETE  state changed
2019-06-12 13:46:58Z [internal_router]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:47:03Z [internal_router]: CREATE_COMPLETE  state changed
2019-06-12 13:47:06Z [internal_router_interface]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:47:09Z [security_group]: CREATE_COMPLETE  state changed
2019-06-12 13:47:09Z [stack]: CREATE_IN_PROGRESS  state changed
2019-06-12 13:47:10Z [internal_router_interface]: CREATE_COMPLETE  state changed
2019-06-12 13:49:12Z [stack]: CREATE_COMPLETE  state changed
2019-06-12 13:49:12Z [k8s-stack3]: CREATE_COMPLETE  Stack CREATE completed successfully
+---------------------+----------------------------------------+
| Field               | Value                                  |
+---------------------+----------------------------------------+
| id                  | 34cb5412-a09f-48e2-ac64-eff888e4c010   |
| stack_name          | k8s-stack3                             |
| description         | Deploy Kubernetes cluster with kubeadm |
| creation_time       | 2019-06-12T13:46:40Z                   |
| updated_time        | None                                   |
| stack_status        | CREATE_COMPLETE                        |
| stack_status_reason | Stack CREATE completed successfully    |
+---------------------+----------------------------------------+
```

The line `[k8s-stack3]: CREATE_COMPLETE  Stack CREATE completed successfully`
means that stack has been created successfully.

### Wait for Kubernetes to be installed

After stack creation is completed, you can SSH to master node ip:

```bash
openstack --insecure stack show k8s-stack3
+-----------------------+-------------------------------------------------------------------------------------------------------------------------------+
| Field                 | Value                                                                                                                         |
+-----------------------+-------------------------------------------------------------------------------------------------------------------------------+
| id                    | 34cb5412-a09f-48e2-ac64-eff888e4c010                                                                                          |
| stack_name            | k8s-stack3                                                                                                                    |
| description           | Deploy Kubernetes cluster with kubeadm                                                                                        |
| creation_time         | 2019-06-12T13:46:40Z                                                                                                          |
| updated_time          | None                                                                                                                          |
| stack_status          | CREATE_COMPLETE                                                                                                               |
| stack_status_reason   | Stack CREATE completed successfully                                                                                           |
| parameters            | OS::project_id: a9bef390359246e9817f13c32f7e33e6                                                                              |
|                       | OS::stack_id: 34cb5412-a09f-48e2-ac64-eff888e4c010                                                                            |
|                       | OS::stack_name: k8s-stack3                                                                                                    |
|                       | availability_zone: JMNG-PE3-NONPROD                                                                                           |
|                       | dns_nameservers: '[u''10.137.2.5'', u''10.137.2.6'', u''8.8.8.8'']'                                                           |
|                       | image: Ubuntu1604                                                                                                             |
|                       | key_name: mj                                                                                                                  |
|                       | master_flavor: m1.large                                                                                                       |
|                       | proxy_host: 10.157.240.254                                                                                                    |
|                       | proxy_port: '8678'                                                                                                            |
|                       | public_network_id: non-prod2                                                                                                  |
|                       | resource_prefix: k8s-                                                                                                         |
|                       | slave_count: '3'                                                                                                              |
|                       | slave_flavor: m1.large                                                                                                        |
|                       | volume_size: '60'                                                                                                             |
|                       |                                                                                                                               |
| outputs               | - description: Master IP of kubernetes cluster                                                                                |
|                       |   output_key: ip                                                                                                              |
|                       |   output_value: 10.157.251.117                                                                                                |
|                       |                                                                                                                               |
| links                 | - href: https://10.147.202.80:8004/v1/a9bef390359246e9817f13c32f7e33e6/stacks/k8s-stack3/34cb5412-a09f-48e2-ac64-eff888e4c010 |
|                       |   rel: self                                                                                                                   |
|                       |                                                                                                                               |
| parent                | None                                                                                                                          |
| disable_rollback      | True                                                                                                                          |
| deletion_time         | None                                                                                                                          |
| stack_user_project_id | c2439310e3aa4064a47cfcc5da84e236                                                                                              |
| capabilities          | []                                                                                                                            |
| notification_topics   | []                                                                                                                            |
| stack_owner           | None                                                                                                                          |
| timeout_mins          | None                                                                                                                          |
| tags                  | null                                                                                                                          |
|                       | ...                                                                                                                           |
|                       |                                                                                                                               |
+-----------------------+-------------------------------------------------------------------------------------------------------------------------------+
```

There you can check if Kubernetes deploymentis is in progress:

```bash
$ ssh -i mj.key ubuntu@10.157.251.117 
```

Now you can verify that kubernetes is up:

```bash
$ sudo -i
# kubectl get nodes
NAME                           STATUS   ROLES    AGE   VERSION  
k8s-zwxoxotidzptqnqj-master    Ready    master   83s   v1.14.3   
k8s-zwxoxotidzptqnqj-slave-0   Ready    <none>   34s   v1.14.3  
k8s-zwxoxotidzptqnqj-slave-1   Ready    <none>   58s   v1.14.3   
k8s-zwxoxotidzptqnqj-slave-2   Ready    <none>   30s   v1.14.3
```

If you don't see all nodes there or some of them are in NotReady state, it
means that cluster is not up yet. You should repeat `kubectl get nodes` again
untill you see all nodes in Ready state.

