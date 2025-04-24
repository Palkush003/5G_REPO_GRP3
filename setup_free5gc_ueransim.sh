#!/bin/bash

set -e

echo "🚀 Starting full setup of free5GC + UERANSIM"

### 1. Install dependencies (if not installed)
echo "🔍 Checking dependencies..."
command -v kubectl >/dev/null 2>&1 || { echo >&2 "kubectl is required. Please install it first."; exit 1; }
command -v minikube >/dev/null 2>&1 || { echo >&2 "minikube is required. Please install it first."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo >&2 "helm is required. Please install it first."; exit 1; }

### 2. Start Minikube
echo "⚙️ Starting Minikube..."
minikube start --cpus=4 --memory=8192 --driver=docker

### 3. Create namespace for 5GC
kubectl create namespace 5gc || echo "Namespace already exists"

### 4. Add Helm repo & install free5GC
echo "📦 Installing free5GC via Helm..."
helm repo add free5gc https://free5gc.github.io/helm-charts
helm repo update
helm install free5gc free5gc/free5gc -n 5gc

### 5. Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod --all -n 5gc --timeout=300s

### 6. Patch AMF Service to expose via NodePort
echo "🔧 Exposing AMF via NodePort (port 30801)..."
kubectl patch svc free5gc-free5gc-amf-service -n 5gc \
  --type='json' \
  -p='[
    {"op": "replace", "path": "/spec/type", "value": "NodePort"},
    {"op": "add", "path": "/spec/ports/1", "value": {
      "name": "sctp",
      "port": 38412,
      "protocol": "SCTP",
      "targetPort": 38412,
      "nodePort": 30801
    }}
  ]'

### 7. Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "🛰️ Minikube IP is $MINIKUBE_IP"

### 8. Clone and build UERANSIM
echo "🧱 Cloning and building UERANSIM..."
cd ~
git clone https://github.com/aligungr/UERANSIM.git
cd UERANSIM
make

### 9. Create gNB config
echo "📝 Creating gNB config..."
cat <<EOF > config/gnb.yaml
gnb:
  nci: 1000
  tac: 1
  mcc: '208'
  mnc: '93'
  sctp:
    local_ip: 127.0.0.1
    local_port: 38412
    remote_ip: $MINIKUBE_IP
    remote_port: 30801
  cell:
    plmn:
      mcc: '208'
      mnc: '93'
    bandwidth: '50MHz'
    frequency: '3500MHz'
  nrci: 1000
  bandwidth: 50
EOF

### 10. Create UE config
echo "📝 Creating UE config..."
cat <<EOF > config/ue.yaml
supi: 'imsi-208930000000003'
gpsi: 'msisdn-0900000000'
mcc: '208'
mnc: '93'
protectionScheme: 0
key: '8baf473f2f8fd09487cccbd7097c6862'
op: '8e27b6af0e692e750f32667a3b14605d'
opType: 'OPC'
amf: '8000'
imei: '356938035643803'
imeiSv: '4370816125816151'
tunNetmask: '255.255.255.0'
gnbSearchList:
  - 127.0.0.1
uacAic:
  mps: false
  mcs: false
uacAcc:
  normalClass: 0
  class11: false
  class12: false
  class13: false
  class14: false
  class15: false
sessions:
  - type: 'IPv4'
    apn: 'internet'
    slice:
      sst: 0x01
      sd: 0x010203
configured-nssai:
  - sst: 0x01
    sd: 0x010203
default-nssai:
  - sst: 1
    sd: 1
integrity:
  IA1: true
  IA2: true
  IA3: true
ciphering:
  EA1: true
  EA2: true
  EA3: true
integrityMaxRate:
  uplink: 'full'
  downlink: 'full'
gnb:
  nci: 1000
  tac: 1
  sctp:
    local_ip: 127.0.0.1
    local_port: 38412
    remote_ip: $MINIKUBE_IP
    remote_port: 30801
EOF

### 11. Ready to run UERANSIM
echo ""
echo "✅ Setup complete. To start gNB and UE:"
echo ""
echo "📡 Run gNB:"
echo "  ./build/nr-gnb -c config/gnb.yaml"
echo ""
echo "📱 Run UE:"
echo "  ./build/nr-ue -c config/ue.yaml"
echo ""
