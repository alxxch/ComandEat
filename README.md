# ComandEat 🍽️
Aplicación de gestión de pedidos para restaurantes  
_(Trabajo Fin de Grado – DAM)_

---

## 📱 Descripción

**ComandEat** es una solución digital diseñada para optimizar la experiencia tanto de los clientes como del personal en restaurantes. El sistema está compuesto por dos aplicaciones desarrolladas con **Flutter** y gestionadas desde **Android Studio**:

- **App Cliente**: Los comensales pueden escanear un código QR en su mesa, consultar el menú digital, realizar pedidos directamente desde su dispositivo móvil y solicitar la atención del camarero con un solo botón.

- **App Administrador**: El encargado del restaurante recibe los pedidos en tiempo real, gestiona el estado de las mesas, reservas, llamadas de clientes y controla el flujo de pedidos desde la cocina hasta la entrega.

---

## 🚀 Tecnologías utilizadas

<div style="display:flex; align-items:center;">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter Badge"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart Badge"/>
  <img src="https://img.shields.io/badge/Android%20Studio-3DDC84?logo=android-studio&logoColor=white" alt="Android Studio Badge"/>
  <img src="https://img.shields.io/badge/Visual%20Studio%20Code-0078D4?logo=visual-studio-code&logoColor=white" alt="Visual Studio Code Badge">
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase Badge"/>
  <img src="https://img.shields.io/badge/Riverpod-075E54?logoColor=white" alt="Riverpod Badge">
  <img src="https://img.shields.io/badge/GoRouter-4285F4?logoColor=white" alt="GoRouter Badge">
  <img src="https://img.shields.io/badge/Figma-F24E1E?logo=figma&logoColor=white" alt="Figma Badge">
  <img src="https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white" alt="GitHub Badge">
</div>

- **Flutter** ![Flutter](https://img.icons8.com/color/24/flutter.png) — Framework principal para el desarrollo multiplataforma.
- **Dart** ![Dart](https://img.icons8.com/color/24/dart.png) — Lenguaje de programación.
- **Android Studio** ![Android Studio](https://img.icons8.com/color/24/android-studio--v2.png) — IDE principal de desarrollo.
- **Visual Studio Code** ![Visual Studio Code](https://img.icons8.com/color/24/visual-studio-code-2019.png) — IDE secundario de desarrollo.
- **Supabase** ![Supabase](https://img.icons8.com/ios-filled/24/3ECF8E/database.png) — Backend como servicio (BaaS) con PostgreSQL, autenticación y realtime.
- **Riverpod** ![Riverpod](https://img.icons8.com/ios/24/000000/workflow.png) — Gestión del estado.
- **GoRouter** ![GoRouter](https://img.icons8.com/ios-filled/24/000000/route.png) — Navegación declarativa.
- **Figma** ![Figma](https://img.icons8.com/color/24/figma.png) — Diseño de interfaces.
- **GitHub** ![GitHub](https://img.icons8.com/ios-glyphs/24/000000/github.png) — Control de versiones.

---

## 📂 Estructura del proyecto

```plaintext
comandeat/
├── lib/
│   ├── admin/            # Entry point App Administrador   
│   ├── client/           # Entry point App Cliente
│   ├── core/             # Modelos, servicios y utilidades comunes
│   ├── features/         # Módulos funcionales (menu, carrito, pedido, llamada)
│   │   ├── admin/        # Controladores y vistas de administrador
│   │   └── client/       # Controladores y vistas de cliente
│   └── routes/           # Configuración de rutas (GoRouter)            
├── pubspec.yaml
└── README.md
```
---
## ⚙️ Configuración del entorno

### 1. Requisitos previos:
- Flutter SDK ≥ 3.x
- Tener instalado **Android Studio** o **Visual Studio Code**.
- Emulador o dispositivo físico.
- Cuenta en **Supabase** con el proyecto configurado.
### 2. Clonar el repositorio:

```bash
git clone https://github.com/tuusuario/comandeat.git  
cd comandeat
```

### 3. Configurar variables de entorno
Crear un archivo .env en la raíz con las siguientes claves:
```env
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsIn...
```
### 4. Instalar dependencias:

```bash
flutter pub get  
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ▶️ Ejecución

- **App Cliente**:

```bash
flutter run -t lib/client/main_cliente.dart
```

- **App Administrador**:

```bash
flutter run -t lib/admin/main_admin.dart
```
---

## 👨‍💻 Autor
Alejandro Posadas Martín  
Alumno de 2º Desarrollo de Aplicaciones Multiplataforma (DAM)  
[LinkedIn](https://www.linkedin.com/in/alejandroposmardev/) | [GitHub](https://github.com/alxxch)

---

## 📜 Licencia
Este proyecto es parte de un Trabajo Fin de Grado (TFG). Uso educativo.
