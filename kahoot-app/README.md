# 🎮 Kahoot Familiar

Quiz interactivo familiar con **11 temas** y **651 preguntas**, listo para Docker en Raspberry Pi.

## Temas

### 🎮 Series & Juegos
| Tema | Preguntas |
|------|-----------|
| Harry Potter ⚡ | 105 |
| Shin Chan 🍑 | 75 |
| Pokémon 🔴 | 75 |
| My Melody & Kuromi 🐰 | 65 |
| Minecraft ⛏️ | 45 |
| Studio Ghibli 🌿 | 45 |

### 📚 Del Cole
| Tema | Preguntas |
|------|-----------|
| Matemáticas 🔢 | 50 |
| Lengua 📝 | 47 |
| Historia 🏛️ | 47 |
| Geografía 🌍 | 49 |
| Sistema Solar 🪐 | 48 |

Tres niveles de dificultad (⭐ / ⭐⭐ / ⭐⭐⭐), turnos alternos, puntos por velocidad.

## Despliegue en Raspberry Pi

```bash
scp -r kahoot-app/ pi@<IP_PI>:~/
ssh pi@<IP_PI>
cd ~/kahoot-app
docker compose up -d --build
```

Acceso desde tablet: `http://<IP_PI>:8080`

## Gestión

```bash
docker compose down          # Parar
docker compose logs -f       # Ver logs
docker compose up -d --build # Reconstruir
```

## Personalización

Edita `index.html`, objeto `DB`. Formato por pregunta:

```js
{q:"Pregunta", o:["Op1","Op2","Op3","Op4"], c:0, d:1}
// c = índice respuesta correcta (0-3)
// d = dificultad (1=fácil, 2=media, 3=difícil)
```

Reconstruye tras editar: `docker compose up -d --build`
