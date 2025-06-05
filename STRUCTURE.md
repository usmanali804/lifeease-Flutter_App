# Project Structure Documentation

## Overview
LifeEase is organized using a feature-first architecture with clean separation of concerns. This document outlines the project structure and organization principles.

## Directory Structure

### Core (/lib/core)
Contains application-wide functionality and configurations:
- `/app`: App initialization and root widgets
- `/auth`: Authentication services
- `/constants`: Application-wide constants
- `/configs`: Environment and configuration files
- `/database`: Database related code
- `/di`: Dependency injection setup
- `/models`: Base models and shared data structures
- `/network`: Network and API related code
- `/services`: Core services
- `/theme`: App theming
- `/utils`: Utility functions

### Features (/lib/features)
Each feature is self-contained with its own layers:
- `data`: Repositories and data sources
- `domain`: Business logic and models
- `presentation`: UI components and screens

Current features:
- Task Management
- Chat
- Wellness Tracking
- OCR
- Voice Control
- Multilingual Support
- Notifications
- Settings

### Shared (/lib/shared)
Reusable components and utilities:
- `widgets`: Common UI components
- `utils`: Shared utility functions
- `constants`: Shared constants

### Services (/lib/services)
Application-wide services that don't fit into core:
- Connectivity service
- Analytics service
- Push notification service

## Development Guidelines

1. **Feature Organization**
   - Keep feature-specific code within its feature directory
   - Share common functionality through core or shared directories

2. **Dependency Management**
   - Use dependency injection for service locator
   - Minimize direct dependencies between features
   - Use abstractions and interfaces for loose coupling

3. **Code Style**
   - Follow Flutter/Dart style guide
   - Use meaningful naming conventions
   - Document public APIs and complex logic

4. **Testing**
   - Write unit tests for business logic
   - Write widget tests for UI components
   - Write integration tests for critical user flows

## Backend Structure

The backend follows a modular structure:
- `/middleware`: Express middleware functions
- `/models`: Database models and schemas
- `/routes`: API route handlers
- `/services`: Business logic and external service integration
