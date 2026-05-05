"""
Bibliothèque de fonctions pour les matrices

=======================================

Fonctions disponibles :
  - creer_matrice_5x4       : crée une matrice de dimension 5x4
  - creer_matrice           : créer une matrice générique aux dimensions indiquées
  - multiplication_matrices : multiplie 2 matrices de même dimension
  - addition_matrices       : additionne 2 matrices de même dimension
  - operation_matrices      : réalise des opérations mathématiques sur 2 matrices de même dimension
"""

import random

# 1. Matrice fixe 5 x 4
def creer_matrice_5x4(fill=0):
    return [[fill] * 4 for _ in range(5)]


# 2. Matrice n x m générique
def creer_matrice(n, m, fill=0):
    """
    Crée une matrice n × m.
    fill : valeur par défaut, ou 'random' pour des entiers aléatoires 1-9.
    """
    if fill == 'random':
        return [[random.randint(1, 9) for _ in range(m)] for _ in range(n)]
    return [[fill] * m for _ in range(n)]

# 3. Multiplication de matrices
def multiplication_matrices(A, B):
    n, k = len(A), len(A[0])
    if len(B) != k:
        raise ValueError(f"Dimensions incompatibles : A={n}×{k}, B={len(B)}×{len(B[0])}")
    m = len(B[0])
    result = creer_matrice(n, m)
    for i in range(n):
        for j in range(m):
            result[i][j] = sum(A[i][p] * B[p][j] for p in range(k))
    return result

# 4. Addition de matrices
def addition_matrices(A, B):
    n, m = len(A), len(A[0])
    if len(B) != n or len(B[0]) != m:
        raise ValueError(f"Dimensions incompatibles : A={n}×{m}, B={len(B)}×{len(B[0])}")
    return [[A[i][j] + B[i][j] for j in range(m)] for i in range(n)]

# 5. Fonction standard avec opération (+, -, x, /)
def operation_matrices(A, B, op):
    ELEM_OPS = {'+', '-', '/'}

    # --- Vérification des dimensions ---
    n, m = len(A), len(A[0])
    if op in ELEM_OPS:
        if len(B) != n or len(B[0]) != m:
            raise ValueError(
                f"[{op}] Dimensions incompatibles : A={n}×{m}, B={len(B)}×{len(B[0])}"
            )
    elif op == 'x':
        if len(B) != m:
            raise ValueError(
                f"[x] Dimensions incompatibles : A={n}×{m}, B={len(B)}×{len(B[0])}"
            )
    else:
        raise ValueError(f"Opération inconnue : '{op}'. Choisir parmi +, -, x, /")

    # --- Calcul ---
    if op == 'x':
        return multiplication_matrices(A, B)

    rows, cols = n, len(B[0]) if op == 'x' else m
    result = creer_matrice(rows, cols)

    for i in range(rows):
        for j in range(cols):
            a, b = A[i][j], B[i][j]
            if   op == '+': result[i][j] = a + b
            elif op == '-': result[i][j] = a - b
            elif op == '/': result[i][j] = a / b if b != 0 else 1

    return result

# Utilitaire : affichage propre
def afficher_matrice(M, label=""):
    if label:
        print(f"\n{label}")
    for row in M:
        print("", [f"{v:6.2f}" if isinstance(v, float) else f"{v:4}" for v in row])

# ─────────────────────────────────────────────
# Démonstration
# ─────────────────────────────────────────────
if __name__ == "__main__":

    print("=" * 55)
    print("Démonstration de manipulation de matrices")
    print("=" * 55)

    # 1 — Matrice 5×4
    M54 = creer_matrice_5x4(fill=1)
    afficher_matrice(M54, "Matrice 5×4 (remplie de 1)")

    # 2 — Matrices aléatoires
    A = creer_matrice(3, 3, fill='random')
    B = creer_matrice(3, 3, fill='random')
    afficher_matrice(A, "Matrice A (3×3 aléatoire)")
    afficher_matrice(B, "Matrice B (3×3 aléatoire)")

    # 3 — Opérations
    for op in ('+', '-', 'x', '/'):
        try:
            R = operation_matrices(A, B, op)
            afficher_matrice(R, f"A {op} B")
        except ValueError as e:
            print(f"Erreur : {e}")