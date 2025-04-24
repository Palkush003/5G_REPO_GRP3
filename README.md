# 📶 5G Core Network Simulation using free5GC and UERANSIM on Minikube

### 📚 Group 3

This project demonstrates the deployment and simulation of a 5G Core Network using **free5GC** within a **Minikube Kubernetes** cluster and simulates the Radio Access Network (gNB + UE) using **UERANSIM**.

---

## 🧑‍💻 Group Members

- Palkush Dave (202251082)
- Om Kumar (202251081)
- Nishant (202252345)
- Garv Arora (202251048)
---

## 📌 Project Overview

This project aims to:
- Deploy a full 5G Core (free5GC) stack on Minikube.
- Simulate a 5G gNB and UE using UERANSIM.
- Establish connectivity between simulated UE and the 5GC.
- Analyze network registration and PDU session establishment.

---

## 🛠️ Tools & Technologies

- Kubernetes + Minikube
- Helm
- free5GC (v3.x)
- UERANSIM (latest)
- SCTP Protocol
- Docker

---

## 🚀 Setup Instructions

### 🔧 Prerequisites

- Ubuntu 20.04 or later
- Installed:
  - `minikube`
  - `kubectl`
  - `helm`
  - `git`
  - `build-essential`

### 📥 Clone and Setup

```bash
git clone https://github.com/group3-5g/free5gc-ueransim-minikube.git
cd free5gc-ueransim-minikube
chmod +x setup_5gc_ueransim.sh
./setup_5gc_ueransim.sh
```

---

## 🛰 Running gNB and UE

### ✅ gNB

```bash
cd ~/UERANSIM
./build/nr-gnb -c config/gnb.yaml
```

### ✅ UE

```bash
cd ~/UERANSIM
./build/nr-ue -c config/ue.yaml
```

---

## 🌐 Accessing the WebUI

```bash
kubectl port-forward svc/webui-service -n 5gc 5000:5000
```

Open your browser and go to: [http://localhost:5000](http://localhost:5000)

---

## 📁 Project Structure

```
.
├── config/                    # Configuration for gNB and UE
│   ├── gnb.yaml
│   └── ue.yaml
├── setup_5gc_ueransim.sh      # Automated installation and setup script
├── README.md
```

---

## 🧪 Test Cases

- ✅ UE Registration Success
- ✅ PDU Session Establishment
- ✅ Handover

---

## 🔍 Observations

- SCTP port must be correctly exposed via NodePort for gNB-AMF connection.
- Minikube IP must match the `remote_ip` in gNB config.
- Proper cell config (MCC/MNC) is required for UE to detect gNB.

---

## 🧹 Cleanup

```bash
minikube delete
rm -rf ~/UERANSIM
```

---

## 🙌 Acknowledgements

- [free5GC Team](https://www.free5gc.org/)
- [UERANSIM by Ali Güngör](https://github.com/aligungr/UERANSIM)
- Kubernetes and Helm communities

---

## 📜 License

This project is submitted as a part of academic coursework and follows open-source licensing under MIT.
