"""
Bibliothèque de fonctions pour les arbres binaires

=======================================

Fonctions disponibles :
  - creer_arbre(n)              : crée un arbre binaire avec n sommets
  - parcours_prefixe(arbre)     : parcours préfixe (racine → gauche → droite)
  - parcours_infixe(arbre)      : parcours infixe  (gauche → racine → droite)
  - parcours_postfixe(arbre)    : parcours postfixe (gauche → droite → racine)
  - inserer_feuille(arbre, val) : insère une feuille (sans enfants)
  - inserer_branche(arbre, val) : insère une branche (noeud interne)
"""

from collections import deque

# Structure initiale du noeud
class Noeud:

    def __init__(self, valeur):
        self.valeur = valeur        # Valeur du noeud
        self.gauche = None          # Sous-arbre gauche
        self.droit  = None          # Sous-arbre droit

    def __repr__(self):
        return f"Noeud({self.valeur})"

# 1. Création d'un arbre binaire avec n sommets
def creer_arbre(n: int) -> Noeud | None:
    """
    Crée un arbre binaire complet avec n sommets numérotés de 1 à n.

    Principe : insertion niveau par niveau.
      - La racine recoit la valeur 1
      - Chaque noeud recoit un enfant gauche puis un enfant droit avec les valeurs suivantes

    Paramètre
    ---------
    n : int  — nombre de sommets souhaité (>= 0)

    Retourne
    --------
    La racine de l'arbre, ou None si n == 0.
    """

    if n <= 0:
        return None

    racine = Noeud(1)           # Premier noeud = racine
    file = deque([racine])      # File pour construire niveau par niveau
    val = 2                     # Prochaine valeur à insérer

    while val <= n:
        noeud_courant = file.popleft()

        # Enfant gauche
        if val <= n:
            noeud_courant.gauche = Noeud(val)
            file.append(noeud_courant.gauche)
            val += 1

        # Enfant droit
        if val <= n:
            noeud_courant.droit = Noeud(val)
            file.append(noeud_courant.droit)
            val += 1

    return racine

# 2. Parcours préfixe / racine → gauche → droite
def parcours_prefixe(arbre: Noeud | None) -> list:
    """
    Retourne la liste des valeurs en ordre préfixe.
    Ordre : noeud courant → sous-arbre gauche → sous-arbre droit.
    """

    if arbre is None:
        return []

    return (
        [arbre.valeur]
        + parcours_prefixe(arbre.gauche)
        + parcours_prefixe(arbre.droit)
    )

# 3. Parcours infixe / gauche → racine → droite
def parcours_infixe(arbre: Noeud | None) -> list:
    """
    Retourne la liste des valeurs en ordre infixe.
    Ordre : sous-arbre gauche → noeud courant → sous-arbre droit.
    Pour un arbre binaire de recherche, cela donne les valeurs triées.
    """
    if arbre is None:
        return []

    return (
        parcours_infixe(arbre.gauche)
        + [arbre.valeur]
        + parcours_infixe(arbre.droit)
    )

#  4. Parcours postfixe / gauche → droite → racine
def parcours_postfixe(arbre: Noeud | None) -> list:
    """
    Retourne la liste des valeurs en ordre postfixe.
    Ordre : sous-arbre gauche → sous-arbre droit → Nœud courant.
    Utile pour évaluer des expressions ou libérer la mémoire.
    """
    if arbre is None:
        return []

    return (
        parcours_postfixe(arbre.gauche)
        + parcours_postfixe(arbre.droit)
        + [arbre.valeur]
    )

# 5. Insertion d'une feuille
def inserer_feuille(arbre: Noeud | None, valeur) -> Noeud:
    """
    Insère une nouvelle feuille (noeud sans enfants) dans l'arbre.

    Stratégie : on cherche le premier emplacement libre niveau par niveau, pour maintenir l'arbre aussi complet que possible.

    Paramètres
    ----------
    arbre  : racine de l'arbre (peut être None → crée la racine)
    valeur : valeur à insérer

    Retourne
    --------
    La racine de l'arbre (inchangée sauf si l'arbre était vide).
    """
    nouvelle_feuille = Noeud(valeur)

    # Cas particulier : arbre vide → la feuille devient la racine
    if arbre is None:
        return nouvelle_feuille

    # Parcours pour trouver le premier noeud avec une place libre
    file = deque([arbre])

    while file:
        noeud = file.popleft()

        # Place libre à gauche
        if noeud.gauche is None:
            noeud.gauche = nouvelle_feuille
            return arbre
        else:
            file.append(noeud.gauche)

        # Place libre à droite
        if noeud.droit is None:
            noeud.droit = nouvelle_feuille
            return arbre
        else:
            file.append(noeud.droit)

    return arbre

# 5. Insertion d'une branche
def inserer_branche(arbre: Noeud | None, valeur,
                    gauche: Noeud | None = None,
                    droit:  Noeud | None = None) -> Noeud:
    """
    Insère un noeud interne (branche) avec des sous-arbres optionnels.

    Le nouveau noeud est placé au premier emplacement libre, puis ses enfants gauche/droit sont attachés.
    Si l'emplacement était déjà occupé par un sous-arbre, ce sous-arbre devient l'enfant gauche du nouveau nœud (préservation de structure).

    Paramètres
    ----------
    arbre  : racine de l'arbre (peut être None → crée la racine)
    valeur : valeur du nouveau noeud interne
    gauche : sous-arbre à attacher à gauche  (facultatif)
    droit  : sous-arbre à attacher à droite  (facultatif)

    Retourne
    --------
    La racine de l'arbre.
    """
    nouvelle_branche = Noeud(valeur)
    nouvelle_branche.gauche = gauche
    nouvelle_branche.droit  = droit

    # Arbre vide → la branche devient la racine
    if arbre is None:
        return nouvelle_branche

    # Recherche du premier emplacement libre
    file = deque([arbre])

    while file:
        noeud = file.popleft()

        if noeud.gauche is None:
            noeud.gauche = nouvelle_branche
            return arbre
        else:
            file.append(noeud.gauche)

        if noeud.droit is None:
            noeud.droit = nouvelle_branche
            return arbre
        else:
            file.append(noeud.droit)

    return arbre


# Utilitaire : affichage visuel de l'arbre
def afficher_arbre(arbre: Noeud | None) -> None:
    """
    Affiche l'arbre de manière verticale et lisible dans la console.
    """
    if arbre is None:
        print("(arbre vide)")
        return

    def _construire_lignes(noeud):
        # Cas 1 : C'est une feuille (aucun enfant)
        if noeud.gauche is None and noeud.droit is None:
            ligne = str(noeud.valeur)
            largeur = len(ligne)
            hauteur = 1
            milieu = largeur // 2
            return [ligne], largeur, hauteur, milieu

        # Cas 2 : Uniquement un enfant gauche
        if noeud.droit is None:
            lignes, n, p, x = _construire_lignes(noeud.gauche)
            s = str(noeud.valeur)
            u = len(s)
            premiere_ligne = (x + 1) * ' ' + (n - x - 1) * '_' + s
            deuxieme_ligne = x * ' ' + '/' + (n - x - 1 + u) * ' '
            lignes_decalees = [ligne + u * ' ' for ligne in lignes]
            return [premiere_ligne, deuxieme_ligne] + lignes_decalees, n + u, p + 2, n + u // 2

        # Cas 3 : Uniquement un enfant droit
        if noeud.gauche is None:
            lignes, n, p, x = _construire_lignes(noeud.droit)
            s = str(noeud.valeur)
            u = len(s)
            premiere_ligne = s + x * '_' + (n - x) * ' '
            deuxieme_ligne = (u + x) * ' ' + '\\' + (n - x - 1) * ' '
            lignes_decalees = [u * ' ' + ligne for ligne in lignes]
            return [premiere_ligne, deuxieme_ligne] + lignes_decalees, n + u, p + 2, u // 2

        # Cas 4 : Deux enfants (gauche et droit)
        gauche, n, p, x = _construire_lignes(noeud.gauche)
        droit, m, q, y = _construire_lignes(noeud.droit)
        s = str(noeud.valeur)
        u = len(s)
        premiere_ligne = (x + 1) * ' ' + (n - x - 1) * '_' + s + y * '_' + (m - y) * ' '
        deuxieme_ligne = x * ' ' + '/' + (n - x - 1 + u + y) * ' ' + '\\' + (m - y - 1) * ' '
        
        if p < q:
            gauche += [n * ' '] * (q - p)
        elif q < p:
            droit += [m * ' '] * (p - q)
            
        lignes_fusionnees = zip(gauche, droit)
        lignes = [premiere_ligne, deuxieme_ligne] + [a + u * ' ' + b for a, b in lignes_fusionnees]
        return lignes, n + m + u, max(p, q) + 2, n + u // 2

    lignes, *_ = _construire_lignes(arbre)
    for ligne in lignes:
        print(ligne)

#  Programme exemple pour démonstration
if __name__ == "__main__":

    print("=" * 55)
    print("Démonstration de manipulation d'arbres binaires")
    print("=" * 55)

    # ── Création
    print("\n- Création d'un arbre binaire avec 7 sommets")
    arbre = creer_arbre(7)
    afficher_arbre(arbre)

    # ── Parcours
    print("\n- Parcours de l'arbre")
    print(f"  Préfixe  : {parcours_prefixe(arbre)}")
    print(f"  Infixe   : {parcours_infixe(arbre)}")
    print(f"  Postfixe : {parcours_postfixe(arbre)}")

    # ── Insertion d'une feuille
    print("\n- Insertion d'une feuille (valeur = 8)")
    arbre = inserer_feuille(arbre, 8)
    afficher_arbre(arbre)

    # ── Insertion d'une branche
    print("\n- Insertion d'une branche (valeur = 9, avec enfant gauche = 10)")
    enfant = Noeud(10)
    arbre = inserer_branche(arbre, 9, gauche=enfant)
    afficher_arbre(arbre)

    # ── Arbre vide
    print("\n- Tests sur un arbre vide")
    print(f"  creer_arbre(0)      → {creer_arbre(0)}")
    print(f"  parcours_prefixe    → {parcours_prefixe(None)}")
    print(f"  inserer_feuille(42) → {inserer_feuille(None, 42)}")