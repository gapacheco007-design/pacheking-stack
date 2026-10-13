# PacheKing Stack 🚀 (Producción)

Estación autónoma de descargas y procesamiento hacia Google Drive orquestada con Docker Compose en ARM64 (Oracle Cloud).

## Servicios Integrados
- **Aria2-Pro (`6800`, `6888`)**: Motor multihilo para descargas directas y torrents. RPC Secret: `1d0d8b3a3a52f684e6740180b134d6d8`
- **AriaNg (`6880`)**: Interfaz web moderna para Aria2.
- **MeTube (`8081`)**: Extracción de video y audio (MP3/4K) desde YouTube y redes sociales vía `yt-dlp`.
- **FileBrowser (`8080`)**: Gestor de archivos y streaming multimedia web (`admin` / `admin`).
- **Pipeline Automático**: Script `upload_to_gdrive.sh` que descomprime (.zip, .rar, .7z) y mueve los archivos a `gdrive:Descargas/`.

## Despliegue Rápido
\`\`\`bash
docker compose up -d
\`\`\`
