import numpy as np

"""
Fonction qui simule le fonctionnement d'un casino selon le modèle de Poisson
et qui trace l'évolution du capital du casino au fil du temps.

Paramètres
alpha : Paramètre alpha des rentrées d'argent
Y0 : Capital initial du casino
duration : Durée de la simulation (en nombre de pas de temps)
"""


def casino_simulation(alpha, Y0, duration, earn_function):
    print("alpha = ", alpha)
    print("Y0 = ", Y0)
    print("duration = ", duration)
    # Génére la série de temps de saut (ξk) selon une loi exponentielle de paramètre 1
    jump_times = np.random.exponential(size=duration, scale=1)

    # Calculer les instants de saut (Ti)
    T = np.cumsum(jump_times)
    T = np.insert(T, 0, 0)

    # Générer la série de gains des joueurs (Xi) selon une loi exponentielle de paramètre 1
    gains = earn_function(duration)

    # Calculer le nombre de joueurs ayant eu un gain avant chaque instant de temps t
    N_t = np.zeros(duration + 1, dtype=int)
    for t in range(1, duration + 1):
        # N_t[t] = np.max( [i for i in range(duration+1) if T[i] <= t] )
        N_t[t] = np.argmax(np.where(T <= t))

    # Calculer les rentrées d'argent du casino
    casino_earnings = alpha * np.arange(duration + 1)

    # Compute player earnings
    print(N_t[0])
    player_earnings = np.zeros(duration + 1)
    for t in range(1, duration + 1):
        player_earnings[t] = np.sum(gains[: N_t[t]])

    # Calculer le capital du casino à chaque instant de temps t
    casino_capital = Y0 + casino_earnings - player_earnings

    return casino_earnings, player_earnings, casino_capital
