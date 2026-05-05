# ============================================================
# Dockerfile — Environnement de développement ML
# Base : Python 3.11 sur Ubuntu 22.04 (Jammy)
#
# Choix de la distribution :
#   Ubuntu 22.04 LTS — support jusqu'en 2027, recommandée
#   officiellement par Scikit-learn et NumPy. La version LTS
#   garantit stabilité et mises à jour de sécurité longue
#   durée, essentiel pour un environnement de développement.
# ============================================================

FROM ubuntu:22.04

LABEL maintainer="projet-dev-ml"
LABEL description="Environnement de développement Python"
LABEL version="1.0"

# ---- Variables d'environnement ----
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ---- 1. Dépendances système ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3-pip \
    python3.11-venv \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Alias python → python3.11
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# ---- 2. Mise à jour pip ----
RUN pip install --upgrade pip setuptools wheel

# ---- 3. Répertoire de travail ----
WORKDIR /workspace

# ---- 4. Copie des fichiers de configuration qualité ----
COPY .pylintrc   /workspace/.pylintrc
COPY bandit.yaml /workspace/bandit.yaml

# ---- 5. Installation des dépendances Python ----
COPY requirements.txt /workspace/requirements.txt
RUN pip install -r requirements.txt

# ---- 6. Copie des bibliothèques algorithmiques du TP ----
COPY libs/ /workspace/libs/

# ---- 7. Script de vérification qualité ----
COPY check_quality.sh /usr/local/bin/check_quality
RUN chmod +x /usr/local/bin/check_quality

# ---- 8. Port JupyterLab ----
EXPOSE 8888

# ---- 9. Point d'entrée : JupyterLab ----
CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--allow-root", \
     "--NotebookApp.token=''", \
     "--NotebookApp.password=''"]
