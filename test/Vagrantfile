# =============================================================
# Vagrantfile — VM Ubuntu 24.04 LTS prête à l'emploi
#
# Prérequis hôte :
#   - VirtualBox  : https://www.virtualbox.org/wiki/Downloads
#   - Vagrant     : https://developer.hashicorp.com/vagrant/downloads
#
# Démarrage :
#   vagrant up            # crée et provisionne la VM (premier lancement ~5 min)
#   vagrant ssh           # ouvre un shell dans la VM
#   vagrant halt          # arrête la VM
#   vagrant destroy -f    # supprime la VM
#
# Accès à JupyterLab depuis l'hôte → http://localhost:8888
# =============================================================

Vagrant.configure("2") do |config|

  # ── Image de base ──────────────────────────────────────────
  config.vm.box     = "ubuntu/noble64"   # Ubuntu 24.04 LTS
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/noble64"

  # ── Réseau ─────────────────────────────────────────────────
  # Redirection du port JupyterLab vers l'hôte
  config.vm.network "forwarded_port", guest: 8888, host: 8888, host_ip: "127.0.0.1"
  # Réseau privé pour accès direct à la VM si nécessaire
  config.vm.network "private_network", ip: "192.168.56.10"

  # ── Ressources VirtualBox ──────────────────────────────────
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "env-dev-ml"
    vb.memory = "4096"        # 4 Go RAM (minimum recommandé pour Docker + ML)
    vb.cpus   = 2
    vb.gui    = false

    # Améliore les performances disque
    vb.customize ["storagectl", :id,
                  "--name", "SATA Controller",
                  "--hostiocache", "on"] rescue nil
  end

  # ── Nom d'hôte de la VM ────────────────────────────────────
  config.vm.hostname = "env-dev-ml"

  # ── Synchronisation du dossier hôte → VM ──────────────────
  # Le dossier courant est monté dans /vagrant (comportement Vagrant par défaut)
  # Désactivé ici car le dépôt sera cloné directement dans la VM
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # ── Provisionnement (exécuté une seule fois à vagrant up) ──
  config.vm.provision "shell", path: "provision.sh", privileged: false

end
