# Jenkins + OpenShift Local (CRC) — reinicio de deployments desde pipeline

## 0. Requisitos previos
- `crc start` ya ejecutado y el clúster arriba (`crc status` debe decir `Running`).
- Docker Desktop corriendo.

## 1. Averigua la IP de CRC y ponla en docker-compose.yml

```bash
crc ip
```

Copia esa IP y sustituye `192.168.130.11` en `docker-compose.yml` (bloque `extra_hosts`).
Esto es necesario porque CRC resuelve `*.crc.testing` mediante el resolver DNS del
host Windows, pero el contenedor de Jenkins no tiene visibilidad de esa configuración
del host — sin este `extra_hosts`, `oc login` dará timeout o "no route to host".

## 2. Levanta Jenkins

```bash
docker compose up -d --build
```

Abre http://localhost:8080, desbloquea Jenkins con la contraseña inicial:

```bash
docker exec jenkins-crc cat /var/jenkins_home/secrets/initialAdminPassword
```

## 3. Crea un Service Account en OpenShift para Jenkins (no uses tu usuario personal)

Con `oc` en tu máquina Windows (ya logueado con `oc login -u kubeadmin ...` o `crc console --credentials`):

```bash
oc project demo                 # o el namespace que quieras usar
oc create serviceaccount jenkins-deployer
oc policy add-role-to-user edit -z jenkins-deployer
# Si quieres limitarlo solo a reiniciar deployments (mas seguro que 'edit'):
#   oc create role deployment-restarter --verb=get,list,patch,update --resource=deployments,deployments/scale
#   oc adm policy add-role-to-user deployment-restarter -z jenkins-deployer --role-namespace=demo

oc create token jenkins-deployer --duration=8760h
```

Copia el token que imprime ese último comando.

## 4. Guarda el token como credencial en Jenkins

Jenkins → **Manage Jenkins → Credentials → (global) → Add Credentials**
- Kind: **Secret text**
- Secret: el token del paso 3
- ID: `ocp-jenkins-sa-token`  (debe coincidir con el `credentials(...)` del Jenkinsfile)

## 5. Sube esta carpeta a tu repo Git

```bash
git init
git add .
git commit -m "Pipeline Jenkins para reiniciar deployments en OpenShift"
git branch -M main
git remote add origin <URL_DE_TU_REPO>
git push -u origin main
```

## 6. Crea el Pipeline job en Jenkins

Jenkins → **New Item → Pipeline** → nombre, p.ej. `restart-deployment`
- **Pipeline → Definition**: `Pipeline script from SCM`
- **SCM**: Git → URL de tu repo, rama `main`
- **Script Path**: `Jenkinsfile`

Guarda y pulsa **Build with Parameters**, rellena `OC_NAMESPACE` y `DEPLOYMENT_NAME`.

## Notas
- `restart-deployment.sh` funciona igual si en vez de `Deployment` usas `DeploymentConfig`
  (OpenShift clásico): cambia `deployment/` por `dc/` en el script.
- El `--insecure-skip-tls-verify=true` es porque CRC usa un certificado autofirmado;
  en un clúster real deberías importar el CA en vez de saltarte la verificación TLS.
- Si quieres más pipelines (deploy, logs, escalado), duplica el patrón:
  un script en `scripts/` + un `stage` nuevo en el `Jenkinsfile`, o crea Jenkinsfiles
  separados por job.
