## SwapTeam-Manager
Manage &amp; Swap players teams. This is a standalone version of SwapTeam module from my All-In-One plugin "Random Commands Plugin" (unreleased)

AlliedModders Post: https://forums.alliedmods.net/showthread.php?p=2733684

## Requirements

[Tk Libraries](https://github.com/Teamkiller324/Tklib) (To compile the plugin)
[Updater](https://github.com/Teamkiller324/Updater) (To compile with updater support)

## Description

Manage teams, swap teams, exchange players teams, and force team on a target.
This is a standalone version of SwapTeam module from my All-In-One plugin "Random Commands Plugin" (unreleased).

## Games Supported
```
Team Fortress 2
Team Fortress 2 Classic
Counter-Strike: Source
Counter-Strike: Global Offensive
Left 4 Dead
Left 4 Dead 2
Day of Defeat: Source

More to be supported later by suggestion
```

## Commands
```
sm_swap - Swap a player to opposite team
sm_swapteam - Swap a player to opposite team
sm_switch - Swap a player to opposite team
sm_switchteam - Swap a player to opposite team
sm_exchange - Exchange a target to a clients team
sm_spec - Switch to spectators team
sm_switchspec - Switch a player to the spectators team
sm_swapteam - Switch a player to the spectators team
sm_forceteam - Force a team index on a client
sm_scramble - Scramble a player to a random team.
sm_scrambleteams - Scramble players to a random team.
```

## Cvars
```
sm_swapteam_notify_swapteam
  - Determine if teamswaps shall be notified to everyone or just the client. Default: 1

sm_swapteam_notify_specteam
  - Determine if spectator teamswaps shall be notified to everyone or just the client. Default: 1

sm_swapteam_notify_exchangeteam
  - Determine if exchange teamswaps shall be notified to everyone or just the client. Default: 1

sm_swapteam_instant
  - Should team swaps be instant? (Teamchange without respawning) Default: 0

sm_swapteam_updatemodel
  - [CSS/CSGO] Should the players model get updated once swapped team? Default: 1
```
