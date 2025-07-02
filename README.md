# 🐳 jenkins-docker-limited

Run a lightweight, resource-constrained Jenkins server in Docker with persistent storage — perfect for development, testing, and CI/CD demos.

---

## 🚀 Features

- ✅ Launch Jenkins in a Docker container
- ✅ Limit memory usage (e.g., 500MB)
- ✅ Limit disk usage to a fixed size (e.g., 8GB) using a loopback volume
- ✅ Preserve Jenkins configuration, plugins, jobs, and credentials
- ✅ Easy-to-use, parameterized Bash script
- ✅ Compatible with Ubuntu, WSL, and Linux hosts

---

## 📦 Requirements

- [Docker](https://docs.docker.com/get-docker/) (tested with v24+)
- Bash shell (Ubuntu, Debian, or WSL)
- Tools: `fallocate`, `mkfs.ext4`, `mount`, `umount` (usually preinstalled)

---

## 🔧 Usage

### 🟢 Default (Port: 8080, RAM: 1GB, Disk: 8GB, Mount Dir: "$HOME/jenkins_volume")

```bash
bash run_jenkins_limited.sh
```

> Once started, open Jenkins at: [http://localhost:8080](http://localhost:8080)

### ⚙️ With Custom Options

```bash
bash run_jenkins_limited.sh --port 8090 --ram 500m --disk 8 --mount-dir ~/custom_jenkins_volume
```

| Flag          | Description                            | Example                |
|---------------|----------------------------------------|------------------------|
| `--port`      | Port to expose Jenkins Web UI          | `8090`                 |
| `--ram`       | RAM limit for the container            | `500m`, `1g`           |
| `--disk`      | Disk limit in GB                       | `8`                    |
| `--mount-dir` | Custom path to mount Jenkins volume    | `~/my_jenkins_data`    |

---

## 📁 What the Script Does

1. Pulls the latest `jenkins/jenkins:lts` Docker image
2. Creates a loopback disk image at `<mount-dir>/jenkins_volume.img` (default: `~/jenkins_volume.img`)
3. Mounts the image to the specified `--mount-dir` path
4. Runs the Jenkins container with:
    - RAM limit using Docker’s `--memory` flag
    - Disk limit using loopback-mounted volume
    - Persistent storage mapped to `/var/jenkins_home`
5. Automatically retains Jenkins data across restarts or container rebuilds

---

## 🔍 Monitor Usage

### Memory
```bash
docker stats jenkins
```

### Disk
```bash
df -h <your_mount_dir>
```

---

## 🧼 Cleanup

To completely stop and remove Jenkins and its data:

```bash
docker stop jenkins
docker rm jenkins
sudo umount <your_mount_dir>
rm -rf <your_mount_dir> <your_mount_dir>/jenkins_volume.img
```

---

## 📌 Optional Improvements

- Add auto-mount for loopback volume using `/etc/fstab`
- Extend script to:
    - Set CPU limits
    - Auto-install Jenkins plugins
    - Configure admin user via environment variables

---

## 📃 License

MIT License  
© 2025 [Sarang Surve](https://github.com/sarangsurve)

---

## 🙋‍♂️ Support & Contributions

Pull requests, feedback, and feature requests are welcome!

Feel free to [open an issue](https://github.com/sarangsurve/jenkins-docker-limited/issues) or contribute.
