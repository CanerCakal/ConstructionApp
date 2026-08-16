# ConstructionApp

An iOS app for construction cost estimation: define a project, add materials, and get live-rate-adjusted totals, visual cost breakdowns, AI-generated project analysis and a shareable PDF report — built with SwiftUI, SwiftData and MVVM.

## What It Does

- **Project & material management** — create projects, attach materials with quantities and unit costs, edit them in place; total cost updates as you go
- **Cost visualization** — material cost breakdown rendered with Swift Charts on the project detail screen
- **Live market rates** — current USD exchange rates fetched from a public API feed into market price calculations
- **AI project analysis** — one tap sends the project summary to Gemini 2.5 Flash and returns a written cost/risk analysis
- **PDF export** — a formatted report (header, project info, material table, totals) drawn with Core Graphics and shared via the system share sheet
- **Local auth & sessions** — registration/login with salted password hashing, session persistence via Keychain, and per-user data isolation so multiple users on one device only see their own projects

## Architecture

MVVM on SwiftUI:

```
ConstructionApp/
├── Models        # User, Project, Material — SwiftData @Model classes
├── ViewModels    # AuthViewModel, HomeViewModel, ProjectDetailViewModel
├── Views         # Splash, Login/Register, Home, ProjectDetail, EditMaterial, MarketPrices
└── Services      # NetworkManager, AIService, PDFService, KeychainManager
```

- **SwiftData** as the persistence layer (`modelContainer` for User / Project / Material)
- **Service layer** keeps networking, AI calls, PDF drawing and Keychain access out of views and view models
- **Data isolation** — queries are scoped to the signed-in user

## Setup

The Gemini API key is intentionally kept out of version control. After cloning, create `ConstructionApp/Secrets.swift`:

```swift
enum Secrets {
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY"
}
```

Then open the project in Xcode and run. Without this file the project will not compile — that's the point.

## Known Limitations

Documented honestly, because they're part of the engineering story:

- **Keychain stores the raw password** alongside the salted hash for session restore. Keychain is encrypted at rest, but persisting the plaintext credential is an anti-pattern — the right fix is storing only a session token or the hash. On the roadmap.
- **Client-side API key.** Acceptable for a personal tool; a public release would route Gemini calls through a backend proxy.
- **Exchange-rate source** is a free public API without SLA — fine for estimation, not for contractual pricing.

## Built With

Swift · SwiftUI · SwiftData · Swift Charts · Core Graphics (PDFKit-free PDF drawing) · Keychain Services · Gemini 2.5 Flash

## Status

Functional v1 developed as a portfolio project. Active areas: auth hardening (see limitations) and expanding the market-price catalog.
