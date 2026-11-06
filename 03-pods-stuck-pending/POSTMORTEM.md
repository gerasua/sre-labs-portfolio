# Postmortem INC-0003: `checkout-api` stuck at 2/3 replicas (Pod `Pending`, `Insufficient cpu`)

---

## 🇪🇸 Español

### Resumen
El despliegue de `checkout-api` en `lab03` nunca llegó a 3/3 réplicas. Un pod se quedó en `Pending` porque el scheduler no encontró ningún nodo con CPU reservable suficiente. La causa fue un `requests.cpu` de 1500m por réplica, mal calibrado para un nodo de 4 CPU. Lo corregí ajustando las reservas y el despliegue quedó sano.

### Síntoma
QA reportó que el despliegue no terminaba: `kubectl rollout status` se quedaba esperando. Al revisar, el Deployment mostraba `2/3`, dos pods en `Running` y uno en `Pending` con `Node: <none>` y sin IP. No había `CrashLoopBackOff` ni `ImagePullBackOff`: el pod nunca llegó a un nodo.

### Impacto
- El servicio operó con 2 de 3 réplicas (aprox. 67 % de la capacidad prevista).
- El release quedó bloqueado durante unos 23 min 37 s.
- Sin pérdida de datos. Ambiente de laboratorio, prioridad P2.

### Línea de tiempo (hora local, UTC-6, 5 de noviembre de 2026)
| Hora | Evento |
|---|---|
| 20:18:29 | Se abre el ticket INC-0003 y se aplica el Deployment |
| 20:25:16 | Reviso los pods: dos `Running`, uno `Pending` sin nodo |
| 20:31:44 | Leo la cadena Deployment → ReplicaSet → Pods y los eventos del pod pendiente: `default-scheduler` reporta `FailedScheduling: 0/1 nodes are available: 1 Insufficient cpu` |
| 20:40:25 | Contrasto el mensaje con números: 3750m (93 %) reservados de 4000m asignables. Guardo una copia del Deployment antes de tocarlo |
| 20:42:01 | Cambio `requests.cpu` a 100m y `limits.cpu` a 500m |
| 20:42:06 | El rollout termina: 3/3 |
| 20:43:49 | `verify.sh`: 8 de 8 comprobaciones en PASS |
| 21:08 | Limpieza del laboratorio y apagado de Minikube |

### Causa raíz
Cada réplica declaraba `requests.cpu: 1500m`. Con 3 réplicas, el Deployment pedía 4500m en un nodo con 4000m asignables, así que no cabía ni con el nodo vacío. Además, los pods de `kube-system` ya reservaban 750m. Con dos réplicas corriendo (3000m) quedaban solo 250m libres frente a los 1500m que pedía la tercera.

Dos aclaraciones que me sirvieron:
- El scheduler decide con **reservas** (`requests`), no con consumo real. El nodo estaba casi ocioso (cerca de 0.3 CPU usados) y aun así lleno para el scheduler (93 % reservado).
- La memoria no era el problema: solo 2 % reservado. El mensaje lo decía (`Insufficient cpu`).

### Solución
Redimensioné las reservas del contenedor `api` con `kubectl set resources`: `requests.cpu` a 100m y `limits.cpu` a 500m. El cambio modifica la plantilla del pod, por lo que el Deployment hizo un rolling update. Los pods nuevos pesan 100m y caben holgadamente.

No bajé las réplicas porque habría quitado capacidad al servicio, y no era posible ampliar la CPU del nodo. Antes del cambio guardé el YAML original como punto de retorno. Las cifras de 100m y 500m son valores de laboratorio. En un servicio real los calibraría con métricas de uso.

### Prevención
- Definir un `LimitRange` por namespace con valores por defecto y máximos de `requests` y `limits`.
- Aplicar una `ResourceQuota` por equipo o namespace.
- Calibrar `requests` con datos reales (percentil 90 o 95 de uso, y recomendaciones del VPA en modo consultivo), no por intuición.
- Alertar cuando un pod pase más de unos minutos en `Pending`, y cuando la CPU reservada por nodo supere un umbral (por ejemplo, 85 %).
- Validar el manifiesto antes del merge con una política (kube-linter, Kyverno u OPA) que rechace `requests` fuera de rango.
- Hacer los cambios desde Git y el pipeline, no con `kubectl set` en el clúster, para no generar drift.

### Lecciones
- El síntoma "no termina el despliegue" tiene tres etapas posibles (creación, scheduling, arranque). Ubicar la etapa acota la búsqueda: aquí fue el scheduler.
- Los **eventos** y la columna `From` dicen quién habla. Aquí hablaba `default-scheduler`, no el kubelet.
- Un mensaje no es una prueba. Lo confirmé con la suma de reservas contra `Allocatable`.
- Reservado no es lo mismo que usado. Un clúster ocioso puede estar lleno para el scheduler.
- Antes de cambiar nada, guardo el estado actual. Y al cambiar recursos en un nodo casi lleno, verifico que el pod nuevo quepa mientras conviven el ReplicaSet viejo y el nuevo.
- En este caso me enteré por el reporte de QA, no por una alerta. Falta monitoreo de pods `Pending`.

---

## 🇬🇧 English

### Summary
The `checkout-api` deployment in `lab03` never reached 3/3 replicas. One pod stayed `Pending` because the scheduler found no node with enough reservable CPU. The cause was a `requests.cpu` of 1500m per replica, badly sized for a 4-CPU node. I fixed it by adjusting the reservations, and the deployment became healthy.

### Symptom
QA reported that the deployment never finished: `kubectl rollout status` kept waiting. On inspection, the Deployment showed `2/3`, with two pods `Running` and one `Pending` with `Node: <none>` and no IP. There was no `CrashLoopBackOff` or `ImagePullBackOff`: the pod never reached a node.

### Impact
- The service ran with 2 of 3 replicas (about 67% of the intended capacity).
- The release was blocked for about 23 min 37 s.
- No data loss. Lab environment, priority P2.

### Timeline (local time, UTC-6, November 5, 2026)
| Time | Event |
|---|---|
| 20:18:29 | Ticket INC-0003 opened and the Deployment applied |
| 20:25:16 | I inspect the pods: two `Running`, one `Pending` with no node |
| 20:31:44 | I read the Deployment → ReplicaSet → Pods chain and the pending pod's events: `default-scheduler` reports `FailedScheduling: 0/1 nodes are available: 1 Insufficient cpu` |
| 20:40:25 | I check the message against numbers: 3750m (93%) reserved out of 4000m allocatable. I save a copy of the Deployment before touching it |
| 20:42:01 | I change `requests.cpu` to 100m and `limits.cpu` to 500m |
| 20:42:06 | The rollout completes: 3/3 |
| 20:43:49 | `verify.sh`: 8 of 8 checks PASS |
| 21:08 | Lab cleanup and Minikube shutdown |

### Root cause
Each replica declared `requests.cpu: 1500m`. With 3 replicas, the Deployment asked for 4500m on a node with 4000m allocatable, so it wouldn't fit even on an empty node. On top of that, the `kube-system` pods already reserved 750m. With two replicas running (3000m), only 250m was left against the 1500m the third one needed.

Two clarifications that helped me:
- The scheduler decides with **reservations** (`requests`), not real usage. The node was nearly idle (about 0.3 CPU used) and still full to the scheduler (93% reserved).
- Memory wasn't the problem: only 2% reserved. The message said so (`Insufficient cpu`).

### Fix
I resized the `api` container's reservations with `kubectl set resources`: `requests.cpu` to 100m and `limits.cpu` to 500m. The change modifies the pod template, so the Deployment did a rolling update. The new pods weigh 100m and fit comfortably.

I didn't scale down the replicas because that would have removed capacity from the service, and adding CPU to the node wasn't possible. Before the change I saved the original YAML as a way back. The 100m and 500m figures are lab values. For a real service I would calibrate them with usage metrics.

### Prevention
- Define a `LimitRange` per namespace with defaults and maximums for `requests` and `limits`.
- Apply a `ResourceQuota` per team or namespace.
- Size `requests` with real data (90th or 95th percentile of usage, and VPA recommendations in advisory mode), not by gut feeling.
- Alert when a pod stays `Pending` for more than a few minutes, and when CPU reserved per node passes a threshold (for example, 85%).
- Validate the manifest before merge with a policy (kube-linter, Kyverno or OPA) that rejects out-of-range `requests`.
- Make changes through Git and the pipeline, not with `kubectl set` on the cluster, to avoid drift.

### Lessons
- The symptom "the deployment never finishes" has three possible stages (creation, scheduling, startup). Locating the stage narrows the search: here it was the scheduler.
- **Events** and the `From` column tell you who is speaking. Here it was `default-scheduler`, not the kubelet.
- A message is not proof. I confirmed it by adding up the reservations against `Allocatable`.
- Reserved is not the same as used. An idle cluster can be full to the scheduler.
- Before changing anything, I save the current state. And when changing resources on a nearly full node, I check that the new pod fits while the old and new ReplicaSets coexist.
- I learned of this from QA's report, not from an alert. Monitoring for `Pending` pods is missing.
