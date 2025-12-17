#!/bin/bash
# Android Security Suite (Termux)
# Defensive • No Root • Research Friendly

BASE_DIR="$HOME/android-security-suite-termux"
LOG_DIR="$BASE_DIR/logs"
QUAR_DIR="$BASE_DIR/quarantine"
REPORT_DIR="$BASE_DIR/reports"

mkdir -p "$LOG_DIR" "$QUAR_DIR" "$REPORT_DIR"

banner() {
  clear
  echo "========================================="
  echo "  ANDROID SECURITY SUITE (TERMUX)"
  echo "  Defensive • No Root • Research Friendly"
  echo "========================================="
}

pause() {
  read -rp "Tekan ENTER untuk lanjut..."
}

timestamp() {
  date '+%Y-%m-%d_%H-%M-%S'
}

# 1. Scan file mencurigakan
scan_files() {
  banner
  echo "[1] Scan file mencurigakan"
  OUT="$LOG_DIR/file_scan_$(timestamp).log"

  find "$HOME" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.apk" \) 2>/dev/null |
  while read -r f; do
    if grep -qiE "(nc |nmap |curl |wget |botnet|ddos|flood|payload|meterpreter)" "$f" 2>/dev/null; then
      echo "[SUSPECT] $f" | tee -a "$OUT"
    fi
  done

  echo "Hasil disimpan: $OUT"
  pause
}

# 2. Cek jaringan
check_network() {
  banner
  echo "[2] Cek jaringan & koneksi"
  OUT="$LOG_DIR/network_$(timestamp).log"

  echo "IP Address:" | tee "$OUT"
  ip addr 2>/dev/null | tee -a "$OUT"

  echo -e "\nKoneksi aktif:" | tee -a "$OUT"
  ss -tunap 2>/dev/null | tee -a "$OUT"

  pause
}

# 3. Indikator DDoS ringan
check_ddos() {
  banner
  echo "[3] Indikator DDoS (perkiraan)"
  OUT="$LOG_DIR/ddos_$(timestamp).log"

  ss -s 2>/dev/null | tee "$OUT"
  echo "Jika SYN/ESTAB sangat tinggi tanpa aktivitas normal, waspada." | tee -a "$OUT"

  pause
}

# 4. Karantina file
quarantine_file() {
  banner
  read -rp "Masukkan path file: " f

  if [ -f "$f" ]; then
    mv "$f" "$QUAR_DIR/" && echo "Dipindahkan ke $QUAR_DIR"
  else
    echo "File tidak ditemukan"
  fi

  pause
}

# 5. Hapus karantina
clean_quarantine() {
  banner
  ls -l "$QUAR_DIR"
  read -rp "Yakin hapus semua? (y/N): " y

  if [[ "$y" =~ ^[Yy]$ ]]; then
    rm -f "$QUAR_DIR"/*
    echo "Karantina dibersihkan."
  fi

  pause
}

# 6. Export laporan
export_report() {
  banner
  OUT="$REPORT_DIR/report_$(timestamp).zip"

  command -v zip >/dev/null || pkg install -y zip
  zip -r "$OUT" "$LOG_DIR" "$QUAR_DIR" >/dev/null 2>&1

  echo "Laporan diekspor: $OUT"
  pause
}

# 7. Update tool
self_update() {
  banner
  git pull --rebase || echo "Pastikan ini hasil clone GitHub"
  pause
}

# 8. Tips hardening
hardening_tips() {
  banner
  cat <<EOF
Tips Keamanan Tanpa Root:
- Hapus aplikasi mencurigakan
- Batasi izin aplikasi
- Gunakan DNS aman (1.1.1.1 / 9.9.9.9)
- Hindari WiFi publik
- Update sistem & aplikasi
EOF
  pause
}

while true; do
  banner
  echo "1) Scan file mencurigakan"
  echo "2) Cek jaringan"
  echo "3) Indikator DDoS"
  echo "4) Karantina file"
  echo "5) Hapus karantina"
  echo "6) Export laporan"
  echo "7) Update tool"
  echo "8) Tips hardening"
  echo "0) Keluar"
  read -rp "> Pilih menu: " c

  case "$c" in
    1) scan_files ;;
    2) check_network ;;
    3) check_ddos ;;
    4) quarantine_file ;;
    5) clean_quarantine ;;
    6) export_report ;;
    7) self_update ;;
    8) hardening_tips ;;
    0) exit 0 ;;
    *) echo "Pilihan tidak valid"; sleep 1 ;;
  esac
done
