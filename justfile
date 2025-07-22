install-ansible-requirements:
  uvx --from=ansible.core ansible-galaxy collection install community.docker
  uvx --from=ansible.core ansible-galaxy collection install community.crypto

ansible-playbook *args:
  uvx --from=ansible.core ansible-playbook --extra-vars "metal/@vars.secrets.yml" {{args}}

setup_dns_server: (ansible-playbook "metal/setup_dns_server.yml")

setup_nebula_cluster: (ansible-playbook "k3s.orchestration.site")

ssh host *args:
  ssh -i keys/astro_id_rsa -o StrictHostKeyChecking=no astro@{{host}} {{args}}

update-kube-config:
  ssh -i keys/astro_id_rsa -o StrictHostKeyChecking=no astro@nebula01.local "sudo cat /etc/rancher/k3s/k3s.yaml" > keys/kubeconfig
  yq e '.clusters[0].cluster.server |= "https://192.168.1.50:6443"' -i keys/kubeconfig
  cp keys/kubeconfig ~/.kube/config

deploy: (ansible-playbook "deploy_stacks.yml")
