# 02 - Service with no endpoints

## 🇪🇸 Español

**Nivel:** fácil · **Herramientas:** Minikube, kubectl · **Tema:** Kubernetes, red de Services

### Escenario
Una app web está desplegada en el namespace `shop` y sus pods están sanos, pero nada responde en `http://web:80` desde dentro del clúster. Hay que encontrar por qué el tráfico no llega y corregirlo.

### Qué practica
- Seguir la cadena Cliente → Service → Endpoints → Pods para ubicar dónde se corta el tráfico.
- Comparar el selector de un Service contra las etiquetas de los pods.
- Reproducir el síntoma con un pod temporal dentro del clúster.
- Corregir con el menor radio de impacto y validar con un script repetible.

### Estructura
| Carpeta | Contenido |
|---|---|
| `00-setup/` | Bitácora de la preparación y verificación del clúster. |
| `01-break/` | `break.sh` (provoca la falla) y su log. |
| `02-troubleshoot/` | Mi bitácora real de diagnóstico y el respaldo del Service antes del cambio. |
| `04-verify/` | `verify.sh` (7 chequeos con código de salida) y su log. |
| `99-cleanup/` | `cleanup.sh` (elimina el namespace) y su log. |
| `POSTMORTEM.md` | Postmortem en español e inglés. |

> **Ticket y bitácora:** el ticket del incidente está en [`01-break/TICKET.md`](01-break/TICKET.md) y el helper `lablog`, que registra cada comando con su salida, está en [`00-setup/lablog.sh`](00-setup/lablog.sh).

### Cómo reproducirlo
Requiere Minikube corriendo y `kubectl` apuntando a él.
```bash
./01-break/break.sh      # provoca la falla
# diagnostica con kubectl...
./04-verify/verify.sh    # valida la corrección
./99-cleanup/cleanup.sh  # limpia
```

### Resultado
Causa raíz: el selector del Service no coincidía con las etiquetas de los pods, por lo que la lista de endpoints quedó vacía. Detalle completo en [POSTMORTEM.md](POSTMORTEM.md).

## 🇬🇧 English

**Level:** easy · **Tools:** Minikube, kubectl · **Topic:** Kubernetes, Service networking

### Scenario
A web app is deployed in namespace `shop` and its pods are healthy, but nothing answers at `http://web:80` from inside the cluster. The goal is to find out why traffic doesn't arrive and fix it.

### What it practices
- Following the chain Client → Service → Endpoints → Pods to locate where traffic breaks.
- Comparing a Service's selector against the pods' labels.
- Reproducing the symptom with a temporary pod inside the cluster.
- Fixing with the smallest blast radius and validating with a repeatable script.

### Structure
| Folder | Contents |
|---|---|
| `00-setup/` | Log of the cluster preparation and checks. |
| `01-break/` | `break.sh` (triggers the failure) and its log. |
| `02-troubleshoot/` | My real diagnosis logbook and the Service backup taken before the change. |
| `04-verify/` | `verify.sh` (7 checks with an exit code) and its log. |
| `99-cleanup/` | `cleanup.sh` (deletes the namespace) and its log. |
| `POSTMORTEM.md` | Postmortem in Spanish and English. |

> **Ticket and logging helper:** the incident ticket is in [`01-break/TICKET.md`](01-break/TICKET.md) and the `lablog` helper, which records each command with its output, is in [`00-setup/lablog.sh`](00-setup/lablog.sh).

### How to reproduce
Requires a running Minikube and `kubectl` pointing at it.
```bash
./01-break/break.sh      # triggers the failure
# diagnose with kubectl...
./04-verify/verify.sh    # validates the fix
./99-cleanup/cleanup.sh  # cleans up
```

### Outcome
Root cause: the Service's selector didn't match the pods' labels, so the endpoints list was empty. Full details in [POSTMORTEM.md](POSTMORTEM.md).
