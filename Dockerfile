# Stage 1: Menggunakan base image Nginx yang sangat ringan
# Nginx adalah web server performa tinggi yang ideal untuk menyajikan konten statis.
FROM nginx:alpine

# Menghapus file konfigurasi Nginx default
RUN rm /etc/nginx/conf.d/default.conf

# Menyalin file konfigurasi kustom (jika ada, opsional)
# COPY nginx.conf /etc/nginx/conf.d

# Menyalin seluruh file website statis (HTML, CSS, JS, gambar) ke direktori root Nginx
# Direktori ini adalah lokasi default Nginx menyajikan file.
COPY . /usr/share/nginx/html

# Mengekspos port 80 agar container dapat menerima traffic HTTP
EXPOSE 80

# Perintah untuk menjalankan Nginx di foreground saat container dimulai.
# Ini adalah praktik standar untuk container agar tetap berjalan.
CMD ["nginx", "-g", "daemon off;"]
