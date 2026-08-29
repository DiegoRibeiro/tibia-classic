Convergência Total do Mapeamento de Término
                               ┌──────────────────────────────────┐
                               │     Ciclo Interno AdvanceGame    │
                               └────────────────┬─────────────────┘
                                                │ (Tempo expirado)
                                                ▼
┌──────────────────────────────┐        ┌───────────────┐
│ SIGTERM enviado pelo OS (15) │───────►│  CloseGame()  │
└──────────────────────────────┘        └───────┬───────┘
                                                │
                                                ▼
                                    ┌───────────────────────┐
                                    │   LogoutAllPlayers    │
                                    └───────────┬───────────┘
                                                │
                                                ▼
                                    ┌───────────────────────┐
                                    │        SendAll        │
                                    └───────────┬───────────┘
                                                │
                                                ▼
                                    ┌───────────────────────┐
                                    │        SaveMap        │
                                    └───────────┬───────────┘
                                                │
                                                ▼
┌──────────────────────────────┐    ┌───────────────────────┐
│ Outros Sinais (SIGINT, etc.) │───►│       EndGame()       │
└──────────────────────────────┘    └───────────────────────┘

kill -15 $(cat /game/save/game.pid)

quando o server recebe o comaando de kill ele da um broadcast de 5 minutos para logar
Server is going down in 5 minutes.
Please log out.
Server is going down in 3 minutes.
Please log out.

bem legal.