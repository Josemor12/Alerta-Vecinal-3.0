# Alerta Vecinal 3.0 🚨  
![Logo](https://github.com/Josemor12/Alerta-Vecinal-3.0/raw/main/AlertaVecinal3.0%20-%20Copia%20de%20Seguridad/AlertaVecinal3.0/Resources/logo.png)

Aplicación de seguridad comunitaria para iOS desarrollada en Swift que permite reportar incidentes y recibir alertas en tiempo real.

## 📱 Características
- Reportes en tiempo real con geolocalización
- Mapa interactivo de incidentes (MapKit)
- Botón de emergencia con notificaciones push
- Historial de reportes y perfiles verificados

## 🛠 Tecnologías
- Swift 5 + MVVM
- MapKit y CoreLocation
- Core Data

## ⚙️ Requisitos
- Xcode Version 16.4 (16F6)
- iOS 18.0+
- iPhone con cable Lightning/USB-C (para instalación sin cuenta de desarrollador)

## 🚀 Instalación (sin cuenta de desarrollador paga)
1. Clona el repositorio:  
   `git clone https://github.com/Josemor12/Alerta-Vecinal-3.0.git`

### 📱 Conexión del iPhone
2. Conecta tu iPhone a la Mac con cable USB
3. En el iPhone, ve a **Ajustes > General > Administración de dispositivos** y confía en tu computadora
4. En Xcode:
   - Selecciona tu dispositivo físico (no simulador) en la barra de esquemas
   - Ve a **Preferences > Accounts** y añade tu Apple ID personal
   - En el proyecto, selecciona tu Apple ID como equipo de firma
5. Compila la app:
   - Haz clic en el botón ▶️ (o Cmd+R)
   - Si aparece error de firma, ve a **Signing & Capabilities** y:
     - Marca "Automatically manage signing"
     - Selecciona tu Apple ID personal
6. Primera ejecución:
   - En tu iPhone, ve a **Ajustes > General > VPN y Gestión de Dispositivos**
   - Confía en el certificado de desarrollador de tu Apple ID
   - ¡Listo! La app se ejecutará por 7 días (renovable)

## ⚠️ Limitaciones sin cuenta de desarrollador
- La app expira cada 7 días (debes recompilar)
- Notificaciones push pueden no funcionar correctamente
- Algunas funciones avanzadas podrían estar limitadas

## 📱 Comparativa: Instalación en iOS vs Android

### 🔒 Por qué es más complejo instalar apps en iPhone
#### 🛡️ Modelo de Seguridad de Apple
- **Ecosistema cerrado**: iOS usa un sistema "walled garden" para máxima seguridad
- **Firma obligatoria**: Requiere certificados de Apple (gratis para desarrollo, $99/año para distribución)
- **App Store exclusivo**: Instalación de terceros necesita jailbreak (anula garantía) o herramientas como AltStore
