# 📱💻 LLM GRATIS desde tu celular (usándolo desde tu PC)

Corre un modelo de lenguaje (LLM) **localmente en tu celular** y úsalo desde tu computadora vía SSH.

Sin APIs. Sin nube. Sin pagar.

---

## 🚀 ¿Qué vas a lograr?

* Tener un LLM corriendo en tu Android 📱
* Acceder desde tu PC como si fuera local 💻
* Chatear con él usando `curl` o scripts
* Todo **100% gratis y offline**

---

## 🧠 Tecnologías

* Ollama → Motor para correr modelos LLM
* Termux → Terminal en Android
* SSH → Conexión entre tu PC y el celular

👉 Sitio oficial: [https://ollama.com](https://ollama.com)

---

## ⚙️ Instalación

### 1. Instalar en Termux

```bash
pkg update && pkg upgrade
pkg install ollama
```

---

### 2. Levantar el servidor

Abre **dos sesiones de Termux**

#### Sesión 1 (servidor)

```bash
termux-wake-lock
ollama serve
```

Esto evita que Android mate el proceso cuando bloqueas la pantalla.

---

### 3. Probar el modelo

#### Sesión 2

```bash
ollama run gemma3:1b
```

---

## 🌐 Obtener IP del celular

Ve a:

```
Ajustes > WiFi > tu red
```

Ahí verás la IP local (ej: `192.168.1.10`)

---

## 🔗 Conectarte desde tu computadora

Crea un túnel SSH:

```bash
ssh -L 11434:localhost:11434 -p 8022 IP_DEL_CELULAR
```

Ahora tu PC puede usar el LLM como si estuviera corriendo localmente.

---

## 💬 Script para chatear fácil

Crea un archivo `chat.sh`:

```bash
#!/bin/bash
while read -p "Tú: " msg; do
  respuesta=$(curl -s http://localhost:11434/api/chat -d "{
    \"model\": \"gemma3:1b\",
    \"messages\": [{\"role\":\"user\",\"content\":\"$msg\"}],
    \"stream\": false
  }" | grep -o '"content":"[^"]*"' | head -1 | cut -d'"' -f4)
  echo "LLM: $respuesta"
done
```

---

### Dar permisos y ejecutar

```bash
chmod +x chat.sh
./chat.sh
```

---

## 🔥 Resultado

Ahora tienes:

* Un LLM corriendo en tu celular
* Accesible desde tu computadora
* Sin pagar absolutamente nada

---

## ⚠️ Notas

* Modelos pequeños (como `gemma3:1b`) funcionan mejor en celular
* Mantén la pantalla activa o usa `termux-wake-lock`
* Asegúrate de estar en la misma red WiFi

---

## 🧪 Ideas para mejorar

* Crear UI web encima del endpoint
* Conectarlo a una app Flutter
* Usarlo como backend local para pruebas
* Integrarlo con bots o automatizaciones

---

# 📦 Opciones de nombre para el repo

### 🧠 Técnicos / dev

* `phone-llm-server`
* `ollama-mobile-ssh`
* `local-llm-over-ssh`
* `android-llm-node`
* `ollama-remote-client`

### 🔥 Virales / llamativos

* `llm-gratis-en-tu-cel`
* `chatgpt-casero`
* `llm-sin-pagar`
* `tu-propio-chatgpt`
* `ai-en-tu-bolsillo`

### ⚡ Startup vibes

* `PocketLLM`
* `CellAI`
* `LocalMind`
* `EdgeGPT`
* `MiniBrain`

---

Si quieres, te hago también:

* README en inglés 🌍
* versión más técnica (con benchmarks y modelos)
* o incluso una UI web para ese endpoint 👀
