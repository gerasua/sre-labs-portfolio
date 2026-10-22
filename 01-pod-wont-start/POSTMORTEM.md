# Postmortem: storefront in CrashLoopBackOff

## 🇪🇸 Español

### Resumen
En el laboratorio desplegué `storefront`, un frontend web con nginx, en el namespace `lab01` de Minikube. Los dos pods nunca llegaron a estar listos y entraron en `CrashLoopBackOff`. La causa fue un error de sintaxis en la configuración de nginx: le faltaba un `;` a una directiva. Lo corregí en el ConfigMap, lo validé con `nginx -t` y reinicié el despliegue.

### Síntoma
El `rollout status` venció a los 45 segundos con `0 of 2 updated replicas are available`, y `kubectl get pods` mostraba los dos pods en `0/1 CrashLoopBackOff`, con reinicios acumulándose.

### Impacto
El servicio estuvo totalmente no disponible durante unos 58 minutos: ninguna de las dos réplicas llegó a estar lista, así que el Service no tuvo endpoints. Al ser el primer despliegue, no había una versión anterior sana que siguiera atendiendo. Uno de los pods acumuló 16 reinicios.

### Línea de tiempo (22 oct 2026, hora local)
- **13:43** Desplegué la aplicación con `break.sh`; se crearon el ConfigMap, el Deployment y el Service.
- **13:44** El rollout venció y los dos pods estaban en `CrashLoopBackOff`.
- **~14:15** Revisé los logs del contenedor: nginx reportaba `[emerg] unexpected "}" in /etc/nginx/conf.d/default.conf:8` y el código de salida del contenedor era `1`. Me detuve un momento en una línea sobre un sistema de archivos de solo lectura, pero es un aviso informativo del script de arranque de la imagen, que termina diciendo `Configuration complete; ready for start up`. La causa estaba en el `[emerg]`.
- **~14:28** Leí el ConfigMap `storefront-conf` con números de línea y confirmé que ese era el archivo que nginx rechazaba.
- **~14:34** Formulé la hipótesis: falta un `;` al final de la línea 7 (`try_files`), y nginx lo reporta en la línea 8 porque ahí se topa con el `}`.
- **14:36** Respaldé el ConfigMap antes de tocarlo.
- **14:39** Corregí una copia local; el `diff` fue de una sola línea. Con el archivo original, `nginx -t` en mi host reprodujo el mismo error, y con el corregido pasó.
- **~14:41** Apliqué el ConfigMap corregido y ejecuté `rollout restart`; el despliegue completó con dos pods nuevos en `1/1 Running` y cero reinicios.
- **14:52** `verify.sh` pasó las siete comprobaciones.
- **14:56** Limpieza del laboratorio.

### Causa raíz
La directiva `try_files $uri $uri/ =404` del `default.conf` no terminaba en `;`. En nginx, el punto y coma delimita cada directiva, así que el parser siguió esperando argumentos y, al leer la siguiente línea, encontró un `}` donde no cabía. Por eso el error aparece en la línea 8 aunque el defecto está en la 7. nginx abortaba al validar la configuración, el proceso salía con código 1 y el kubelet lo reiniciaba una y otra vez con esperas crecientes. La configuración llega al contenedor desde un ConfigMap, y nadie la validó antes de desplegar.

### Solución
1. Respaldé el ConfigMap con `kubectl get ... -o yaml`.
2. Extraje `default.conf`, lo copié y agregué el `;` con `sed`, revisando el cambio con `diff -u`.
3. Validé el original (falla) y el corregido (pasa) con `nginx -t` en un contenedor desechable.
4. Actualicé el ConfigMap con `create --dry-run=client -o yaml | apply -f -`.
5. Ejecuté `rollout restart` para que los pods nuevos arrancaran con la configuración corregida. Corregir el ConfigMap no basta: el volumen se sincroniza con retraso y nginx lee su configuración solo al arrancar.
6. Verifiqué con `verify.sh`: despliegue completo, 2 réplicas listas, cero reinicios, 2 endpoints, `nginx -t` dentro del pod y respuestas HTTP 200.

### Prevención
- Validar la configuración con `nginx -t` en CI antes de fusionar o desplegar el cambio.
- Mantener los manifiestos en Git como fuente de verdad y desplegar por pipeline, en lugar de parchar en vivo.
- Anotar en la plantilla del pod un hash del ConfigMap (Helm o Kustomize lo hacen) para que un cambio de configuración provoque el rollout solo.
- Alertar por pods en `CrashLoopBackOff` y por reinicios de contenedor, no solo por pods caídos.
- En servicios ya sanos, apoyarse en `RollingUpdate` y en la `readinessProbe` para que una versión defectuosa no reciba tráfico ni reemplace a las réplicas buenas.

### Lecciones
- Un error se señala donde el parser se da cuenta, no donde nació: la línea 8 era el síntoma y la 7 la causa.
- En un `CrashLoopBackOff`, primero el código de salida y los logs del contenedor; hay que separar el ruido informativo de la línea que realmente detiene el proceso.
- Reproducir la falla fuera del clúster con `nginx -t` es la forma más limpia de confirmar una causa raíz.
- Corregir un ConfigMap no reinicia nada: hay que forzar el rollout.
- `Running` no es "arreglado": hay que comprobar reinicios, endpoints y respuestas reales.

---

## 🇬🇧 English

### Summary
In the lab I deployed `storefront`, an nginx web frontend, to the `lab01` namespace on Minikube. Neither pod ever became ready, and both went into `CrashLoopBackOff`. The cause was a syntax error in the nginx configuration: a directive was missing its `;`. I fixed it in the ConfigMap, validated it with `nginx -t` and restarted the deployment.

### Symptom
`rollout status` timed out after 45 seconds with `0 of 2 updated replicas are available`, and `kubectl get pods` showed both pods at `0/1 CrashLoopBackOff` with restarts piling up.

### Impact
The service was completely unavailable for about 58 minutes: neither replica ever became ready, so the Service had no endpoints. Since this was the first deployment, there was no healthy previous version still serving. One of the pods accumulated 16 restarts.

### Timeline (22 Oct 2026, local time)
- **13:43** I deployed the application with `break.sh`; the ConfigMap, Deployment and Service were created.
- **13:44** The rollout timed out and both pods were in `CrashLoopBackOff`.
- **~14:15** I checked the container logs: nginx reported `[emerg] unexpected "}" in /etc/nginx/conf.d/default.conf:8` and the container's exit code was `1`. I paused briefly on a line about a read-only file system, but it's an informational notice from the image's startup script, which ends with `Configuration complete; ready for start up`. The cause was in the `[emerg]` line.
- **~14:28** I read the `storefront-conf` ConfigMap with line numbers and confirmed it was the file nginx was rejecting.
- **~14:34** I formed the hypothesis: a `;` is missing at the end of line 7 (`try_files`), and nginx reports line 8 because that's where it runs into the `}`.
- **14:36** I backed up the ConfigMap before touching it.
- **14:39** I fixed a local copy; the `diff` was a single line. With the original file, `nginx -t` on my host reproduced the same error, and with the fixed one it passed.
- **~14:41** I applied the corrected ConfigMap and ran `rollout restart`; the deployment completed with two new pods at `1/1 Running` and zero restarts.
- **14:52** `verify.sh` passed all seven checks.
- **14:56** Lab cleanup.

### Root cause
The `try_files $uri $uri/ =404` directive in `default.conf` didn't end with `;`. In nginx the semicolon delimits each directive, so the parser kept waiting for arguments and, reading the next line, found a `}` where it didn't fit. That's why the error shows up on line 8 even though the defect is on line 7. nginx aborted while validating the configuration, the process exited with code 1, and the kubelet kept restarting it with growing back-off. The configuration reaches the container from a ConfigMap, and nobody validated it before deploying.

### Fix
1. I backed up the ConfigMap with `kubectl get ... -o yaml`.
2. I extracted `default.conf`, copied it and added the `;` with `sed`, reviewing the change with `diff -u`.
3. I validated the original (fails) and the fixed one (passes) with `nginx -t` in a throwaway container.
4. I updated the ConfigMap with `create --dry-run=client -o yaml | apply -f -`.
5. I ran `rollout restart` so the new pods started with the corrected configuration. Fixing the ConfigMap isn't enough: the volume syncs with a delay and nginx reads its configuration only at startup.
6. I verified with `verify.sh`: complete rollout, 2 ready replicas, zero restarts, 2 endpoints, `nginx -t` inside the pod and HTTP 200 responses.

### Prevention
- Validate the configuration with `nginx -t` in CI before merging or deploying the change.
- Keep manifests in Git as the source of truth and deploy through a pipeline instead of patching live.
- Annotate the pod template with a ConfigMap hash (Helm or Kustomize do this) so a configuration change triggers the rollout by itself.
- Alert on pods in `CrashLoopBackOff` and on container restarts, not just on pods being down.
- On already-healthy services, rely on `RollingUpdate` and the `readinessProbe` so a faulty version neither receives traffic nor replaces the good replicas.

### Lessons
- An error is flagged where the parser notices it, not where it started: line 8 was the symptom and line 7 the cause.
- In a `CrashLoopBackOff`, start with the exit code and the container logs; separate informational noise from the line that actually stops the process.
- Reproducing the failure outside the cluster with `nginx -t` is the cleanest way to confirm a root cause.
- Fixing a ConfigMap restarts nothing: you have to force the rollout.
- `Running` doesn't mean "fixed": check restarts, endpoints and real responses.
