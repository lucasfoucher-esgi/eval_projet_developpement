"""
Bibliothèque de fonctions pour les piles, files et listes chainées

=======================================
"""

# ==
# Bibiliothèque de fonctions pour les piles.
# ==

# Crée et retourne une pile vide.
def pile_creer():
    return []

# Retourne True si la pile est vide, False sinon
def pile_vide(pile):
    return len(pile) == 0

# Empile un élément au sommet de la pile.
def empiler(pile, element):
    pile.append(element)

# Dépile et retourne l'élément au sommet de la pile (lève une exception si la pile est vide).
def depiler(pile):
    if pile_vide(pile):
        raise IndexError("Impossible de dépiler : la pile est vide.")
    return pile.pop()

# Retourne l'élément au sommet sans le retirer.
def sommet(pile):
    if pile_vide(pile):
        raise IndexError("La pile est vide.")
    return pile[-1]

# Retourne le nombre d'éléments dans la pile.
def pile_taille(pile):
    return len(pile)

# Affiche la pile du sommet vers le bas.
def pile_afficher(pile):
    if pile_vide(pile):
        print("Pile : []")
    else:
        print("Pile (sommet → bas) :", list(reversed(pile)))


# ==
# Bibiliothèque de fonctions pour les files.
# ==

# Crée et retourne une file vide.
def file_creer():
    return []

# Retourne True si la file est vide, False sinon.
def file_vide(file):
    return len(file) == 0

# Ajoute un élément en queue de file (enfile).
def ajouter(file, element):
    file.append(element)

# Retire et retourne l'élément en tête de file (défile) (lève une exception si la file est vide).
def retirer(file):
    if file_vide(file):
        raise IndexError("Impossible de retirer : la file est vide.")
    return file.pop(0)

# Retourne l'élément en tête sans le retirer.
def tete(file):
    if file_vide(file):
        raise IndexError("La file est vide.")
    return file[0]

# Retourne le nombre d'éléments dans la file.
def file_taille(file):
    return len(file)

# Affiche la file de la tête vers la queue.
def file_afficher(file):
    if file_vide(file):
        print("File : []")
    else:
        print("File (tête → queue) :", file)


# ==
# Bibiliothèque de fonctions pour les listes chainées.
# ==

# Représente un noeud d'une liste chaînée.
class Noeud:
    def __init__(self, valeur):
        self.valeur = valeur
        self.suivant = None

# Crée et retourne une liste chaînée vide (None = tête vide).
def liste_creer():
    return None

# Retourne True si la liste est vide.
def liste_vide(tete):
    return tete is None

# Insère un élément en tête de liste + retourne la nouvelle tête.
def liste_inserer_tete(tete, valeur):
    nouveau = Noeud(valeur)
    nouveau.suivant = tete
    return nouveau

# Insère un élément en fin de liste + retourne la tête (inchangée sauf si liste vide).
def liste_inserer_fin(tete, valeur):
    nouveau = Noeud(valeur)
    if liste_vide(tete):
        return nouveau
    courant = tete
    while courant.suivant is not None:
        courant = courant.suivant
    courant.suivant = nouveau
    return tete

# Insère un élément à la position donnée (0 = tête) + retourne la nouvelle tête.
def liste_inserer_position(tete, valeur, position):
    if position == 0:
        return liste_inserer_tete(tete, valeur)
    nouveau = Noeud(valeur)
    courant = tete
    for _ in range(position - 1):
        if courant is None:
            raise IndexError("Position hors limites.")
        courant = courant.suivant
    if courant is None:
        raise IndexError("Position hors limites.")
    nouveau.suivant = courant.suivant
    courant.suivant = nouveau
    return tete

# Supprime l'élément en tête + retourne la nouvelle tête.
def liste_supprimer_tete(tete):
    if liste_vide(tete):
        raise IndexError("Impossible de supprimer : liste vide.")
    return tete.suivant

# Supprime la première occurrence de valeur dans la liste + retourne la nouvelle tête.
def liste_supprimer_valeur(tete, valeur):
    if liste_vide(tete):
        raise ValueError(f"Valeur {valeur} introuvable.")
    if tete.valeur == valeur:
        return tete.suivant
    courant = tete
    while courant.suivant is not None:
        if courant.suivant.valeur == valeur:
            courant.suivant = courant.suivant.suivant
            return tete
        courant = courant.suivant
    raise ValueError(f"Valeur {valeur} introuvable dans la liste.")

# Affiche tous les éléments de la liste chaînée.
def liste_afficher(tete):
    elements = []
    courant = tete
    while courant is not None:
        elements.append(str(courant.valeur))
        courant = courant.suivant
    print("Liste :", " → ".join(elements) if elements else "[]")


# ==
# Fonction pour effectuer une rechercher universelle
# ==

def rechercher(structure, element):
    # Pile ou file
    if isinstance(structure, list):
        return element in structure

    # Liste chainée
    if isinstance(structure, Noeud) or structure is None:
        courant = structure
        while courant is not None:
            if courant.valeur == element:
                return True
            courant = courant.suivant
        return False

    raise TypeError("Structure non reconnue.")


# ─────────────────────────────────────────────
# Démonstration
# ─────────────────────────────────────────────
if __name__ == "__main__":

    print("=" * 50)
    print("Démonstration de manipulation des piles")
    print("=" * 50)
    p = pile_creer()
    print("Pile vide ?", pile_vide(p))
    empiler(p, 10)
    empiler(p, 20)
    empiler(p, 30)
    pile_afficher(p)
    print("Sommet     :", sommet(p))
    print("Dépiler    :", depiler(p))
    pile_afficher(p)
    print("Recherche 10 :", rechercher(p, 10))
    print("Recherche 99 :", rechercher(p, 99))

    print()
    print("=" * 50)
    print("Démonstration de manipulation des files")
    print("=" * 50)
    f = file_creer()
    print("File vide ?", file_vide(f))
    ajouter(f, "A")
    ajouter(f, "B")
    ajouter(f, "C")
    file_afficher(f)
    print("Tête       :", tete(f))
    print("Retirer    :", retirer(f))
    file_afficher(f)
    print("Recherche 'B' :", rechercher(f, "B"))
    print("Recherche 'Z' :", rechercher(f, "Z"))

    print()
    print("=" * 50)
    print("Démonstration de manipulation des listes chainées")
    print("=" * 50)
    l = liste_creer()
    print("Liste vide ?", liste_vide(l))
    l = liste_inserer_fin(l, 1)
    l = liste_inserer_fin(l, 2)
    l = liste_inserer_fin(l, 3)
    l = liste_inserer_tete(l, 0)
    liste_afficher(l)
    l = liste_inserer_position(l, 99, 2)
    print("Après insertion de 99 à la position 2 :")
    liste_afficher(l)
    l = liste_supprimer_valeur(l, 99)
    print("Après suppression de 99 :")
    liste_afficher(l)
    l = liste_supprimer_tete(l)
    print("Après suppression de la tête :")
    liste_afficher(l)
    print("Recherche 2 :", rechercher(l, 2))
    print("Recherche 9 :", rechercher(l, 9))
