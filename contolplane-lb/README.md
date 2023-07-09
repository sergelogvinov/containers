# Kubernetes control plane load balancer

A local host load balancer for a Kubernetes nodes is a haproxy tcp load balancer that helps to kubelet distribute outgoing traffic across multiple instances of Kubernetes control plane. The load balancer listens on a specific network port `127.0.0.1:6443` and forwards incoming requests to the appropriate Kubernetes API server instance.

```yaml
# Talos machine config

machine:
  network:
    extraHostEntries:
      - ip: 127.0.0.1
        aliases:
          - kube-api.example.com
  pods:
    - apiVersion: v1
      kind: Pod
      metadata:
        name: controlplane-lb
        namespace: kube-system
      spec:
        hostNetwork: true
        priorityClassName: system-cluster-critical
        restartPolicy: Always
        securityContext:
          runAsUser: 100
          runAsGroup: 101
        containers:
          - name: contolplane-lb
            image: ghcr.io/sergelogvinov/contolplane-lb:2.6.14
            env:
              - name: controlplane
                value: controlplane.example.com
            resources:
              requests:
                cpu: 50m
                memory: 64Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop: [all]
              seccompProfile:
                type: RuntimeDefault
cluster:
  controlPlane:
    endpoint: https://kube-api.example.com:6443
```
