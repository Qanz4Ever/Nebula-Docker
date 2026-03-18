<div align="center">
  <img src="https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/Assets/logo.png" alt="Nebula Docker Logo" width="200"/>
  
  # 🌌 Nebula Docker
  
  ### *Premium Docker Container Management System*
  
  [![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Qanz4Ever/Nebula-Docker)
  [![Docker](https://img.shields.io/badge/docker-required-2496ED.svg)](https://www.docker.com/)
  [![Node](https://img.shields.io/badge/node-18.x-339933.svg)](https://nodejs.org/)
  [![Bash](https://img.shields.io/badge/bash-5.x-4EAA25.svg)](https://www.gnu.org/software/bash/)
  
  <p align="center">
    <b>English</b> | <a href="#indonesian">Indonesian</a>
  </p>

  ---

  <p align="center">
    <i>Transform your Docker containers into fully manageable VPS-like instances with a powerful CLI tool and stunning web dashboard.</i>
  </p>

  ![Dashboard Preview](https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/assets/preview.png)
</div>

---

## ✨ Features

### 🖥️ CLI Tool (`nebula.sh`)
- **Create Container** - Deploy containers with various OS options
- **Resource Management** - Set CPU, RAM, and disk limits
- **Network Configuration** - Port mapping and custom networks
- **Volume Management** - Persistent data storage
- **Environment Variables** - Configure container environment
- **Interactive Shell** - Direct container access
- **Container Lifecycle** - Start, Stop, Restart, Rename, Delete
- **Monitoring** - Real-time stats and logs
- **Backup & Restore** - Container backup functionality

### 🌐 Web Dashboard
- **Modern UI** - Premium dark theme with neon accents
- **Real-time Monitoring** - Live container statistics
- **Container Management** - Full control via web interface
- **System Information** - Host system monitoring
- **Responsive Design** - Works on desktop and mobile
- **Auto-refresh** - Live updates every 5 seconds
- **Toast Notifications** - User-friendly alerts
- **Modal Forms** - Easy container creation

### 🚀 Supported Images
- Ubuntu 22.04/20.04 LTS
- Debian 12/11
- CentOS 9 Stream
- Alpine Linux 3.19
- Fedora 39
- Arch Linux
- Python 3.12-slim
- Node.js 20-slim
- Nginx Alpine
- MySQL 8.0
- PostgreSQL 16
- Redis 7-alpine
- Custom images supported

---

## 📦 Installation

### Prerequisites
- Docker (automatically installed if missing)
- Linux/Unix system (Ubuntu/Debian/CentOS/Fedora)
- Internet connection

### One-line Installation
```bash
curl -o nebula.sh https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/nebula.sh && chmod +x nebula.sh && ./nebula.sh
```

Manual Installation

```bash
# Clone repository
git clone https://github.com/Qanz4Ever/Nebula-Docker.git
cd Nebula-Docker

# Make CLI executable
chmod +x nebula.sh

# Run CLI
./nebula.sh

# From CLI menu, select option 13 for Web Panel
# Then select option 5 to download web files
# Finally select option 1 to start web panel
```

---

🎯 Quick Start Guide

CLI Mode

```bash
# Run the CLI tool
./nebula.sh

# Navigate through menu:
# 1. Create Container - Deploy new container
# 2. Enter Container - Access container shell
# 3-7. Container management operations
# 8. List all containers
# 9-12. Advanced features
# 13. Web Panel management
```

Web Panel Access

After starting the web panel (option 13 → 1), access it at:

· Local: http://localhost:3000
· Network: http://YOUR_SERVER_IP:3000

---

🏗️ Project Structure

```
Nebula-Docker/
├── nebula.sh                 # Main CLI tool
├── Dashboard/
│   ├── server.js             # Express server
│   ├── package.json          # Node.js dependencies
│   └── public/
│       ├── index.html        # Web dashboard
│       ├── style.css         # Dashboard styling
│       └── app.js            # Frontend logic
└── README.md                 # Documentation
```

---

🎨 Screenshots

<div align="center">
  <table>
    <tr>
      <td><img src="https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/assets/cli-menu.png" alt="CLI Menu"/></td>
      <td><img src="https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/assets/cli-create.png" alt="CLI Create"/></td>
    </tr>
    <tr>
      <td align="center"><b>CLI Main Menu</b></td>
      <td align="center"><b>Container Creation</b></td>
    </tr>
    <tr>
      <td><img src="https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/assets/web-dashboard.png" alt="Web Dashboard"/></td>
      <td><img src="https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/assets/web-create.png" alt="Web Create"/></td>
    </tr>
    <tr>
      <td align="center"><b>Web Dashboard</b></td>
      <td align="center"><b>Create Container Form</b></td>
    </tr>
  </table>
</div>

---

⚙️ Configuration

CLI Configuration

Configuration files are stored in ~/.nebula/:

· ~/.nebula/config.json - Main configuration
· ~/.nebula/nebula.log - Activity logs
· ~/.nebula/web/ - Web panel files
· ~/.nebula/backups/ - Container backups

Web Panel Configuration

· Port: 3000 (configurable in server.js)
· Auto-refresh: 5 seconds
· Logs: Available via PM2 (pm2 logs nebula-docker)

---

🔧 Advanced Usage

Backup Container

```bash
# Via CLI
./nebula.sh → Option 12

# Backup location: ~/.nebula/backups/
```

Execute Commands

```bash
# Run commands without entering container
./nebula.sh → Option 11

# Example: Check container disk usage
# Enter command: df -h
```

Custom Images

```bash
# During container creation, select option 15
# Enter your custom image, e.g.:
# - tensorflow/tensorflow:latest
# - mongo:latest
# - your-private-registry/image:tag
```

---

🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

---

📝 License

This project is dual-licensed:

🏢 Commercial License - MFSAVANA License 2.0

For commercial use, proprietary applications, or any usage that does not comply with the terms of the Apache License, a commercial license is required.

Commercial License Terms:

· Full ownership of the code
· No attribution required
· Priority support
· Custom modifications
· Redistribution rights

For commercial licensing inquiries, please contact: [Your Email]

🌐 Open Source License - Apache License 2.0

For open source and non-commercial use, this project is licensed under the Apache License, Version 2.0.

Apache License 2.0 Grants:

· ✅ Free use for personal and open source projects
· ✅ Modification allowed
· ✅ Distribution allowed
· ✅ Patent protection
· ❌ Commercial use requires commercial license

---

<div align="center" id="indonesian">

---

🇮🇩 Nebula Docker - Versi Indonesia

Sistem Manajemen Container Docker Premium

Nebula Docker adalah tools manajemen container Docker yang powerful dengan antarmuka CLI dan Web Dashboard yang modern. Dirancang untuk memudahkan pengelolaan container Docker layaknya mengelola VPS.

Fitur Unggulan

· Mudah Digunakan - CLI interaktif dengan warna dan menu yang jelas
· Dashboard Modern - Web panel dengan tema dark premium
· Multi OS Support - 15+ pilihan sistem operasi
· Resource Management - Atur CPU, RAM, dan disk
· Monitoring Real-time - Pantau resource container
· Backup & Restore - Cadangkan container dengan mudah

Cara Install

```bash
curl -o nebula.sh https://raw.githubusercontent.com/Qanz4Ever/Nebula-Docker/main/nebula.sh && chmod +x nebula.sh && ./nebula.sh
```

Kontak & Dukungan

· 📧 Email: [Your Email]
· 🐛 Issue Tracker: GitHub Issues
· 📱 Telegram: @Qanz4Ever

---

Created By © Mfsavana 2026 · GitHub · Report Bug

⭐ Star us on GitHub — it motivates us a lot!

</div>
