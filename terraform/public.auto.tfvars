my-regional-account = {
  name = "regional-k8s-account"
  roles = [
    "k8s.clusters.agent",
    "vpc.publicAdmin",
    "load-balancer.admin",
    "container-registry.images.puller",
    "kms.keys.encrypterDecrypter",
    "dns.editor",
    ]
}