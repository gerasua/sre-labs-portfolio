# 03 · Pods stuck in `Pending` (`Insufficient cpu`)

> **Spoiler / Aviso:** `POSTMORTEM.md` and `01-break/break.sh` contain the root cause. / `POSTMORTEM.md` y `01-break/break.sh` contienen la causa raíz.

---

## 🇪🇸 Español

### De qué trata
Incidente simulado INC-0003: el despliegue `checkout-api` (3 réplicas) en el namespace `lab03` nunca termina. Dos pods corren y uno se queda en `Pending`. El ejercicio entrena a ubicar en qué etapa se atasca un pod (creación, scheduling o arranque), leer los eventos del scheduler y demostrar la causa con números.

| Campo | Detalle |
|---|---|
| **Nivel** | Fácil-Medio |
| **Herramientas** | Minikube, kubectl, Docker, bash |
| **Recursos** | Un solo clúster Minikube (driver Docker, nodo de 4 CPU asignables) |
| **Tiempo** | 45 a 60 minutos |
| **Falla simulada** | Un pod que el scheduler no logra ubicar |

### Estructura
| Carpeta | Contenido |
|---|---|
| `00-setup/` | `lablog.sh`: función que registra comando, hora y salida |
| `01-break/` | `TICKET.md` (el incidente) y `break.sh` (provoca la falla) |
| `02-troubleshoot/` | Bitácora real: comandos y salidas del diagnóstico, respaldo del Deployment y horas de apertura y cierre |
| `04-verify/` | `verify.sh`: 8 comprobaciones automáticas |
| `99-cleanup/` | `cleanup.sh`: borra el namespace y detiene Minikube |
| `POSTMORTEM.md` | Síntoma, impacto, línea de tiempo, causa raíz, solución, prevención y lecciones |

### Cómo reproducirlo
1. Arranca Minikube: `minikube start`.
2. Carga el helper: `source 00-setup/lablog.sh` y define `export LOG=<archivo>`.
3. Lee `01-break/TICKET.md` y ejecuta `bash 01-break/break.sh`.
4. Diagnostica con `lablog '<comando>'`, sin abrir `break.sh`.
5. Valida con `bash 04-verify/verify.sh` (espera 8 de 8 en PASS).
6. Limpia con `bash 99-cleanup/cleanup.sh`.

**Requisito:** el nodo debe tener 4 CPU asignables. Con un nodo más grande las tres réplicas caben y la falla no se reproduce.

### Habilidades que demuestra
- Triage por etapas: Deployment, ReplicaSet, Pod y scheduler.
- Lectura de eventos (`FailedScheduling`) e identificación de quién los emite.
- Diferencia entre CPU **reservada** (`requests`) y CPU **usada**.
- Cálculo de capacidad asignable frente a reservas por nodo.
- Corrección con `kubectl set resources` y rolling update verificado.
- Script de verificación idempotente que sale con código distinto de cero si algo falla.
- Postmortem sin culpas, con acciones de prevención.

---

## 🇬🇧 English

### What it is about
Simulated incident INC-0003: the `checkout-api` deployment (3 replicas) in the `lab03` namespace never completes. Two pods run and one stays `Pending`. The exercise trains you to locate the stage where a pod gets stuck (creation, scheduling or startup), read the scheduler's events and prove the cause with numbers.

| Field | Detail |
|---|---|
| **Level** | Easy-Medium |
| **Tools** | Minikube, kubectl, Docker, bash |
| **Resources** | A single Minikube cluster (Docker driver, node with 4 allocatable CPUs) |
| **Time** | 45 to 60 minutes |
| **Simulated failure** | A pod the scheduler cannot place |

### Structure
| Folder | Contents |
|---|---|
| `00-setup/` | `lablog.sh`: a function that records the command, time and output |
| `01-break/` | `TICKET.md` (the incident) and `break.sh` (triggers the failure) |
| `02-troubleshoot/` | Real logbook: diagnosis commands and outputs, Deployment backup and opening and closing times |
| `04-verify/` | `verify.sh`: 8 automated checks |
| `99-cleanup/` | `cleanup.sh`: deletes the namespace and stops Minikube |
| `POSTMORTEM.md` | Symptom, impact, timeline, root cause, fix, prevention and lessons |

### How to reproduce it
1. Start Minikube: `minikube start`.
2. Load the helper: `source 00-setup/lablog.sh` and set `export LOG=<file>`.
3. Read `01-break/TICKET.md` and run `bash 01-break/break.sh`.
4. Diagnose with `lablog '<command>'`, without opening `break.sh`.
5. Validate with `bash 04-verify/verify.sh` (expect 8 of 8 PASS).
6. Clean up with `bash 99-cleanup/cleanup.sh`.

**Requirement:** the node must have 4 allocatable CPUs. On a larger node all three replicas fit and the failure does not reproduce.

### Skills it demonstrates
- Stage-by-stage triage: Deployment, ReplicaSet, Pod and scheduler.
- Reading events (`FailedScheduling`) and identifying who emits them.
- The difference between **reserved** CPU (`requests`) and **used** CPU.
- Computing allocatable capacity against per-node reservations.
- Fixing with `kubectl set resources` and a verified rolling update.
- An idempotent verification script that exits non-zero if anything fails.
- Blameless postmortem with prevention actions.
