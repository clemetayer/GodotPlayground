# SoundManager
- custom loop
- loop certaines parties d'une chanson
- peut queue une chanson

# Archi :
- Noeud Song : 
    - BPM
    - Beats per bar
    - fonction pour jouer/arrêter le morceau
    - totalBars (durée de la chanson)
    - transition mode : beat/bar (rappel : beat < bar en terme de temps)
    - transition time : nombre de beats ou bar avant de faire la transition (Attention, beat/bar global)
    - fade in type : None (instantané, pas de transition), filter (transition par filtre), volume (transition par volume)
    - fade out type : None (instantané, pas de transition), filter (transition par filtre), volume (transition par volume)
    - Loops possibles dans la chanson (array)
    - fonction pour set le loop suivant à la fin du précédent
    - fonctions supplémentaires si besoin
    - possibilité de jouer directement à un certain moment de la loop
    - en enfant, le(s) morceau à jouer
    - mode play once ou loop
    - ***optionnel*** : signal spécial à émettre sur un moment spécial de la song
    - ***optionnel*** : array de chansons en enfant avec des paramètres à feed
    - ***optionnel*** : possibilité de ne pas avoir de song principale que des songs avec des paramètres à feed
- Sound Manager : 
    - Garder la manipulation des bus pour les menus de pause, etc.
    - Gère la queue des morceaux à jouer
    - Vérifie si le prochain morceau à jouer n'est pas déjà en train de jouer (et réinitialiser les infos de loop si besoin)
    - possibilité de retourner le morceau en train de jouer
    - vérifier paramètres obligatoires song
    - fonction isPlaying (retourne la position dans la song)
    - signaux beat/bar et leur numéro
    - signaux song changed, song done
    - play at loop index (vérification s'il existe)
    - Noeud contenant le morceau principal en train d'être joué
    - ***optionnel*** : musique de transition entre des morceaux
    - ***optionnel*** : noeud contenant les morceaux additionnels avec des paramètres à feed


