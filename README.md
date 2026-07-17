# Argo CD SOPS Config Management Plugin

A custom Argo CD Config Management Plugin (CMP) sidecar image that enables decrypting SOPS-encrypted YAML files before applying manifests.

Encrypted files must be named `secret.yaml` or use the `*.secret.yaml` extension.

## Usage

### 1. Create the age key secret

Create a Kubernetes secret containing your age private key:

```bash
kubectl -n argocd create secret generic sops-age-key \
  --from-file=keys.txt=/path/to/age/key.txt
```

### 2. Add the container as a sidecar to the ArgoCD Repo Server

For example, add this to your Helm values:

```yaml
repoServer:
  extraContainers:
    - name: sops
      image: ghcr.io/baconing/argocd-sops-cmp:latest
      securityContext:
        runAsUser: 999
        runAsNonRoot: true
      volumeMounts:
        - name: var-files
          mountPath: /var/run/argocd
        - name: plugins
          mountPath: /home/argocd/cmp-server/plugins
        - name: cmp-tmp
          mountPath: /tmp
        - name: sops-age-key
          mountPath: /keys

  volumes:
    - name: cmp-tmp
      emptyDir: {}
    - name: sops-age-key
      secret:
        secretName: sops-age-key
```