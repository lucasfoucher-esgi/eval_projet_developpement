# Environnement de Développement ML — Guide du projet

**Projet de développement en équipe — Algorithmique avancée 2025-2026**
Enseignant : T. Thaureaux | Groupes de 3-4 étudiants

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Partie 1 — Environnement Python ML](#2-partie-1--environnement-python-ml)
3. [Partie 2 — Bibliothèques algorithmiques du TP](#3-partie-2--bibliothèques-algorithmiques-du-tp)
4. [Partie 3 — Outils de qualité du code](#4-partie-3--outils-de-qualité-du-code)
5. [Partie 4 — Containerisation avec Docker](#5-partie-4--containerisation-avec-docker)
6. [Partie 5 — Script de déploiement](#6-partie-5--script-de-déploiement)
7. [Partie 6 — Mise à disposition via GitHub](#7-partie-6--mise-à-disposition-via-github)
8. [Partie 7 — VM Linux prête à l'emploi](#8-partie-7--vm-linux-prête-à-lemploi)
9. [Partie 8 — Réseau SDN avec ContainerLab](#9-partie-8--réseau-sdn-avec-containerlab)
10. [Structure du projet & commandes utiles](#10-structure-du-projet--commandes-utiles)

---

## 1. Vue d'ensemble

L'objectif est de livrer un **environnement de développement complet, reproductible et distribuable** qui couvre :

```
GitHub (source unique de vérité)
│
├── Docker  →  JupyterLab prêt en 1 commande
├── VM      →  Ubuntu 22.04 avec tout préinstallé
└── ContainerLab → Réseau SDN simulé autour du serveur ML
```

**Ce que contient l'environnement :**

| Composant | Contenu |
|---|---|
| Bibliothèques ML | NumPy · Scikit-learn · Matplotlib |
| Bibliothèques TP | arbres_binaires · matrice · structures_donnees |
| Outils qualité | Pylint · Bandit · Radon |
| Interface | JupyterLab (port 8888) |
| Réseau simulé | 2 routeurs FRR + 4 clients + serveur ML |

---

## 2. Partie 1 — Environnement Python ML

### Pourquoi ces 3 bibliothèques ?

Les trois bibliothèques ont été choisies pour former une **chaîne de traitement complète et cohérente**, du calcul brut à la présentation des résultats :

```
NumPy          →      Scikit-learn     →      Matplotlib
(données)            (modèle ML)              (graphique)
```

Chacune remplit un rôle que les deux autres ne couvrent pas.

### NumPy — Calcul numérique

**Rôle :** Fondation de tout l'écosystème ML. Fournit les tableaux N-dimensionnels (`ndarray`), l'algèbre linéaire, et les opérations vectorisées ultra-rapides. Scikit-learn et Matplotlib l'utilisent en interne.

```python
import numpy as np

# Créer un tableau et faire du calcul vectorisé
donnees = np.array([1, 2, 3, 4, 5])
print(donnees.mean())   # 3.0
print(donnees ** 2)     # [1, 4, 9, 16, 25]

# Générer des données d'entraînement
X = np.random.rand(100, 2)   # 100 exemples, 2 features
```

### Scikit-learn — Machine Learning

**Rôle :** Fournit les algorithmes ML entraînables (classification, régression, clustering) ainsi que les outils de pipeline, de validation croisée et les métriques. C'est la bibliothèque ML classique de référence en Python.

```python
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

modele = KNeighborsClassifier(n_neighbors=3)
modele.fit(X_train, y_train)

predictions = modele.predict(X_test)
print(f"Précision : {accuracy_score(y_test, predictions):.2%}")
```

### Matplotlib — Visualisation

**Rôle :** Complémentaire aux deux autres : elle rend les résultats lisibles. Sans visualisation, les données NumPy et les prédictions Scikit-learn restent des chiffres abstraits.

```python
import matplotlib.pyplot as plt

# Visualiser les données et les prédictions
plt.scatter(X_test[:, 0], X_test[:, 1], c=predictions, cmap='viridis')
plt.title("Résultat de la classification KNN")
plt.colorbar(label="Classe prédite")
plt.savefig("resultats.png")
plt.show()
```

### Installation (hors Docker)

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 3. Partie 2 — Bibliothèques algorithmiques du TP

Les trois bibliothèques développées en TP d'Algorithmique avancée sont placées dans `libs/` et disponibles dans le conteneur via `PYTHONPATH=/workspace/libs`.

### Contenu de libs/

| Fichier | Structures et fonctions clés |
|---|---|
| `arbres_binaires.py` | `creer_arbre`, `parcours_prefixe/infixe/postfixe`, `inserer_feuille`, `inserer_branche`, `afficher_arbre` |
| `matrice.py` | `creer_matrice`, `addition_matrices`, `multiplication_matrices`, `operation_matrices` |
| `structures_donnees.py` | Piles (`empiler/depiler`), Files (`ajouter/retirer`), Listes chaînées (`inserer/supprimer`), `rechercher` |

### Utilisation dans JupyterLab

```python
# PYTHONPATH est déjà configuré dans le conteneur → import direct
from arbres_binaires import creer_arbre, parcours_infixe, afficher_arbre
from matrice import creer_matrice, operation_matrices
from structures_donnees import pile_creer, empiler, depiler

# Exemple : arbre binaire de 7 nœuds
arbre = creer_arbre(7)
afficher_arbre(arbre)
# Résultat :   1
#            /   \
#           2     3
#          / \ / \
#         4  5 6  7

print(parcours_infixe(arbre))   # [4, 2, 5, 1, 6, 3, 7]

# Exemple : opération matricielle
A = creer_matrice(3, 3, fill='random')
B = creer_matrice(3, 3, fill='random')
R = operation_matrices(A, B, 'x')   # Produit matriciel
```

---

## 4. Partie 3 — Outils de qualité du code

### Pourquoi ces 3 outils ?

Chaque outil répond à une question **différente** sur la qualité du code :

| Outil | Question posée | Dimension |
|---|---|---|
| **Pylint** | *Le code est-il bien écrit ?* | Style & erreurs statiques |
| **Bandit** | *Le code est-il sûr ?* | Sécurité |
| **Radon** | *Le code est-il simple à maintenir ?* | Complexité |

Ils sont **complémentaires** : un code peut avoir un Pylint parfait (10/10) mais contenir une faille Bandit, ou être lisible mais d'une complexité cyclomatique excessive selon Radon.

### Pylint — Style & erreurs statiques

**Ce qu'il fait :** Analyse le code sans l'exécuter. Détecte les erreurs de logique, les variables non utilisées, les imports manquants, les non-conformités PEP8. Attribue un score de **0 à 10**.

**Configuration :** `config/.pylintrc` — longueur max 100 caractères, seuils de complexité adaptés au code pédagogique.

```bash
# Analyser le dossier libs
pylint libs/ --rcfile=config/.pylintrc

# Exemple de sortie
# libs/matrice.py:45:0: W0611: Unused import random (unused-import)
# Your code has been rated at 9.52/10
```

### Bandit — Sécurité

**Ce qu'il fait :** Recherche dans le code les **patterns de vulnérabilité connus** (injections, mots de passe en dur, utilisation de fonctions cryptographiquement faibles, exécution de commandes système non sécurisée…). Classe chaque problème par sévérité (LOW / MEDIUM / HIGH) et confiance.

**Configuration :** `config/bandit.yaml` — exclut `B101` (assert, acceptable en pédagogie) et `B311` (random, non cryptographique mais attendu ici).

```bash
bandit -r libs/ --configfile config/bandit.yaml

# Exemple de sortie
# >> Issue: [B324:hashlib] Use of weak MD5 hash considered insecure.
#    Severity: Medium   Confidence: High
```

### Radon — Complexité

**Ce qu'il fait :** Calcule deux métriques complémentaires :

- **Complexité cyclomatique (CC)** : compte le nombre de chemins d'exécution indépendants dans une fonction. Plus c'est élevé, plus la fonction est difficile à tester.
- **Indice de maintenabilité (MI)** : score global qui combine complexité, volume de code et documentation. De A (excellent) à C (à refactorer).

```bash
# Complexité cyclomatique — note A (1-5) à F (>25)
radon cc libs/ --min B --show-complexity --average

# Exemple de sortie
# libs/arbres_binaires.py
#     F afficher_arbre:174 - B (6)   ← complexité modérée, acceptable
#     F creer_arbre:35    - A (3)    ← très simple

# Indice de maintenabilité
radon mi libs/ --show
# libs/matrice.py - A (85.23)
```

**Grille de complexité cyclomatique :**
```
A (1-5)   Faible  — facile à tester, idéal
B (6-10)  Modéré  — acceptable
C (11-15) Élevé   — à surveiller
D+        Critique — refactoring recommandé
```

### Lancement unifié

```bash
# Depuis l'hôte, via le conteneur Docker
docker exec jupyter-ml check_quality

# Ou cibler un fichier spécifique
docker exec jupyter-ml check_quality /workspace/libs/matrice.py

# Les rapports texte sont sauvegardés dans /workspace/quality_reports/
```

---

## 5. Partie 4 — Containerisation avec Docker

### Choix de la distribution : Ubuntu 22.04 LTS

**Ubuntu 22.04 LTS (Jammy)** a été retenu pour les raisons suivantes :

| Critère | Ubuntu 22.04 LTS | Debian 12 |
|---|---|---|
| Support | Jusqu'en **2027** | Jusqu'en 2028 |
| Compatibilité NumPy/Scikit | **Officielle** | Bonne |
| Binaires précompilés pip | Très nombreux | Nombreux |
| Communauté & documentation | **Très large** | Large |

Ubuntu 22.04 LTS est recommandée officiellement par NumPy et Scikit-learn, ce qui évite les compilations manuelles et les conflits de dépendances.

### Architecture du Dockerfile

```
FROM ubuntu:22.04
│
├─ Variables ENV (UTF-8, pas de fichiers .pyc, pip silencieux)
├─ Dépendances système : python3.11, git, curl, build-essential
├─ pip install --upgrade pip
├─ WORKDIR /workspace
├─ COPY config/.pylintrc + bandit.yaml
├─ COPY requirements.txt → pip install (NumPy, Scikit-learn, Matplotlib…)
├─ COPY libs/             → bibliothèques TP
├─ COPY check_quality.sh  → /usr/local/bin/check_quality
└─ EXPOSE 8888
   CMD jupyter lab --ip=0.0.0.0 --no-browser --allow-root
```

### Construire et lancer

```bash
# Construction de l'image (5-10 min au premier lancement)
docker compose build

# Démarrage en arrière-plan
docker compose up -d

# Accès à JupyterLab
# → http://localhost:8888

# Arrêt propre
docker compose down
```

### Points clés du docker-compose.yml

```yaml
volumes:
  - jupyter_work:/workspace/work   # Travail persistant entre redémarrages
  - ./libs:/workspace/libs:ro      # Montage live : modifications sans rebuild

environment:
  - PYTHONPATH=/workspace/libs     # Import direct des bibliothèques TP
```

Le volume `jupyter_work` assure que les notebooks créés dans JupyterLab survivent aux redémarrages du conteneur. Le montage `:ro` (read-only) de `libs/` permet de modifier les bibliothèques sur l'hôte et de voir les changements immédiatement dans le conteneur.

---

## 6. Partie 5 — Script de déploiement

Le script `scripts/deploy.sh` automatise le déploiement complet en **5 étapes séquentielles** :

```
deploy.sh
│
├─ [1] Vérification des prérequis
│       docker, git, curl présents ?
│       Espace disque ≥ 20 Go ?
│
├─ [2] Récupération du code
│       Dépôt déjà cloné → git pull
│       Sinon            → git clone
│
├─ [3] Construction de l'image Docker
│       docker compose build --no-cache
│
├─ [4] Démarrage des services
│       docker compose up -d
│       Attente healthcheck JupyterLab (curl /api)
│
└─ [5] Résumé
        URL d'accès : http://localhost:8888
        Commandes utiles rappelées
```

```bash
# Déploiement complet (clonage + build + démarrage)
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Arrêt propre des services
./scripts/deploy.sh --stop

# Nettoyage complet (supprime l'image et les volumes)
./scripts/deploy.sh --clean
```

---

## 7. Partie 6 — Mise à disposition via GitHub

### Initialisation

```bash
git init
git add .
git commit -m "Initial commit — environnement ML"
git remote add origin https://github.com/VOTRE_ORG/projet-env-dev.git
git push -u origin main
```

### Un développeur qui rejoint l'équipe

```bash
# Une seule commande suffit pour avoir l'environnement complet
git clone https://github.com/VOTRE_ORG/projet-env-dev.git
cd projet-env-dev
./scripts/deploy.sh
# → JupyterLab disponible sur http://localhost:8888
```

### Conventions de commits

```bash
git commit -m "feat(libs): ajout hauteur_arbre dans arbres_binaires"
git commit -m "fix(docker): correction du healthcheck"
git commit -m "docs(readme): mise à jour partie ContainerLab"
```

### .gitignore — Ce qui n'est pas versionné

```
__pycache__/, *.pyc     ← fichiers compilés Python
.venv/, venv/           ← environnements virtuels locaux
quality_reports/        ← rapports générés (temporaires)
clab-reseau-dev-ml/     ← dossier généré par ContainerLab
*.log                   ← journaux
```

---

## 8. Partie 7 — VM Linux prête à l'emploi

### Choix : Ubuntu 22.04 LTS Desktop

Même distribution que le Docker pour la cohérence, avec l'interface graphique GNOME pour une utilisation plus accessible.

### Script de provisionnement (`scripts/vm_setup.sh`)

Ce script transforme une installation fraîche d'Ubuntu 22.04 en environnement de développement complet :

```bash
#!/usr/bin/env bash
# À exécuter en root sur une Ubuntu 22.04 fraîche

# 1. Mise à jour du système
apt-get update && apt-get upgrade -y

# 2. Installation de Docker
curl -fsSL https://get.docker.com | bash
usermod -aG docker $SUDO_USER
systemctl enable docker

# 3. Installation de ContainerLab
bash -c "$(curl -sL https://get.containerlab.dev)"

# 4. Clonage du dépôt et déploiement
sudo -u $SUDO_USER git clone \
    https://github.com/VOTRE_ORG/projet-env-dev.git \
    /home/$SUDO_USER/projet-env-dev

cd /home/$SUDO_USER/projet-env-dev
sudo -u $SUDO_USER ./scripts/deploy.sh

echo "VM prête → http://localhost:8888"
```

### Distribution de la VM

**Option recommandée — Vagrant** (reproductible, versionnable) :

```ruby
# Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus   = 2
  end
  config.vm.provision "shell", path: "scripts/vm_setup.sh"
end
```

```bash
vagrant up      # Crée et provisionne la VM automatiquement
vagrant ssh     # Connexion SSH
vagrant halt    # Arrêt de la VM
```

---

## 9. Partie 8 — Réseau SDN avec ContainerLab

### Qu'est-ce que ContainerLab ?

ContainerLab est un outil qui crée des **réseaux virtuels complets avec Docker**. La topologie est définie dans un fichier YAML — c'est de l'Infrastructure as Code. Avantage par rapport à GNS3 : tout tourne dans des conteneurs, déploiement en secondes.

### Architecture du réseau

```
   [client1] ──┐                     ┌── [client3]
  192.168.1/24 │                     │  192.168.3/24
               ├── [routeur1] ─────── [routeur2] ┤
   [client2] ──┘   10.0.0.0/30      └── [client4]
  192.168.2/24 │                        192.168.4/24
               │
          [serveur-ml]   ←  notre image projet-ml:latest
           10.10.0.2          JupyterLab port 8888
```

**Nœuds :**
- `routeur1`, `routeur2` : routeurs Linux avec FRR (protocole OSPF)
- `client1` à `client4` : postes clients Linux (`network-multitool`)
- `serveur-ml` : notre image Docker `projet-ml:latest`

### Déploiement

```bash
# Prérequis : image projet-ml déjà construite
docker images | grep projet-ml

# Déployer le réseau (nécessite sudo)
sudo ./scripts/deploy_containerlab.sh

# Vérifier l'état
sudo clab inspect --topo containerlab/topology.clab.yml

# Générer un schéma graphique du réseau
sudo ./scripts/deploy_containerlab.sh --graph
# → http://localhost:50080
```

### Tests de connectivité

```bash
# Accéder au routeur1 et voir les routes
docker exec -it clab-reseau-dev-ml-routeur1 vtysh
routeur1# show ip route

# Ping depuis client1 vers client3 (passe par les 2 routeurs)
docker exec clab-reseau-dev-ml-client1 ping -c 4 192.168.3.1

# Accéder au serveur ML depuis le réseau simulé
docker exec clab-reseau-dev-ml-client1 curl http://10.10.0.2:8888/api
```

### Destruction

```bash
sudo ./scripts/deploy_containerlab.sh --destroy
```

---

## 10. Structure du projet & commandes utiles

### Arborescence complète

```
projet-env-dev/
│
├── README.md                    ← Ce fichier
├── Dockerfile                   ← Ubuntu 22.04 + Python ML
├── docker-compose.yml           ← Service JupyterLab
├── requirements.txt             ← NumPy · Scikit-learn · Matplotlib + outils
├── .gitignore
│
├── libs/                        ← Bibliothèques TP algorithmique
│   ├── arbres_binaires.py
│   ├── matrice.py
│   └── structures_donnees.py
│
├── config/                      ← Configuration des outils qualité
│   ├── .pylintrc                ← Pylint (style, longueur max 100)
│   └── bandit.yaml              ← Bandit (exclusions pédagogiques)
│
├── scripts/
│   ├── deploy.sh                ← Déploiement Docker (5 étapes)
│   ├── deploy_containerlab.sh   ← Déploiement réseau SDN
│   └── check_quality.sh         ← Pylint + Bandit + Radon
│
└── containerlab/
    └── topology.clab.yml        ← Topologie réseau (2 routeurs, 4 clients, serveur ML)
```

### Référence des commandes

**Docker**
```bash
./scripts/deploy.sh                    # Déploiement complet
./scripts/deploy.sh --stop             # Arrêt
./scripts/deploy.sh --clean            # Nettoyage total
docker exec -it jupyter-ml bash        # Shell dans le conteneur
docker exec jupyter-ml check_quality   # Analyse qualité des 3 libs TP
```

**Qualité du code**
```bash
pylint libs/ --rcfile=config/.pylintrc     # Style & erreurs (score /10)
bandit -r libs/ --configfile config/bandit.yaml  # Sécurité
radon cc libs/ --min B --average           # Complexité cyclomatique
radon mi libs/ --show                      # Indice de maintenabilité
```

**ContainerLab**
```bash
sudo ./scripts/deploy_containerlab.sh            # Déployer le réseau SDN
sudo ./scripts/deploy_containerlab.sh --graph    # Schéma graphique
sudo ./scripts/deploy_containerlab.sh --destroy  # Supprimer le réseau
```

---

*Projet de développement en équipe — Algorithmique avancée 2025-2026*
