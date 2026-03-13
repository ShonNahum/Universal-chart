# universal-chart

A generic, modular Helm chart for deploying **any** application. Configure everything through `values.yaml` — no app-specific templates needed.

## Structure

```
universal-chart/
├── Chart.yaml
├── values.yaml                  # All options, fully documented
├── templates/
│   ├── _helpers.tpl             # Name/label helpers
│   ├── _pod-spec.tpl            # Shared pod spec (DRY)
│   ├── deployment.yaml          # workload.type: deployment
│   ├── statefulset.yaml         # workload.type: statefulset
│   ├── daemonset.yaml           # workload.type: daemonset
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── route.yaml               # OpenShift Route
│   ├── configmap.yaml           # loops over .Values.configMaps[]
│   ├── secret.yaml              # loops over .Values.secrets[]
│   ├── pvc.yaml                 # loops over .Values.pvc[]
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   ├── pdb.yaml
│   ├── networkpolicy.yaml       # loops over .Values.networkPolicies[]
│   ├── rbac.yaml                # Role, RoleBinding, ClusterRole, CRB
│   ├── cronjob.yaml             # loops over .Values.cronjobs[]
│   ├── job.yaml                 # loops over .Values.jobs[]
│   ├── servicemonitor.yaml      # Prometheus ServiceMonitor
│   └── extra-deploy.yaml        # Raw YAML injection via tpl
└── examples/
    ├── simple-webapp.yaml
    ├── full-example.yaml
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

# OpenShift Route
route:
  enabled: true
  host: myapp.apps.cluster.example.com
  tls:
    termination: edge

# OR standard Ingress
ingress:
  enabled: false
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
| Sidecar containers | `extraContainers[]` |
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
| PodDisruptionBudget | `pdb.enabled: true` |
| Prometheus scraping | `serviceMonitor.enabled: true` |
| OpenShift Route | `route.enabled: true` |
| Anything else | `extraDeploy[]` |

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
