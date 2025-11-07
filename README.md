# BookSwap - Student Textbook Exchange App

A complete Flutter mobile application for students to exchange textbooks through a marketplace system with real-time chat functionality.

## Features

### 🔐 Authentication
- User registration with email verification
- Secure login/logout functionality
- Profile management

### 📚 Book Management (CRUD)
- **Create**: Add books with title, author, condition, and cover image
- **Read**: Browse all available book listings
- **Update**: Edit your own book listings
- **Delete**: Remove your book listings

### 🔄 Swap System
- Initiate swap requests with other users
- Real-time swap status updates (Pending, Accepted, Rejected)
- Track sent and received swap offers

### 💬 Real-time Chat
- 1-on-1 messaging between users after swap initiation
- Real-time message synchronization
- Chat history persistence

### 🎨 Modern UI Design
- **Theme**: Blue background, white text, yellow accents
- Clean and intuitive navigation
- Responsive design for all screen sizes

### 📱 Navigation
- **Browse Listings**: View all available books
- **My Listings**: Manage your book listings
- **Chats**: Access all conversations
- **Settings**: Profile info and preferences

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project setup
- Android Studio / VS Code

### Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Enable Firebase Storage
5. Update `lib/firebase_options.dart` with your Firebase configuration

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase for your platforms
4. Run `flutter run` to start the app

## Dependencies
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: File storage
- `image_picker`: Image selection
- `provider`: State management
- `shared_preferences`: Local storage
- `uuid`: Unique ID generation
- `intl`: Date formatting

## Architecture

### Models
- `User`: User profile data
- `Book`: Book listing information
- `Swap`: Swap request details
- `Message`: Chat message data

### Services
- `AuthService`: Authentication operations
- `DatabaseService`: Firestore operations

### Providers
- `AuthProvider`: Authentication state management

### Screens
- Authentication: Login, Sign Up
- Main: Browse, My Listings, Chats, Settings
- Detail: Add/Edit Book, Chat Detail

## Usage

1. **Sign Up**: Create account with email verification
2. **Add Books**: List textbooks you want to exchange
3. **Browse**: Find books you need from other students
4. **Request Swap**: Initiate exchange with book owners
5. **Chat**: Communicate with other users
6. **Manage**: Accept/reject swap requests

## Security Features
- Email verification required
- Secure Firebase authentication
- User data validation
- Real-time security rules

## Future Enhancements
- Push notifications
- Advanced search and filters
- Rating system
- Location-based matching
- In-app payment integration
