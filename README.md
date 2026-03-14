# universal-chart

A generic, modular Helm chart for deploying **any** application to Kubernetes or OpenShift. Configure everything through `values.yaml` — no app-specific templates needed.

## Structure

```
universal-chart/
├── Chart.yaml
├── values.yaml                  # All options, fully documented with examples
├── values.schema.json           # JSON Schema validation
├── templates/
│   ├── _helpers.tpl             # Name/label/checksum helpers
│   ├── _pod-spec.tpl            # Shared pod spec (DRY across workloads)
│   ├── deployment.yaml          # workload.type: deployment
│   ├── statefulset.yaml         # workload.type: statefulset
│   ├── daemonset.yaml           # workload.type: daemonset
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── route.yaml               # OpenShift Route
│   ├── configmap.yaml           # loops over .Values.configMaps[]
│   ├── secret.yaml              # loops over .Values.secrets[]
│   ├── pvc.yaml                 # loops over .Values.pvc[]
│   ├── pv.yaml                  # loops over .Values.persistentVolumes[]
│   ├── storageclass.yaml        # loops over .Values.storageClasses[]
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   ├── vpa.yaml
│   ├── pdb.yaml
│   ├── networkpolicy.yaml       # loops over .Values.networkPolicies[]
│   ├── rbac.yaml                # Role, RoleBinding, ClusterRole, CRB
│   ├── cronjob.yaml             # loops over .Values.cronjobs[]
│   ├── job.yaml                 # loops over .Values.jobs[]
│   ├── servicemonitor.yaml      # Prometheus ServiceMonitor
│   └── extra-deploy.yaml        # Raw YAML injection via tpl
└── examples/
    ├── simple-webapp.yaml
    ├── full-example.yaml        # Everything-on example (StatefulSet + all features)
    ├── app1-fullstack-webapp.yaml
    ├── app2-postgres-statefulset.yaml
    └── 3-apps-usage.yaml        # 3-app ArgoCD ApplicationSet pattern
```

## Quick Start

```yaml
# values.yaml for your app
image:
  repository: my-registry/myapp
  tag: "1.0.0"

ports:
  - name: http
    containerPort: 8080

service:
  enabled: true
  ports:
    - name: http
      port: 80
      targetPort: http

# Standard Kubernetes Ingress
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

# OR OpenShift Route
# route:
#   enabled: true
#   host: myapp.apps.cluster.example.com
#   tls:
#     termination: edge
```

## Workload Types

Switch between `deployment` (default), `statefulset`, or `daemonset`:

```yaml
workload:
  type: statefulset   # deployment | statefulset | daemonset
```

## Key Features

| Feature | Values Key |
|---|---|
| Sidecar containers | `sidecars[]` |
| Init containers | `initContainers[]` |
| Multiple ConfigMaps | `configMaps[]` |
| Multiple Secrets | `secrets[]` |
| Multiple PVCs | `pvc[]` |
| StatefulSet PVC templates | `volumeClaimTemplates[]` |
| Multiple NetworkPolicies | `networkPolicies[]` |
| CronJobs | `cronjobs[]` |
| One-off Jobs | `jobs[]` |
| RBAC | `rbac.roles[]`, `rbac.clusterRoles[]` |
| HPA | `hpa.enabled: true` |
| VPA | `vpa.enabled: true` |
| PodDisruptionBudget | `pdb.enabled: true` |
| Prometheus scraping | `serviceMonitor.enabled: true` |
| OpenShift Route | `route.enabled: true` |
| Pod anti-affinity | `affinity.podAntiAffinity` |
| Topology spread | `topologySpreadConstraints[]` |
| Auto-restart on CM/Secret change | `checksums.enabled: true` |
| Anything else | `extraDeploy[]` |

## Pod Anti-Affinity (StatefulSet & Deployment)

Spread pods across nodes to avoid single points of failure:

```yaml
affinity:
  podAntiAffinity:
    # Soft rule — prefer different nodes (recommended)
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: myapp
          topologyKey: kubernetes.io/hostname
    # Hard rule — REQUIRE different nodes (can block scheduling if not enough nodes)
    # requiredDuringSchedulingIgnoredDuringExecution:
    #   - labelSelector:
    #       matchLabels:
    #         app.kubernetes.io/name: myapp
    #     topologyKey: kubernetes.io/hostname
```

## Checksums — Opt-in Pod Restart on Config Change

By default pods do **NOT** restart when a ConfigMap or Secret changes. To enable:

```yaml
checksums:
  enabled: true   # adds checksum annotations → rolling restart when CM/Secret changes
```

## extraDeploy — Raw YAML Injection

For anything not covered natively. Supports full Helm templating:

```yaml
extraDeploy:
  - |
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ .Release.Name }}-special
    data:
      my-key: my-value
  - |
    apiVersion: some.crd.io/v1
    kind: CustomResource
    metadata:
      name: {{ .Release.Name }}-cr
    spec:
      anything: goes-here
```

## 3-App ArgoCD Pattern

See [`examples/3-apps-usage.yaml`](examples/3-apps-usage.yaml) for a complete example with:
- **frontend** — Route + env vars
- **backend** — Secrets + ConfigMap + HPA
- **worker** — CronJob + no Service + extraDeploy

Each app has its own `values.yaml` in the gitops `apps` repo. The `ApplicationSet` auto-generates an Argo CD Application per directory.

## Validation

```bash
helm lint charts/universal-chart
helm template test charts/universal-chart                                          # default values
helm template test charts/universal-chart -f examples/full-example.yaml           # full-featured
helm template test charts/universal-chart -f examples/app1-fullstack-webapp.yaml  # deployment
helm template test charts/universal-chart -f examples/app2-postgres-statefulset.yaml  # statefulset
```
