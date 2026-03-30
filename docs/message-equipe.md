# Nouvel outil — Claude Code Advisor (à installer)

Salut l'équipe,

Je viens de publier **Claude Code Advisor** — un skill Claude Code qui vous dit exactement comment aborder n'importe quelle tâche avec les bons outils, le bon mode, et la bonne stratégie.

## Le problème

Claude Code a des dizaines de fonctionnalités (plan mode, subagents, worktrees, skills, MCPs...) et on utilise à peine 20% du potentiel. Le résultat : on perd du temps, on fait des erreurs évitables, et chacun réinvente la roue dans son coin.

## La solution

Avant de commencer une tâche, vous demandez conseil :

```
> conseille-moi pour ajouter l'auth au projet
```

Et l'advisor vous répond avec :
- Le **mode** à utiliser (plan mode, normal, fast)
- Les **skills** à activer (brainstorming, TDD, debugging...)
- Les **MCPs** à brancher si besoin
- Comment **gérer le contexte** pour ne pas saturer la fenêtre
- Les **pièges à éviter** pour ce type de tâche
- Des **tips** concrets adaptés à votre situation

Le tout basé sur un framework à **6 niveaux de maîtrise** de Claude Code. L'advisor détecte le niveau adapté à votre tâche et vous guide.

## Installation (30 secondes)

**macOS / Linux :**
```bash
bash <(curl -s https://raw.githubusercontent.com/Flo976/claude-code-advisor/main/install.sh)
```

**Windows (PowerShell) :**
```powershell
irm https://raw.githubusercontent.com/Flo976/claude-code-advisor/main/install.ps1 | iex
```

C'est tout. Le skill se met à jour automatiquement chaque semaine.

## Comment l'utiliser

Dans Claude Code, dites simplement :
- **`/advisor`** — recommandation pour la tâche en cours
- **`conseille-moi`** — même chose en langage naturel
- **`comment faire ça au mieux ?`** — idem
- **`/advisor update`** — forcer une mise à jour des connaissances

Ça répond en français si vous parlez en français.

## Prérequis

Le skill fonctionne beaucoup mieux avec le plugin **Superpowers** installé. Si vous ne l'avez pas, l'advisor vous le signalera et vous expliquera comment l'installer.

## Le repo

https://github.com/Flo976/claude-code-advisor

Open source (MIT). Si vous découvrez un bon tip ou un anti-pattern, ajoutez-le dans les références et faites une PR.

---

N'hésitez pas à me faire vos retours après quelques jours d'utilisation — le skill s'améliore avec vos feedbacks.

Florent
