# 01 · Pod that won't start

## 🇪🇸 Español

### Escenario
Un frontend web (`storefront`, nginx) se despliega en Kubernetes y nunca queda disponible: los dos pods entran en `CrashLoopBackOff`. El objetivo es diagnosticar la causa desde el clúster, corregirla y verificar el servicio de punta a punta.

### Qué demuestra este ejercicio
- Diagnóstico metódico de un `CrashLoopBackOff`: estado del pod, logs del contenedor, código de salida y contenido de la configuración montada.
- Distinguir ruido informativo de la causa real en los logs de un contenedor.
- Corregir en la fuente (ConfigMap), validar con `nginx -t` antes de aplicar y forzar un rollout determinista.
- Verificar más allá de `Running`: réplicas listas, cero reinicios, endpoints del Service y respuestas HTTP reales.

### Herramientas
Minikube v1.38.1 (driver Docker, 2 CPUs, 4 GB), kubectl, Docker, Bash.

### Estructura
- `00-setup/`: preparación del entorno (arranque de Minikube, chequeos de salud y prueba de descarga de imágenes). Bitácora en `setup.log`.
- `01-break/`: `storefront.yaml` (manifiestos) y `break.sh` (despliega la app).
- `02-troubleshoot/`: `diagnostico.log`, mi bitácora real de comandos y salidas.
- `04-verify/`: `verify.sh` (siete comprobaciones) y su `verify.log`.
- `99-cleanup/`: `cleanup.sh` (borra el namespace y temporales) y su `cleanup.log`.
- `POSTMORTEM.md`: síntoma, impacto, línea de tiempo, causa raíz, solución, prevención y lecciones.

### Cómo reproducirlo
Requisitos: Docker y Minikube instalados.

    minikube start --driver=docker --cpus=2 --memory=4096
    kubectl create namespace lab01
    bash 01-break/break.sh
    # diagnosticar con kubectl
    bash 04-verify/verify.sh
    bash 99-cleanup/cleanup.sh

### Resultado
Causa raíz: a una directiva `try_files` del `default.conf` (ConfigMap `storefront-conf`) le faltaba el `;` final. nginx rechazaba la configuración y salía con código 1. Detalle en [POSTMORTEM.md](POSTMORTEM.md).

---

## 🇬🇧 English

### Scenario
A web frontend (`storefront`, nginx) is deployed to Kubernetes and never becomes available: both pods go into `CrashLoopBackOff`. The goal is to diagnose the cause from the cluster, fix it and verify the service end to end.

### What this exercise demonstrates
- Methodical diagnosis of a `CrashLoopBackOff`: pod state, container logs, exit code and the contents of the mounted configuration.
- Telling informational noise apart from the real cause in a container's logs.
- Fixing at the source (ConfigMap), validating with `nginx -t` before applying, and forcing a deterministic rollout.
- Verifying beyond `Running`: ready replicas, zero restarts, Service endpoints and real HTTP responses.

### Tools
Minikube v1.38.1 (Docker driver, 2 CPUs, 4 GB), kubectl, Docker, Bash.

### Structure
- `00-setup/`: environment preparation (Minikube start, health checks and image-pull test). Logbook in `setup.log`.
- `01-break/`: `storefront.yaml` (manifests) and `break.sh` (deploys the app).
- `02-troubleshoot/`: `diagnostico.log`, my real logbook of commands and outputs.
- `04-verify/`: `verify.sh` (seven checks) and its `verify.log`.
- `99-cleanup/`: `cleanup.sh` (deletes the namespace and temp files) and its `cleanup.log`.
- `POSTMORTEM.md`: symptom, impact, timeline, root cause, fix, prevention and lessons.

### How to reproduce
Requirements: Docker and Minikube installed.

    minikube start --driver=docker --cpus=2 --memory=4096
    kubectl create namespace lab01
    bash 01-break/break.sh
    # diagnose with kubectl
    bash 04-verify/verify.sh
    bash 99-cleanup/cleanup.sh

### Result
Root cause: a `try_files` directive in `default.conf` (ConfigMap `storefront-conf`) was missing its trailing `;`. nginx rejected the configuration and exited with code 1. Details in [POSTMORTEM.md](POSTMORTEM.md).
