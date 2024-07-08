#!/bin/bash
echo "${tls_private_key.jenkins_key.private_key_pem}" > /home/ubuntu/jenkins_private_key.pem
chmod 400 /home/ubuntu/jenkins_private_key.pem
sudo chown ubuntu:ubuntu /home/ubuntu/jenkins_private_key.pem
echo "${tls_private_key.k8s_key.private_key_pem}" > /home/ubuntu/k8s_private_key.pem
chmod 400 /home/ubuntu/k8s_private_key.pem
sudo chown ubuntu:ubuntu /home/ubuntu/k8s_private_key.pem
