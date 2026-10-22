# SRE Labs Portfolio

## 🇪🇸 Español
Ejercicios prácticos de troubleshooting y automatización SRE con fallas simuladas, 100 % locales (sin nube real ni costos): Kubernetes + ArgoCD, CI/CD y Terraform + Atlantis. Cada ejercicio incluye su preparación, el script que provoca la falla, mi bitácora real de diagnóstico, la verificación, la limpieza y un postmortem.

### Índice de ejercicios
| # | Ejercicio | Tema | Estado |
|---|-----------|------|--------|
| 01 | [Pod that won't start](01-pod-wont-start/) | Kubernetes: `CrashLoopBackOff` por un error de configuración en un ConfigMap | ✅ Completado |

### Habilidades demostradas
| Habilidad | Ejercicios |
|-----------|------------|
| Diagnóstico de `CrashLoopBackOff` (estado, logs, código de salida) | 01 |
| Gestión de ConfigMaps y rollouts en Kubernetes | 01 |
| Validación de configuración antes de desplegar (`nginx -t`) | 01 |
| Scripts Bash seguros (guardia de contexto, idempotencia, códigos de salida) | 01 |
| Verificación de punta a punta y redacción de postmortems | 01 |

## 🇬🇧 English
Hands-on SRE troubleshooting and automation exercises with simulated failures, 100% local (no real cloud, no costs): Kubernetes + ArgoCD, CI/CD, and Terraform + Atlantis. Each exercise includes its setup, the script that triggers the failure, my real diagnosis logbook, verification, cleanup and a postmortem.

### Exercise index
| # | Exercise | Topic | Status |
|---|----------|-------|--------|
| 01 | [Pod that won't start](01-pod-wont-start/) | Kubernetes: `CrashLoopBackOff` caused by a configuration error in a ConfigMap | ✅ Completed |

### Skills demonstrated
| Skill | Exercises |
|-------|-----------|
| `CrashLoopBackOff` diagnosis (state, logs, exit code) | 01 |
| ConfigMap and rollout management in Kubernetes | 01 |
| Configuration validation before deploying (`nginx -t`) | 01 |
| Safe Bash scripting (context guard, idempotency, exit codes) | 01 |
| End-to-end verification and postmortem writing | 01 |

## License
MIT — see [LICENSE](LICENSE).
