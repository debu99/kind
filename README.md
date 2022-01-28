# Nginx ingress benchmark automation test

This repo is used to create a Kind K8s cluster on Ubuntu linux and start nginx ingress benchmark automatically, a CSV file will be generated from Prometheus metrics when the test is done and download to the ansible controller host.


## Features

- Install the [Kind](https://kind.sigs.k8s.io) K8s cluster on Ubuntu linux autoatmically
- Install [ArgoCD](https://argoproj.github.io) and sync the K8s components installation with git repo
- Run benchmark with [Wrk](https://github.com/wg/wrk) against [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/) and generate a csv result from [Prometheus](https://prometheus.io) endpoint

## Pre-requisite
The script requires below component to run:
- [Ansible](https://ansible.com/) - simple IT automation engine

## Installation
On MacOs
```sh
brew install ansible
```
On Ubuntu
```sh
apt install ansible
```

## Folder Structure

Source code is currently organized as ansible role folder structure.
```

localk8s

/
│   README.md
└───ansible
    │   hosts.txt 
    │   playbook.yml 
    └───roles
        └───argocd
        │   └───defaults
        │       │   main.yml
        │   └───files
        │       │   argocd_install.sh
        │       │   check_pod.sh
        │   └───tasks
        │       │   main.yml
        │   └───templates
        │       │   argocd_configmap.yaml.j2
        └───benchmark
        │   └───defaults
        │       │   main.yml
        │   └───files
        │       │   random_path.lua
        │   └───tasks
        │       │   main.yml
        └───docker
        |   └───defaults
        |       │   main.yml
        |   └───handlers
        |       │   main.yml
        |   └───tasks
        |       │   main.yml
        └───kind
        |   └───defaults
        |       │   main.yml
        |   └───tasks
        |       │   main.yml
        |   └───templates
        |       │   kind-config.yaml
└───localk8s
    └───argocd-applications
    └───bar
    └───foo
    └───ingress
    └───metrics-server
    └───nginx
    └───prometheus
```
    
| File/Folder | Usage |
| ------ | ------ |
| README.md | This file |
| hosts.txt | Ansible host file |
| playbook.yml | Ansible playbook file |
| kind-config.yaml | Kind cluster configuration file |
| argocd_install.sh | ArgoCD installation bash script |
| check_pod.sh | Bash script checks K8S pod healthy status with K8S API |
| argocd_configmap.yaml.j2 |  ArgoCD configmap yaml template |
| random_path.lua |  Wrk lua script |
| main.yml |  Ansible yaml file |
| localk8s |  Argocd K8s cluster directory |
| argocd-applications |  Argocd application yaml |
| bar |  Hashicorp echo |
| foo |  Hashicorp echo |
| ingress | Echo ingress |
| metrics-server | Metric server |
| nginx |  Nginx ingress conroller |
| prometheus |  Prometheus |

## How does the script work
The script uses different ansible roles to install Kind K8s cluster, and then sync the nginx, promethues and [echo pods](https://github.com/hashicorp/http-echo) with ArgoCD, when the components installation is done, Wrk will be used to launch a benchmark test for nginx ingress, then the results will be collected from Prometheus endpoint and download to the Ansible controller host.

## How to run the script

Configure remote Ubuntu IP in hosts.txt:
```
[test]
13.229.71.142

[test:vars]
ansible_ssh_user=SSH_USERNAME
ansible_ssh_private_key_file=~/.ssh/YOUR_PRIVATE_KEY.pem
```
Configure git repo and token in playbook.yml:
```
- hosts: test
  vars:
    cluster_name: localk8s
    git_url: https://github.com/debu99/kind.git
    git_user: git
    git_token: YOUR_GITHUB_TOKEN
......
```
Run below command under terminal:
```
ansible-playbook -i hosts.txt playbook.yml 
```

## License

MIT
