#!/bin/bash
# Hook de descarga para Aria2 / Procesador hacia Google Drive
# Recibe argumentos de Aria2: $1 = GID, $2 = File count, $3 = File path
# O archivo directo: $1

TARGET_PATH="$3"
[ -z "$TARGET_PATH" ] && TARGET_PATH="$1"

LOG_FILE="/opt/downloader-stack/scripts/uploader.log"
exec >> "$LOG_FILE" 2>&1

echo "========================================="
echo "[$(date +%Y-%m-%d %H:%M:%S)] Nueva descarga detectada: $TARGET_PATH"

if [ -z "$TARGET_PATH" ]; then
    echo "ERROR: No se especificó ruta de descarga."
    exit 1
fi

# Esperar unos segundos para liberar locks si el archivo acaba de ser cerrado
sleep 2

if [ ! -e "$TARGET_PATH" ]; then
    echo "AVISO: La ruta directa no existe ($TARGET_PATH), comprobando directorio de descargas..."
fi

BASE_DIR="/opt/downloader-stack/downloads"
REMOTE_DEST="gdrive:Descargas/"

# 1. Descomprimir archivos si corresponde en /opt/downloader-stack/downloads
find "$BASE_DIR" -type f -name "*.zip" -exec unzip -o -q {} -d "$BASE_DIR" \; -exec rm -f {} \;
find "$BASE_DIR" -type f -name "*.rar" -exec unrar x -o+ {} "$BASE_DIR/" \; -exec rm -f {} \;
find "$BASE_DIR" -type f -name "*.7z" -exec 7z x -y {} -o"$BASE_DIR" \; -exec rm -f {} \;
find "$BASE_DIR" -type f -name "*.tar.gz" -exec tar -xzf {} -C "$BASE_DIR" \; -exec rm -f {} \;

# Limpiar archivos .aria2 huérfanos o temporales no activos
find "$BASE_DIR" -type f -name "*.aria2" -delete 2>/dev/null || true

# 2. Si Rclone está configurado, mover a Google Drive
if rclone listremotes | grep -q "^gdrive:"; then
    echo "[$(date +%Y-%m-%d %H:%M:%S)] Moviendo archivos a $REMOTE_DEST..."
    rclone move "$BASE_DIR" "$REMOTE_DEST" \
        --exclude "*.aria2" \
        --exclude "*.tmp" \
        --exclude "*.part" \
        --exclude "*.crdownload" \
        --delete-empty-src-dirs \
        --transfers 4 \
        --checkers 8 \
        --fast-list \
        --log-file="$LOG_FILE" \
        --log-level INFO
    echo "[$(date +%Y-%m-%d %H:%M:%S)] Sincronización a Google Drive completada."
else
    echo "[$(date +%Y-%m-%d %H:%M:%S)] Rclone gdrive aún no está configurado. Archivos guardados localmente en $BASE_DIR."
fi
