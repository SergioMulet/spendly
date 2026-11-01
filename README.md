# Spendly

Native iOS expense tracker built with Swift and SwiftUI to control your monthly expenses.

> Status: in development.

## Features

- Monthly budget with the amount spent and the amount left
- Calendar view where each day is colored by how much you spent, from green (low) to yellow (medium) to red (high)
- Expenses organized by category
- Quick add sheet to register an expense
- Light and dark mode
- English and Spanish

## Privacy and data

Spendly has no accounts and no login. Your data is stored with Apple's CloudKit, in your own private iCloud, so it stays within you and syncs across your own devices. There is no Spendly server.

## Tech stack

- Swift and SwiftUI
- CloudKit for persistence and sync
- String Catalog (`Localizable.xcstrings`) for English and Spanish
- Minimum deployment target: iOS 27.0