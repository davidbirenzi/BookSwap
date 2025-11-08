# BookSwap App

Hello! This is my book exchange app. Basically, you can list your old books and swap them with other students instead of buying expensive new ones.

## What it does

- **Sign up & Login**: Create an account with email verification.
- **List your books**: Take a photo, add title/authorand pick its condition.
- **Browse books**: See what other students are offering.
- **Request swaps**: Found a book you need? click that swap button.
- **Chat**: Talk to the book owner to arrange the exchange.
- **Manage requests**: Accept or reject swap offers from others.

## How to run it

You'll need Flutter installed and a Firebase project set up. Here's the quick version:

1. Clone this repo
2. Run `flutter pub get`
3. Set up Firebase (Auth + Firestore)
4. Update `lib/firebase_options.dart` with your config
5. `flutter run`

## explanations

- **Flutter** for the mobile app
- **Firebase Auth** for login/signup
- **Firestore** for storing books, swaps, and messages
- **Provider** for state management (keeps the UI reactive)

The app follows clean architecture - models, services, providers, and screens are all separated.

<img width="3323" height="2392" alt="image" src="https://github.com/user-attachments/assets/84ac6bc1-1720-40b0-8101-a25a8e1b5ada" />


**Done by:** David Birenzi
