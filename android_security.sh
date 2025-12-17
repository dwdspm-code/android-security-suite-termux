#!/data/data/com.termux/files/usr/bin/bash

ANDROID SECURITY SUITE (DEFENSIVE)

Non-root | Termux only | Research purpose

BASE_DIR="$HOME/android_security" LOG_DIR="$BASE_DIR/logs" QUAR_DIR="$BASE_DIR/quarantine" REPORT_DIR="$BASE_DIR/reports"

mkdir -p "$LOG_DIR" "$QUAR_DIR" "$REPORT_DIR"

LOGFILE="$LOG_DIR/scan_$(date +%F_%H-%M).log" REPORT="$REPORT_DIR/report_$(date +%F_%H-%M).txt"

function header() { clear echo "=======================================" echo " ANDROID SECURITY SUITE (NO ROOT)" echo " Malware • Network • DNS • Research" echo "=======================================" }

function pause() { echo read -p "Tekan ENTER untuk kembali ke menu..." tmp }

function check_deps() { echo "[+] Cek dependensi..." | tee -a "$LOGFILE" for cmd in clamscan nmap netstat ss ping sha256sum; do if ! command -v $cmd >/dev/null 2>&1; then echo "[-] $cmd belum terinstall" | tee -a "$LOGFILE" else echo "[OK] $cmd tersedia" | tee -a "$LOGFILE" fi done }

function malware_scan() { echo "[+] Malware scan dimulai" | tee -a "$LOGFILE" echo "Scan /sdcard/Download dan /sdcard/Android" | tee -a "$LOGFILE" clamscan -r /sdcard/Download --move="$QUAR_DIR" | tee -a "$LOGFILE" clamscan -r /sdcard/Android --move="$QUAR_DIR" | tee -a "$LOGFILE" echo "[+] Scan selesai" | tee -a "$LOGFILE" }

function network_scan() { echo "[+] Network scan" | tee -a "$LOGFILE" ip a | tee -a "$REPORT" ip route | tee -a "$REPORT" netstat -tunap | tee -a "$REPORT" ss -tunap | tee -a "$REPORT" }

function nmap_scan() { echo "[+] Scan jaringan lokal" | tee -a "$LOGFILE" SUBNET=$(ip route | grep wlan | awk '{print $1}') if [ -z "$SUBNET" ]; then echo "[-] Subnet tidak terdeteksi" | tee -a "$LOGFILE" else nmap -sn "$SUBNET" | tee -a "$REPORT" fi }

function dns_fix() { echo "[+] Set DNS Cloudflare" | tee -a "$LOGFILE" echo "nameserver 1.1.1.1" > $PREFIX/etc/resolv.conf echo "nameserver 8.8.8.8" >> $PREFIX/etc/resolv.conf cat $PREFIX/etc/resolv.conf | tee -a "$REPORT" }

function hash_research() { read -p "Masukkan path file APK: " FILE if [ -f "$FILE" ]; then sha256sum "$FILE" | tee -a "$REPORT" echo "Gunakan hash ini untuk VirusTotal (manual)" | tee -a "$REPORT" else echo "File tidak ditemukan" | tee -a "$LOGFILE" fi }

function quarantine_menu() { echo "[+] Isi karantina:" | tee -a "$LOGFILE" ls -lh "$QUAR_DIR" echo echo "1. Hapus semua file karantina" echo "2. Pindahkan ke folder riset" read -p "Pilih: " q case $q in 1) rm -rf "$QUAR_DIR"/* ; echo "Karantina dibersihkan" | tee -a "$LOGFILE";; 2) mv "$QUAR_DIR"/* "$REPORT_DIR"/research_files/ 2>/dev/null;; esac }

while true; do header echo "1. Cek dependensi & status" echo "2. Scan malware (ClamAV)" echo "3. Scan koneksi & network" echo "4. Scan jaringan lokal (Nmap)" echo "5. Perbaiki DNS / jaringan" echo "6. Research hash APK (VirusTotal)" echo "7. Kelola karantina (hapus / simpan)" echo "0. Keluar" echo "" read -p "Pilih menu [0-7]: " menu

case $menu in 1) check_deps; pause;; 2) malware_scan; pause;; 3) network_scan; pause;; 4) nmap_scan; pause;; 5) dns_fix; pause;; 6) hash_research; pause;; 7) quarantine_menu; pause;; 0) exit 0;; *) echo "Pilihan tidak valid"; sleep 1;; esac done
