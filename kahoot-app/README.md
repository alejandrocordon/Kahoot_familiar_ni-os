# Kahoot Familiar

Quiz interactivo familiar con **12 temas**, **691 preguntas** y fondos animados por tema. Listo para Docker en cualquier máquina o Raspberry Pi.

---

## Temas disponibles

### Series & Juegos
| Tema | Preguntas | Fondo animado |
|------|-----------|---------------|
| Harry Potter ⚡ | 105 | Estrellas doradas, rayos, escudos de casas |
| Shin Chan 🍑 | 75 | Duraznos, crayones, nubes kawaii |
| Pokémon 🔴 | 75 | Pokébolas, rayos, tipos elementales |
| My Melody & Kuromi 🐰 | 65 | Lazos, corazones pulsantes, estrellas |
| Minecraft ⛏️ | 45 | Bloques pixelados, picos, diamantes |
| Studio Ghibli 🌿 | 45 | Hojas cayendo, esporas, luna |

### Del Cole
| Tema | Preguntas | Fondo animado |
|------|-----------|---------------|
| Matemáticas 🔢 | 50 | Operaciones flotantes, números |
| Lengua 📝 | 47 | Letras del abecedario, plumas |
| Historia 🏛️ | 47 | Castillos, espadas, polvo antiguo |
| Geografía 🌍 | 49 | Globos, brújulas, meridianos |
| Sistema Solar 🪐 | 48 | 30 estrellas, planetas, nebulosas |

### 🧩 Reto Mental
| Tema | Preguntas | Fondo animado |
|------|-----------|---------------|
| Adivinanzas 🧩 | 40 | Interrogantes, bombillas, puzzles dorados |

Tres niveles de dificultad (⭐ / ⭐⭐ / ⭐⭐⭐), turnos alternos, puntos por velocidad, 1-10 jugadores.

---

## Despliegue rápido (local)

Requisitos: [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado.

```bash
cd kahoot-app
docker compose up -d --build
```

Abre en el navegador: `http://localhost:8080`

---

## Despliegue en Raspberry Pi

### 1. Copiar archivos a la Pi

```bash
scp -r kahoot-app/ pi@<IP_DE_TU_PI>:~/
```

### 2. Conectarse y levantar

```bash
ssh pi@<IP_DE_TU_PI>
cd ~/kahoot-app
docker compose up -d --build
```

### 3. Acceder desde cualquier dispositivo de la red

```
http://<IP_DE_TU_PI>:8080
```

> Para saber la IP de tu Pi: ejecuta `hostname -I` en la Pi.

---

## Gestión del contenedor

```bash
# Ver estado
docker compose ps

# Ver logs en tiempo real
docker compose logs -f

# Parar el contenedor
docker compose down

# Reconstruir tras cambios en index.html
docker compose up -d --build

# Reiniciar sin reconstruir
docker compose restart
```

---

## Estructura del proyecto

```
kahoot-app/
├── index.html          # App completa (HTML + CSS + JS + preguntas)
├── Dockerfile          # Sirve index.html con nginx:alpine
├── docker-compose.yml  # Puerto 8080 → 80, restart automático
└── README.md
```

---

## Personalizar preguntas

Edita el objeto `DB` en `index.html`. Formato de cada pregunta:

```js
{q:"¿Pregunta?", o:["Op1","Op2","Op3","Op4"], c:0, d:1}
// c = índice de la respuesta correcta (0-3)
// d = dificultad: 1=fácil ⭐  2=media ⭐⭐  3=difícil ⭐⭐⭐
```

Después de editar, reconstruye:

```bash
docker compose up -d --build
```

---

## Cambiar el puerto

Edita `docker-compose.yml`:

```yaml
ports:
  - "3000:80"   # Cambia 8080 por el puerto que quieras
```

Luego: `docker compose up -d --build`
