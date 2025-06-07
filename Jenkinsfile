// Jenkinsfile (Declarative Pipeline)
// Pipeline ini akan melakukan proses CI/CD secara otomatis
pipeline {
    // Menentukan di mana pipeline akan berjalan. 'any' berarti Jenkins bisa memilih agent mana pun.
    agent any

    // Mendefinisikan variabel lingkungan yang akan digunakan di seluruh pipeline
    environment {
        // Ganti 'your-dockerhub-username' dengan username Docker Hub Anda
        DOCKER_IMAGE_NAME = "eve56/final-project-news" 
        // ID dari credentials Docker Hub yang sudah Anda simpan di Jenkins
        DOCKER_HUB_CREDENTIALS = "docker-hub"
        // Namespace di Kubernetes tempat aplikasi akan di-deploy
        KUBE_NAMESPACE = "final-project-news"
    }

    stages {
        // Stage 1: Checkout - Mengambil kode dari repository
        stage('Checkout SCM') {
            steps {
                echo 'Checking out code from repository...'
                // Perintah ini akan mengambil kode dari repo yang terkonfigurasi di Jenkins Job
                checkout scm
            }
        }

        // Stage 2: Build Docker Image - Membangun image Docker dari Dockerfile
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                // Menjalankan perintah 'docker build'. 
                // Tag -t digunakan untuk memberi nama dan tag pada image. 
                // Tagging dengan BUILD_NUMBER memastikan setiap build memiliki image yang unik.
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        // Stage 3: Push Docker Image - Mendorong image ke registry (Docker Hub)
        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image to Docker Hub..."
                // Menggunakan 'withCredentials' untuk mengakses username dan password secara aman
                withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    // Login ke Docker Hub
                    sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    // Push image dengan tag BUILD_NUMBER
                    sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                    // Memberi tag 'latest' pada image yang baru di-build dan push lagi
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        // Stage 4: Deploy to Kubernetes - Menerapkan konfigurasi ke cluster K8s
        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes in namespace ${KUBE_NAMESPACE}..."
                // Menggunakan 'kubectl apply' untuk menerapkan atau memperbarui semua resource
                // dari file-file .yaml. Ini mendukung deployment tanpa downtime (rolling updates).
                sh "kubectl apply -f deployment.yaml -n ${KUBE_NAMESPACE} --validate=false"
                sh "kubectl apply -f service.yaml -n ${KUBE_NAMESPACE} --validate=false"
                sh "kubectl apply -f ingress.yaml -n ${KUBE_NAMESPACE} --validate=false"
                
                echo "Deployment successful!"
            }
        }
    }
    
    // Post-actions: Langkah yang dijalankan setelah semua stage selesai
    post {
        always {
            // Selalu membersihkan workspace dan logout dari Docker Hub untuk keamanan
            echo 'Cleaning up workspace and logging out...'
            sh 'docker logout'
            cleanWs()
        }
    }
}
