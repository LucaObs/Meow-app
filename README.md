# Meow-app

Un'app iOS per analizzare le calorie e gli ingredienti dei tuoi pasti tramite fotografia, usando Claude Vision AI.

## Funzionalità

- Seleziona una foto dalla libreria fotografica
- Claude analizza automaticamente il pasto
- Ottieni un elenco dettagliato degli ingredienti con le calorie stimate
- Totale calorie del pasto visualizzato chiaramente

## Setup

### 1. Apri il progetto in Xcode

```
open MeowApp/MeowApp.xcodeproj
```

### 2. Configura la chiave API

Avvia l'app e tocca l'icona **Impostazioni** (ingranaggio) in alto a destra. Inserisci la tua chiave API Claude ottenuta da `console.anthropic.com`.

La chiave viene salvata in modo sicuro sul dispositivo tramite `UserDefaults`.

### 3. Build & Run

- Seleziona un simulatore iPhone o il tuo dispositivo fisico
- Premi `Cmd+R` per compilare ed eseguire

## Requisiti

- iOS 16.0+
- Xcode 15+
- Chiave API Anthropic (Claude)

## Struttura del progetto

```
MeowApp/
├── MeowApp.xcodeproj/
└── MeowApp/
    ├── MeowAppApp.swift       # Entry point
    ├── ContentView.swift      # Schermata principale con selezione foto
    ├── ResultView.swift       # Schermata risultati analisi
    ├── SettingsView.swift     # Impostazioni chiave API
    ├── ClaudeService.swift    # Integrazione API Claude Vision
    ├── MealAnalysis.swift     # Modelli dati
    ├── Assets.xcassets/
    └── Info.plist
```

## Come funziona

1. L'utente seleziona una foto del pasto dalla libreria
2. L'immagine viene codificata in base64 e inviata a Claude (`claude-opus-4-8`) tramite l'API Messages
3. Claude analizza il pasto e restituisce un JSON strutturato con ingredienti e calorie
4. L'app mostra i risultati in una lista dettagliata
