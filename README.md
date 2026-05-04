# Multi-VM DevOps Tutorial: Web → API → Database with Vagrant

> A minimal but realistic 3-tier application running across three Vagrant VMs that communicate over a private network using IP addresses and ports.

This project is the natural next step after learning **virtualization, Linux fundamentals, Vagrant, and networking basics**. By the end, students will have:

- Provisioned three independent Linux VMs from a single `Vagrantfile`
- Configured services (Nginx, Node.js, PostgreSQL) to listen on the right interfaces
- Made services on different VMs talk to each other over a private network
- Used real DevOps tools (`systemd`, `pg_hba.conf`, Nginx reverse proxy) to glue everything together
- Verified connectivity at every layer using `ping`, `ss`, `curl`, and `psql`

---

## 1. What you're building

A classic 3-tier "tasks" app where each tier runs on its own VM:

```
                         Host machine (your laptop)
                         http://localhost:8080
                                 │
         ┌───────────────────────┼───────────────────────┐
         │     VirtualBox private network 192.168.56.0/24 │
         │                                                │
         │   ┌─────────────┐   ┌─────────────┐   ┌──────────────┐
         │   │   web VM    │   │   api VM    │   │    db VM     │
         │   │ 192.168.56.10│──▶│192.168.56.11│──▶│192.168.56.12 │
         │   │             │   │             │   │              │
         │   │ Nginx :80   │   │ Node.js:3000│   │ Postgres:5432│
         │   │ static HTML │   │ Express API │   │  appdb       │
         │   │ + /api/ proxy│  │   pg client │   │  tasks table │
         │   └─────────────┘   └─────────────┘   └──────────────┘
         └────────────────────────────────────────────────────────┘
```

### Tier responsibilities

| Tier   | VM hostname | Private IP       | Port  | Software       |
|--------|-------------|------------------|-------|----------------|
| Web    | `web`       | `192.168.56.10`  | `80`  | Nginx          |
| API    | `api`       | `192.168.56.11`  | `3000`| Node.js + Express |
| DB     | `db`        | `192.168.56.12`  | `5432`| PostgreSQL 14  |

### Request flow

1. Your browser hits `http://localhost:8080` → forwarded by Vagrant to `web:80`
2. Nginx serves `index.html` (static frontend)
3. The page makes `fetch('/api/tasks')` calls
4. Nginx reverse-proxies `/api/*` to `http://192.168.56.11:3000/*` (the API VM)
5. The Node.js API queries PostgreSQL at `192.168.56.12:5432`
6. The data flows back: db → api → web → browser

---

## 2. Prerequisites

Students should have installed (covered in your earlier modules):

- **VirtualBox** 7.x — https://www.virtualbox.org/
- **Vagrant** 2.4+ — https://www.vagrantup.com/
- ~6 GB free RAM (each VM uses 512 MB)
- ~10 GB free disk space

Verify:

```bash
vagrant --version
VBoxManage --version
```

---

## 3. Project layout

```
multi-vm-app/
├── Vagrantfile              # Defines all 3 VMs and their networking
├── provision/
│   ├── db.sh                # PostgreSQL install + DB setup
│   ├── api.sh               # Node.js install + service registration
│   └── web.sh               # Nginx install + reverse-proxy config
├── api/
│   ├── server.js            # Express API code
│   └── package.json         # Node.js dependencies
└── web/
    └── index.html           # Static frontend
```

Vagrant automatically mounts the project folder as `/vagrant` inside every VM. That's how the provisioning scripts copy the application code in.

---

## 4. The Vagrantfile, explained

The `Vagrantfile` is just Ruby — three `config.vm.define` blocks, one per VM. The key parts to teach:

```ruby
config.vm.box = "ubuntu/jammy64"   # Ubuntu 22.04 LTS for everyone
```

Each VM block defines four things:

```ruby
config.vm.define "db" do |db|
  db.vm.hostname = "db"                                        # 1. hostname inside the VM
  db.vm.network "private_network", ip: "192.168.56.12"         # 2. static IP on private net
  db.vm.provider "virtualbox" do |vb|                          # 3. VM resources
    vb.memory = 512
    vb.cpus   = 1
  end
  db.vm.provision "shell", path: "provision/db.sh"             # 4. provisioning script
end
```

The web VM has one extra line — a port forward so you can reach it from the host browser:

```ruby
web.vm.network "forwarded_port", guest: 80, host: 8080
```

> **Teaching point:** The API and DB VMs deliberately have *no* port forwarding. They are not exposed to the host — they're only reachable from inside the private network. This mirrors how real production architectures isolate backend services.

---
