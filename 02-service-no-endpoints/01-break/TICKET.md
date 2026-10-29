# 🇪🇸 Ticket de incidente INC-0002

| Campo | Valor |
|---|---|
| **ID** | INC-0002 |
| **Título** | La app «web» no responde en `http://web` |
| **Prioridad** | P2 - Alta |
| **Estado** | Abierto |
| **Reportado por** | Equipo storefront |
| **Asignado a** | Gerardo Suárez Gómez (SRE) |
| **Ambiente** | Minikube (clúster local de laboratorio), namespace `shop` |
| **Abierto** | 2026-10-29 13:25 (America/Mexico_City) |

## Síntoma (según el usuario)
> Desplegamos la app «web» en el namespace `shop` y los pods se ven bien, pero cuando intentamos entrar a `http://web` (puerto 80) desde dentro del clúster no responde nada. No sabemos por qué no llega el tráfico.

## Impacto
Ningún cliente dentro del clúster puede usar la app «web» a través de `http://web:80`. Los pods aparecen sanos, por lo que el problema no es evidente a simple vista.

## Solicitud
Averiguar por qué no llega el tráfico y corregirlo.

## Criterio de cierre
`http://web:80` responde correctamente desde un pod dentro del clúster.

---

# 🇬🇧 Incident ticket INC-0002

| Field | Value |
|---|---|
| **ID** | INC-0002 |
| **Title** | The "web" app does not answer at `http://web` |
| **Priority** | P2 - High |
| **Status** | Open |
| **Reported by** | Storefront team |
| **Assigned to** | Gerardo Suárez Gómez (SRE) |
| **Environment** | Minikube (local lab cluster), namespace `shop` |
| **Opened** | 2026-10-29 13:25 (America/Mexico_City) |

## Symptom (as the user put it)
> We deployed the "web" app in the `shop` namespace and the pods look fine, but when we try to reach `http://web` (port 80) from inside the cluster nothing answers. We don't know why the traffic doesn't arrive.

## Impact
No client inside the cluster can use the "web" app through `http://web:80`. The pods look healthy, so the problem is not obvious at first glance.

## Request
Find out why traffic does not arrive and fix it.

## Closing criterion
`http://web:80` answers correctly from a pod inside the cluster.
