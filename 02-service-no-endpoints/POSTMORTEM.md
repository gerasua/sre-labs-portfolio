# Postmortem: Service sin endpoints / Service with no endpoints

## 🇪🇸 Español

### Resumen
La app `web` del namespace `shop` estaba desplegada y sus dos pods se veían sanos, pero nada respondía en `http://web`. La causa fue un desajuste entre el selector del Service y las etiquetas de los pods. Lo corregí en el Service, sin tocar ni reiniciar los pods.

### Síntoma
El equipo de la tienda reportó que la app "estaba desplegada pero no contestaba". Los pods estaban en `1/1 Running`, sin reinicios. Desde dentro del clúster, `wget http://web` terminaba con `Connection refused` contra la IP del Service.

### Impacto
Todo el tráfico que pasaba por el Service `web` se rechazaba. Como los pods estaban sanos, ninguna señal a nivel de pod avisaba del problema; solo se notaba desde el cliente. Esto ocurrió en un laboratorio local, pero en producción habría sido una caída total de la app para quien dependiera de ese Service.

### Línea de tiempo (hora local, 29-oct-2026)
- **13:25** Despliegue de la app: Deployment `web` con 2 réplicas y Service `web`. Se abre el ticket: nada responde en `http://web`.
- **13:26** Segunda ejecución del aprovisionamiento; es idempotente y no cambió nada.
- **13:44** Empiezo a investigar. `kubectl get endpoints web` devuelve `<none>`. El selector del Service es `app=web-app` y los pods tienen `app=web`.
- **13:51** Reproduzco el síntoma desde un pod temporal dentro del clúster: `Connection refused` contra la ClusterIP.
- **13:56** Guardo el YAML del Service antes de tocarlo.
- **13:58** Cambio el selector con `kubectl set selector svc web app=web`. Los endpoints pasan a ser las IP de los dos pods y la misma prueba ahora devuelve la página de nginx.
- **14:01** Corro `verify.sh`: 7 de 7 chequeos en verde.
- **14:03** Limpieza del namespace con `cleanup.sh`.

Del primer comando de diagnóstico a la corrección pasaron unos 14 minutos.

### Causa raíz
El Service `web` tenía `selector: app=web-app`, pero el Deployment crea pods con la etiqueta `app=web`. Un Service solo adopta pods cuyas etiquetas cumplen todo su selector. Al no coincidir ninguno, la lista de endpoints quedó vacía y `kube-proxy` rechazó el tráfico de inmediato. Fue un simple error de escritura, y nada en el despliegue lo señalaba como error: Kubernetes acepta un selector que no selecciona nada.

### Solución
Corregí el selector del Service a `app=web`. Elegí cambiar el Service y no los pods porque (1) los pods eran coherentes con su propio Deployment, (2) cambiar sus etiquetas habría exigido modificar la plantilla del Deployment, con un rollout que reinicia pods sanos (y el `selector` del Deployment es inmutable), y (3) otras piezas pueden depender de `app=web`. Tocar el Service tenía el radio de impacto más pequeño. Antes del cambio guardé el estado previo en `svc-web-before.yaml`.

### Prevención
- Alertar cuando un Service tenga cero endpoints disponibles (por ejemplo, con las métricas de kube-state-metrics).
- Incluir una prueba de humo después de cada despliegue que haga una petición real al Service.
- Definir las etiquetas en un solo lugar (kustomize o Helm) para que Service y Deployment no puedan divergir por un error de dedo.
- Revisar en el pull request que el selector del Service coincida con las etiquetas de la plantilla del Deployment. `verify.sh` ya incluye ese chequeo.
- En un entorno GitOps, corregir el manifiesto en Git y dejar que la herramienta sincronice, en vez de parchear a mano el clúster.

### Lecciones
- Un pod en `Running` no significa que reciba tráfico. La pregunta correcta es si el Service lo tiene en sus endpoints.
- Ante "el Service no responde pero los pods están bien", `kubectl get endpoints` es el primer comando: separa en segundos un problema de selección de uno de red o de aplicación.
- `Connection refused` inmediato apunta a un Service sin destinos; un timeout apunta más bien a firewall, NetworkPolicy o pods que no contestan.
- Guardar el estado previo antes de tocar un recurso vivo cuesta un comando y permite revertir en segundos.
- Verifico con una prueba de extremo a extremo, no solo mirando que el recurso "se vea bien".

## 🇬🇧 English

### Summary
The `web` app in namespace `shop` was deployed and its two pods looked healthy, but nothing answered at `http://web`. The cause was a mismatch between the Service's selector and the pods' labels. I fixed it on the Service, without touching or restarting the pods.

### Symptom
The storefront team reported the app was "deployed but not answering". The pods were `1/1 Running` with no restarts. From inside the cluster, `wget http://web` ended with `Connection refused` against the Service IP.

### Impact
All traffic going through the `web` Service was rejected. Because the pods were healthy, no pod-level signal flagged the problem; it was only visible from the client side. This happened in a local lab, but in production it would have been a total outage of the app for anyone depending on that Service.

### Timeline (local time, 29 Oct 2026)
- **13:25** App deployed: Deployment `web` with 2 replicas and Service `web`. Ticket opened: nothing answers at `http://web`.
- **13:26** Provisioning ran a second time; it is idempotent and changed nothing.
- **13:44** I start investigating. `kubectl get endpoints web` returns `<none>`. The Service selector is `app=web-app` and the pods carry `app=web`.
- **13:51** I reproduce the symptom from a temporary pod inside the cluster: `Connection refused` against the ClusterIP.
- **13:56** I save the Service YAML before touching it.
- **13:58** I change the selector with `kubectl set selector svc web app=web`. The endpoints become the two pods' IPs and the same test now returns the nginx page.
- **14:01** I run `verify.sh`: 7 of 7 checks green.
- **14:03** Namespace cleanup with `cleanup.sh`.

From the first diagnostic command to the fix, about 14 minutes passed.

### Root cause
The `web` Service had `selector: app=web-app`, but the Deployment creates pods labeled `app=web`. A Service only adopts pods whose labels satisfy its whole selector. With no match, the endpoints list stayed empty and `kube-proxy` rejected traffic immediately. It was a plain typo, and nothing in the deployment flagged it as an error: Kubernetes happily accepts a selector that selects nothing.

### Fix
I corrected the Service selector to `app=web`. I changed the Service rather than the pods because (1) the pods were consistent with their own Deployment, (2) changing their labels would have required editing the Deployment's template, triggering a rollout that restarts healthy pods (and a Deployment's `selector` is immutable), and (3) other pieces may depend on `app=web`. Touching the Service had the smallest blast radius. Before the change I saved the previous state in `svc-web-before.yaml`.

### Prevention
- Alert when a Service has zero available endpoints (for example, using kube-state-metrics metrics).
- Add a post-deploy smoke test that makes a real request to the Service.
- Define labels in a single place (kustomize or Helm) so Service and Deployment can't diverge through a typo.
- Review in the pull request that the Service selector matches the Deployment template's labels. `verify.sh` already includes that check.
- In a GitOps setup, fix the manifest in Git and let the tool sync, instead of patching the cluster by hand.

### Lessons
- A pod in `Running` doesn't mean it receives traffic. The right question is whether the Service has it in its endpoints.
- When "the Service doesn't answer but the pods are fine", `kubectl get endpoints` is the first command: it separates a pod-selection problem from a network or application problem in seconds.
- An immediate `Connection refused` points to a Service with no destinations; a timeout points more toward a firewall, NetworkPolicy or pods that don't answer.
- Saving the previous state before touching a live resource costs one command and allows a rollback in seconds.
- I verify with an end-to-end test, not just by checking that the resource "looks right".
