# SRE Labs Portfolio

## 🇪🇸 Español
Ejercicios prácticos de troubleshooting y automatización SRE con fallas simuladas, 100 % locales (sin nube real ni costos): Kubernetes + ArgoCD, CI/CD y Terraform + Atlantis. Cada ejercicio incluye su preparación, el script que provoca la falla, mi bitácora real de diagnóstico, la verificación, la limpieza y un postmortem.

### Índice de ejercicios
| # | Ejercicio | Tema | Estado |
|---|-----------|------|--------|
| 01 | [Pod that won't start](01-pod-wont-start/) | Kubernetes: `CrashLoopBackOff` por un error de configuración en un ConfigMap | ✅ Completado |
| 02 | [Service with no endpoints](02-service-no-endpoints/) | Kubernetes: Service sin endpoints porque su selector no coincide con las etiquetas de los pods | ✅ Completado |
| 03 | [Pods stuck in Pending](03-pods-stuck-pending/) | Kubernetes: pod en Pending porque los `requests` de CPU no caben en el nodo | ✅ Completado |

### Cómo está organizado cada laboratorio
Todos siguen la misma estructura, para que se puedan reproducir y revisar de la misma forma:

    NN-nombre-del-ejercicio/
    ├── README.md          escenario, objetivo y cómo reproducirlo (ES y EN)
    ├── 00-setup/          preparación del entorno y verificación de requisitos
    ├── 01-break/          scripts que provocan la falla
    ├── 02-troubleshoot/   mi bitácora real: comandos y salidas del diagnóstico
    ├── 04-verify/         validación de que quedó arreglado
    ├── 99-cleanup/        apagado y limpieza del entorno
    └── POSTMORTEM.md      síntoma, impacto, línea de tiempo, causa raíz, solución, prevención y lecciones

### Habilidades demostradas
| Habilidad | Ejercicios |
|-----------|------------|
| Diagnóstico de `CrashLoopBackOff` (estado, logs, código de salida) | 01 |
| Gestión de ConfigMaps y rollouts en Kubernetes | 01 |
| Validación de configuración antes de desplegar (`nginx -t`) | 01 |
| Scripts Bash seguros (guardia de contexto, idempotencia, códigos de salida) | 01, 02 |
| Verificación de punta a punta y redacción de postmortems | 01, 02, 03 |
| Diagnóstico de Services sin endpoints (selector vs. etiquetas de pods) | 02 |
| Pruebas de conectividad desde dentro del clúster con un pod temporal | 02 |
| Triage por etapas (Deployment, ReplicaSet, Pod) y lectura de eventos del scheduler | 03 |
| Capacidad asignable frente a reservas: `requests`, `limits` y CPU por nodo | 03 |
| Ajuste de recursos con `kubectl set resources` y rolling update verificado | 03 |

### Roadmap
Ejercicios planeados; el orden puede cambiar.

| # | Ejercicio | Enfoque |
|---|-----------|---------|
| 04 | Intermittent restarts | Kubernetes: límites de memoria y sondas de salud |
| 05 | GitOps drift | ArgoCD: aplicación `OutOfSync` |
| 06 | ArgoCD won't sync | ArgoCD + Gitea: acceso al repositorio y hooks |
| 07 | Pipeline never runs | Gitea Actions: runner y etiquetas |
| 08 | Terraform stuck on the PR | Terraform + Atlantis + LocalEmu: bloqueo de estado y deriva |
| 09 | AI-assisted incident triage | Claude Code: diagnóstico y automatización de runbooks |
| 10 | Cluster cascade | Kubernetes + ArgoCD: presión de nodo y app-of-apps |

## 🇬🇧 English
Hands-on SRE troubleshooting and automation exercises with simulated failures, 100% local (no real cloud, no costs): Kubernetes + ArgoCD, CI/CD, and Terraform + Atlantis. Each exercise includes its setup, the script that triggers the failure, my real diagnosis logbook, verification, cleanup and a postmortem.

### Exercise index
| # | Exercise | Topic | Status |
|---|----------|-------|--------|
| 01 | [Pod that won't start](01-pod-wont-start/) | Kubernetes: `CrashLoopBackOff` caused by a configuration error in a ConfigMap | ✅ Completed |
| 02 | [Service with no endpoints](02-service-no-endpoints/) | Kubernetes: Service with no endpoints because its selector doesn't match the pods' labels | ✅ Completed |
| 03 | [Pods stuck in Pending](03-pods-stuck-pending/) | Kubernetes: pod stuck in Pending because its CPU `requests` don't fit on the node | ✅ Completed |

### How each lab is organized
All labs follow the same structure, so they can be reproduced and reviewed the same way:

    NN-exercise-name/
    ├── README.md          scenario, goal and how to reproduce it (ES and EN)
    ├── 00-setup/          environment preparation and prerequisite checks
    ├── 01-break/          scripts that trigger the failure
    ├── 02-troubleshoot/   my real logbook: diagnosis commands and outputs
    ├── 04-verify/         validation that the fix worked
    ├── 99-cleanup/        shutdown and environment cleanup
    └── POSTMORTEM.md      symptom, impact, timeline, root cause, fix, prevention and lessons

### Skills demonstrated
| Skill | Exercises |
|-------|-----------|
| `CrashLoopBackOff` diagnosis (state, logs, exit code) | 01 |
| ConfigMap and rollout management in Kubernetes | 01 |
| Configuration validation before deploying (`nginx -t`) | 01 |
| Safe Bash scripting (context guard, idempotency, exit codes) | 01, 02 |
| End-to-end verification and postmortem writing | 01, 02, 03 |
| Diagnosing Services with no endpoints (selector vs. pod labels) | 02 |
| In-cluster connectivity tests with a temporary pod | 02 |
| Stage-by-stage triage (Deployment, ReplicaSet, Pod) and scheduler event reading | 03 |
| Allocatable capacity versus reservations: `requests`, `limits` and CPU per node | 03 |
| Resource right-sizing with `kubectl set resources` and a verified rolling update | 03 |

### Roadmap
Planned exercises; the order may change.

| # | Exercise | Focus |
|---|----------|-------|
| 04 | Intermittent restarts | Kubernetes: memory limits and health probes |
| 05 | GitOps drift | ArgoCD: `OutOfSync` application |
| 06 | ArgoCD won't sync | ArgoCD + Gitea: repository access and hooks |
| 07 | Pipeline never runs | Gitea Actions: runner and labels |
| 08 | Terraform stuck on the PR | Terraform + Atlantis + LocalEmu: state lock and drift |
| 09 | AI-assisted incident triage | Claude Code: diagnosis and runbook automation |
| 10 | Cluster cascade | Kubernetes + ArgoCD: node pressure and app-of-apps |

## License
MIT — see [LICENSE](LICENSE).
