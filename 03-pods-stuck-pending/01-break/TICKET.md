# INC-0003 · Deployment never completes / El despliegue nunca termina

| Field / Campo | Value / Valor |
|---|---|
| **Priority / Prioridad** | P2 |
| **Reported by / Reportó** | Marta Ríos, QA Lead (Storefront) |
| **Environment / Ambiente** | Minikube, namespace `lab03` |
| **Service / Servicio** | `checkout-api` |

## 🇪🇸 Descripción
Desplegamos `checkout-api` con 3 réplicas en el namespace `lab03`, pero el despliegue nunca termina. `kubectl rollout status` se queda esperando y no podemos dar el visto bueno de QA. No hemos cambiado nada en el clúster, solo aplicamos el manifiesto.

**Impacto:** el release está bloqueado y el servicio no tiene toda la capacidad esperada.

## 🇬🇧 Description
We deployed `checkout-api` with 3 replicas in the `lab03` namespace, but the deployment never completes. `kubectl rollout status` hangs and we can't sign off on QA. We changed nothing in the cluster, we only applied the manifest.

**Impact:** the release is blocked and the service doesn't have its expected capacity.
