# Ubuntu Server Setup Script 🚀

![Bash](https://img.shields.io/badge/-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Ubuntu](https://img.shields.io/badge/-Ubuntu-E95420?logo=ubuntu&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

Automated setup script for Ubuntu servers that configures security, performance and essential tools with one command.

# ✨ Features

- ### 🔒 **Security Hardening**
  - SSH port change & root login disable
  - Fail2Ban protection
  - UFW firewall setup

- ### ⚡ **Performance Optimization**
  - Smart swap configuration (auto-sized)

- ### 🛠️ **Essential Tools**
  ```bash
  ssh, curl, wget, git, fail2ban, ufw, 
  net-tools, zip/unzip, tmux, htop, tree, ntp
  ```
- ### 👥 **User Management**
  - Create new sudo user
  - Secure password setup

- ### ⏰ **Time Synchronization**
  - Automatic NTP configuration
  - Moscow timezone setup

# 🚀 Installation

Run this single command as root:
`bash <(curl -fsSL https://raw.githubusercontent.com/jettmaiin/setup-ubuntu/main/setup.sh)`

Or with wget:
`bash <(wget -O- https://raw.githubusercontent.com/jettmaiin/setup-ubuntu/main/setup.sh)`

# 🛠️ Manual Setup
1. Download the script: `wget https://raw.githubusercontent.com/jettmaiin/setup-ubuntu/main/setup.sh`
2. Make it executable: `chmod +x setup.sh`
3. Run as root: `sudo ./setup.sh`

# 📜 License
```text
MIT License

Copyright (c) 2025 jettmaiin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
