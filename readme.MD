# 🚀 TodoListi - Unified Productivity Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.0+-red.svg)](https://nestjs.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://postgresql.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> A production-ready, cross-platform productivity system combining Google Calendar-style scheduling, Notion-like organization, and ADHD-friendly task management.

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Product Vision & Use Cases](#-product-vision--use-cases)
3. [Feature Breakdown](#-feature-breakdown)
4. [System Architecture](#-system-architecture)
5. [Tech Stack](#-tech-stack)
6. [Folder Structure](#-folder-structure)
7. [Environment Setup](#-environment-setup)
8. [Local Development Guide](#-local-development-guide)
9. [Running the App](#-running-the-app)
10. [Authentication Flow](#-authentication-flow)
11. [Google Calendar Sync](#-google-calendar-sync)
12. [Assistant/PA Permission Model](#-assistantpa-permission-model)
13. [Database Schema](#-database-schema)
14. [API Documentation](#-api-documentation)
15. [Offline-First & Sync Strategy](#-offline-first--sync-strategy)
16. [Security Practices](#-security-practices)
17. [Deployment Instructions](#-deployment-instructions)
18. [CI/CD Pipeline](#-cicd-pipeline)
19. [Contribution Guidelines](#-contribution-guidelines)
20. [Future Roadmap](#-future-roadmap)

---

## 🎯 Project Overview

**TodoListi** is a unified productivity platform designed to help individuals and teams manage their tasks, time, and goals effectively. Built with accessibility in mind, particularly for users with ADHD, it provides a low-cognitive-load interface while offering powerful features.

### Key Differentiators

- **Cross-Platform**: Single codebase for Android, iOS, Windows, macOS, and Linux
- **ADHD-Friendly**: Designed to reduce overwhelm and increase focus
- **Personal Assistant Delegation**: Unique PA/Associate system for task delegation
- **Offline-First**: Works seamlessly without internet, syncs when connected
- **Google Calendar Integration**: Two-way sync with your existing calendar

---

## 🔮 Product Vision & Use Cases

### Vision Statement

> "Empower everyone to achieve their goals by providing a distraction-free, intelligent productivity platform that adapts to how you work."

### Primary Use Cases

| Use Case | Description | Target User |
|----------|-------------|-------------|
| **Personal Task Management** | Daily todo lists, habit tracking, goal setting | Individual users |
| **Executive Assistance** | PA manages executive's calendar and tasks | Executives with PAs |
| **Project Planning** | Break down projects into tasks with timelines | Freelancers, Small teams |
| **ADHD Support** | Focus modes, reduced clutter, smart reminders | Users with ADHD |
| **Family Coordination** | Shared calendars, delegated tasks | Families |

### User Personas

1. **Alex the Executive** - Needs PA delegation, quick task capture
2. **Sam the Freelancer** - Project tracking, time blocking, invoicing prep
3. **Jordan with ADHD** - Focus modes, gentle reminders, visual progress
4. **Taylor the Parent** - Family calendar, shared lists, recurring tasks

---

## ✨ Feature Breakdown

### Phase 1 - MVP (Current)

#### Task Management
- ✅ Create, edit, delete tasks
- ✅ Subtasks with unlimited nesting
- ✅ Priority levels (None, Low, Medium, High, Urgent)
- ✅ Due dates and times
- ✅ Recurring tasks (daily, weekly, monthly, custom)
- ✅ Tags and categories
- ✅ Quick add with natural language parsing

#### Views
- ✅ **List View**: Traditional todo list
- ✅ **Calendar View**: Google Calendar-style timeline
- ✅ **Timeline View**: Gantt-like project view
- ✅ **Focus View**: One task at a time (ADHD mode)
- ✅ **Board View**: Kanban-style organization

#### Personal Assistant System
- ✅ Invite PA via email
- ✅ Permission levels: View, Edit, Full Control
- ✅ Activity audit trail
- ✅ Real-time updates
- ✅ Revoke access anytime

#### Integrations
- ✅ Google Calendar two-way sync
- ✅ Google Sign-In (OAuth 2.0)

#### Core Features
- ✅ Offline-first with background sync
- ✅ Push notifications
- ✅ Smart reminders
- ✅ Search across all content
- ✅ Dark/Light themes

### Phase 2 - Power Users (Planned)
- 🔲 Notion import/sync
- 🔲 Focus timer (Pomodoro)
- 🔲 Productivity analytics dashboard
- 🔲 Goal tracking with milestones
- 🔲 Templates for recurring projects

### Phase 3 - Scale & Monetization (Planned)
- 🔲 Free/Pro/Enterprise tiers
- 🔲 Team workspaces
- 🔲 Multiple PA support
- 🔲 API access for integrations
- 🔲 White-label options

---

## 🏗 System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CLIENT LAYER                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Android   │  │     iOS     │  │   Windows   │  │    macOS    │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │            │
│         └────────────────┴────────────────┴────────────────┘            │
│                                   │                                      │
│                        ┌──────────▼──────────┐                          │
│                        │   FLUTTER APP       │                          │
│                        │  ┌────────────────┐ │                          │
│                        │  │   Riverpod     │ │                          │
│                        │  │ State Manager  │ │                          │
│                        │  └────────────────┘ │                          │
│                        │  ┌────────────────┐ │                          │
│                        │  │  Drift/SQLite  │ │                          │
│                        │  │  Local Store   │ │                          │
│                        │  └────────────────┘ │                          │
│                        └──────────┬──────────┘                          │
└───────────────────────────────────┼─────────────────────────────────────┘
                                    │
                          HTTPS/WSS │ (REST + WebSocket)
                                    │
┌───────────────────────────────────┼─────────────────────────────────────┐
│                         API GATEWAY LAYER                                │
│                        ┌──────────▼──────────┐                          │
│                        │   Load Balancer     │                          │
│                        │   (nginx/AWS ALB)   │                          │
│                        └──────────┬──────────┘                          │
└───────────────────────────────────┼─────────────────────────────────────┘
                                    │
┌───────────────────────────────────┼─────────────────────────────────────┐
│                         APPLICATION LAYER                                │
│                        ┌──────────▼──────────┐                          │
│                        │   NestJS Backend    │                          │
│                        │  ┌────────────────┐ │                          │
│                        │  │  Controllers   │ │                          │
│                        │  ├────────────────┤ │                          │
│                        │  │   Services     │ │                          │
│                        │  ├────────────────┤ │                          │
│                        │  │   Modules      │ │                          │
│                        │  └────────────────┘ │                          │
│                        │  ┌────────────────┐ │                          │
│                        │  │   WebSocket    │ │                          │
│                        │  │   Gateway      │ │                          │
│                        │  └────────────────┘ │                          │
│                        └─────────┬───────────┘                          │
└──────────────────────────────────┼──────────────────────────────────────┘
                                   │
┌──────────────────────────────────┼──────────────────────────────────────┐
│                          DATA LAYER                                      │
│     ┌────────────────┐    │     ┌────────────────┐                      │
│     │   PostgreSQL   │◄───┴────►│     Redis      │                      │
│     │   (Primary DB) │          │  (Cache/Queue) │                      │
│     └────────────────┘          └────────────────┘                      │
│     ┌────────────────┐          ┌────────────────┐                      │
│     │       S3       │          │    Sentry      │                      │
│     │  (File Store)  │          │  (Monitoring)  │                      │
│     └────────────────┘          └────────────────┘                      │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
┌──────────────────────────────────┼──────────────────────────────────────┐
│                    EXTERNAL INTEGRATIONS                                 │
│     ┌────────────────┐          ┌────────────────┐                      │
│     │ Google Calendar│          │  Google OAuth  │                      │
│     │      API       │          │     2.0        │                      │
│     └────────────────┘          └────────────────┘                      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User Action** → Flutter UI captures user input
2. **Local First** → Changes saved to local SQLite immediately
3. **Sync Queue** → Changes queued for background sync
4. **API Call** → REST/WebSocket to NestJS backend
5. **Validation** → RBAC + business logic validation
6. **Persistence** → PostgreSQL for durable storage
7. **Broadcast** → WebSocket broadcasts to other devices
8. **Conflict Resolution** → Last-write-wins with user notification

---

## 🛠 Tech Stack

### Frontend (Flutter)

| Technology | Purpose | Why We Chose It |
|------------|---------|-----------------|
| **Flutter 3.16+** | UI Framework | Single codebase, native performance, hot reload |
| **Riverpod 2.0** | State Management | Compile-safe, testable, scalable |
| **Drift (SQLite)** | Local Database | Type-safe, reactive, offline support |
| **Dio** | HTTP Client | Interceptors, retry logic, logging |
| **go_router** | Navigation | Declarative, deep linking, guards |
| **flutter_local_notifications** | Notifications | Cross-platform notifications |
| **freezed** | Data Classes | Immutability, JSON serialization |
| **flutter_animate** | Animations | Easy, performant animations |

### Backend (NestJS)

| Technology | Purpose | Why We Chose It |
|------------|---------|-----------------|
| **Node.js 20 LTS** | Runtime | Async I/O, large ecosystem |
| **NestJS 10** | Framework | TypeScript, modular, enterprise-ready |
| **PostgreSQL 15** | Primary Database | ACID, JSONB, full-text search |
| **Redis 7** | Cache/Queue | Sessions, rate limiting, pub/sub |
| **TypeORM** | ORM | TypeScript entities, migrations |
| **Passport.js** | Authentication | OAuth strategies, JWT support |
| **Socket.io** | Real-time | WebSocket with fallbacks |
| **Bull** | Job Queue | Reliable background jobs |

### Infrastructure

| Technology | Purpose | Why We Chose It |
|------------|---------|-----------------|
| **Docker** | Containerization | Consistent environments |
| **GitHub Actions** | CI/CD | Free for open source, flexible |
| **AWS/GCP/Render** | Cloud Platform | Scalable, managed services |
| **S3/MinIO** | Object Storage | File attachments, exports |
| **Sentry** | Error Tracking | Real-time error monitoring |
| **Prometheus + Grafana** | Metrics | Performance monitoring |

---

## 📁 Folder Structure

### Frontend (Flutter)

```
flutter_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App configuration
│   │
│   ├── core/                        # Core infrastructure
│   │   ├── config/                  # App configuration
│   │   │   ├── app_config.dart
│   │   │   ├── environment.dart
│   │   │   └── theme_config.dart
│   │   ├── constants/               # App constants
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   └── ui_constants.dart
│   │   ├── errors/                  # Error handling
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/                 # Network layer
│   │   │   ├── api_client.dart
│   │   │   ├── interceptors/
│   │   │   └── network_info.dart
│   │   ├── storage/                 # Local storage
│   │   │   ├── secure_storage.dart
│   │   │   └── preferences.dart
│   │   └── utils/                   # Utilities
│   │       ├── date_utils.dart
│   │       ├── string_utils.dart
│   │       └── validators.dart
│   │
│   ├── data/                        # Data layer
│   │   ├── datasources/             # Data sources
│   │   │   ├── local/
│   │   │   │   ├── database.dart
│   │   │   │   ├── task_local_ds.dart
│   │   │   │   └── user_local_ds.dart
│   │   │   └── remote/
│   │   │       ├── task_remote_ds.dart
│   │   │       └── user_remote_ds.dart
│   │   ├── models/                  # Data models
│   │   │   ├── task_model.dart
│   │   │   ├── user_model.dart
│   │   │   └── sync_model.dart
│   │   └── repositories/            # Repository implementations
│   │       ├── task_repository_impl.dart
│   │       └── user_repository_impl.dart
│   │
│   ├── domain/                      # Domain layer
│   │   ├── entities/                # Business entities
│   │   │   ├── task.dart
│   │   │   ├── user.dart
│   │   │   ├── project.dart
│   │   │   └── permission.dart
│   │   ├── repositories/            # Repository contracts
│   │   │   ├── task_repository.dart
│   │   │   └── user_repository.dart
│   │   └── usecases/                # Business logic
│   │       ├── task/
│   │       │   ├── create_task.dart
│   │       │   ├── update_task.dart
│   │       │   └── delete_task.dart
│   │       └── auth/
│   │           ├── sign_in.dart
│   │           └── sign_out.dart
│   │
│   ├── presentation/                # Presentation layer
│   │   ├── providers/               # Riverpod providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── task_provider.dart
│   │   │   └── sync_provider.dart
│   │   ├── screens/                 # Screen widgets
│   │   │   ├── home/
│   │   │   ├── tasks/
│   │   │   ├── calendar/
│   │   │   ├── settings/
│   │   │   └── auth/
│   │   ├── widgets/                 # Reusable widgets
│   │   │   ├── common/
│   │   │   ├── task/
│   │   │   └── calendar/
│   │   └── theme/                   # App theming
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   └── services/                    # App services
│       ├── sync_service.dart
│       ├── notification_service.dart
│       └── analytics_service.dart
│
├── test/                            # Test files
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/                          # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml                     # Dependencies
└── analysis_options.yaml            # Lint rules
```

### Backend (NestJS)

```
backend/
├── src/
│   ├── main.ts                      # App entry point
│   ├── app.module.ts                # Root module
│   │
│   ├── common/                      # Shared code
│   │   ├── decorators/              # Custom decorators
│   │   │   ├── current-user.decorator.ts
│   │   │   └── permissions.decorator.ts
│   │   ├── filters/                 # Exception filters
│   │   │   └── http-exception.filter.ts
│   │   ├── guards/                  # Auth guards
│   │   │   ├── jwt-auth.guard.ts
│   │   │   └── rbac.guard.ts
│   │   ├── interceptors/            # Request interceptors
│   │   │   ├── logging.interceptor.ts
│   │   │   └── transform.interceptor.ts
│   │   ├── pipes/                   # Validation pipes
│   │   │   └── validation.pipe.ts
│   │   └── utils/                   # Utilities
│   │       └── crypto.util.ts
│   │
│   ├── config/                      # Configuration
│   │   ├── database.config.ts
│   │   ├── redis.config.ts
│   │   └── app.config.ts
│   │
│   ├── modules/                     # Feature modules
│   │   ├── auth/                    # Authentication
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── strategies/
│   │   │   │   ├── jwt.strategy.ts
│   │   │   │   └── google.strategy.ts
│   │   │   └── dto/
│   │   │       └── auth.dto.ts
│   │   │
│   │   ├── users/                   # User management
│   │   │   ├── users.module.ts
│   │   │   ├── users.controller.ts
│   │   │   ├── users.service.ts
│   │   │   ├── entities/
│   │   │   │   └── user.entity.ts
│   │   │   └── dto/
│   │   │       └── user.dto.ts
│   │   │
│   │   ├── tasks/                   # Task management
│   │   │   ├── tasks.module.ts
│   │   │   ├── tasks.controller.ts
│   │   │   ├── tasks.service.ts
│   │   │   ├── entities/
│   │   │   │   └── task.entity.ts
│   │   │   └── dto/
│   │   │       └── task.dto.ts
│   │   │
│   │   ├── projects/                # Projects
│   │   │   └── ...
│   │   │
│   │   ├── permissions/             # PA/RBAC system
│   │   │   ├── permissions.module.ts
│   │   │   ├── permissions.controller.ts
│   │   │   ├── permissions.service.ts
│   │   │   ├── entities/
│   │   │   │   └── permission.entity.ts
│   │   │   └── dto/
│   │   │       └── permission.dto.ts
│   │   │
│   │   ├── calendar-sync/           # Google Calendar
│   │   │   ├── calendar-sync.module.ts
│   │   │   ├── calendar-sync.service.ts
│   │   │   └── google-calendar.client.ts
│   │   │
│   │   ├── sync/                    # Offline sync
│   │   │   ├── sync.module.ts
│   │   │   ├── sync.gateway.ts      # WebSocket
│   │   │   └── sync.service.ts
│   │   │
│   │   └── audit/                   # Audit trail
│   │       ├── audit.module.ts
│   │       ├── audit.service.ts
│   │       └── entities/
│   │           └── audit-log.entity.ts
│   │
│   └── database/                    # Database
│       ├── migrations/              # TypeORM migrations
│       └── seeds/                   # Seed data
│
├── test/                            # Tests
│   ├── unit/
│   └── e2e/
│
├── docker/                          # Docker configs
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── .env.example                     # Environment template
├── package.json                     # Dependencies
├── tsconfig.json                    # TypeScript config
└── nest-cli.json                    # NestJS CLI config
```

---

## ⚙️ Environment Setup

### Prerequisites

- **Node.js** 20 LTS or higher
- **Flutter** 3.16 or higher
- **PostgreSQL** 15 or higher
- **Redis** 7 or higher
- **Docker** (optional, for containerized development)
- **Git**

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/todolisti.git
cd todolisti
```

### Step 2: Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your values (see Environment Variables section)

# Run database migrations
npm run migration:run

# Seed initial data (optional)
npm run seed

# Start development server
npm run start:dev
```

### Step 3: Frontend Setup

```bash
cd flutter_app

# Get Flutter dependencies
flutter pub get

# Generate code (Freezed, Drift, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment Variables

#### Backend (.env)

```env
# Application
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=todolisti
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your_super_secret_key_min_32_chars
JWT_EXPIRATION=7d
JWT_REFRESH_EXPIRATION=30d

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:3000/api/v1/auth/google/callback

# Google Calendar API
GOOGLE_CALENDAR_API_KEY=your_api_key

# S3 Storage
S3_BUCKET=todolisti-uploads
S3_REGION=us-east-1
S3_ACCESS_KEY=your_access_key
S3_SECRET_KEY=your_secret_key

# Sentry
SENTRY_DSN=your_sentry_dsn

# Encryption
ENCRYPTION_KEY=your_32_char_encryption_key
```

#### Frontend (lib/core/config/environment.dart)

```dart
class Environment {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
  
  static const googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
}
```

---

## 💻 Local Development Guide

### Running with Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Running Manually

#### Terminal 1: PostgreSQL + Redis
```bash
# Using Docker for databases only
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:15
docker run -d --name redis -p 6379:6379 redis:7
```

#### Terminal 2: Backend
```bash
cd backend
npm run start:dev
```

#### Terminal 3: Flutter App
```bash
cd flutter_app
flutter run -d windows  # or macos, linux, chrome, etc.
```

### Hot Reload

- **Backend**: NestJS auto-reloads on file changes
- **Flutter**: Press `r` in terminal or save files

### Code Generation

When you modify Freezed models or Drift tables:

```bash
cd flutter_app
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📱 Running the App

### Mobile (Android/iOS)

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on all connected devices
flutter run -d all
```

### Desktop (Windows/macOS/Linux)

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Web (Development Only)

```bash
flutter run -d chrome
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 🔐 Authentication Flow

### OAuth 2.0 with Google

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│   Flutter   │          │   Backend   │          │   Google    │
│     App     │          │   (NestJS)  │          │   OAuth     │
└──────┬──────┘          └──────┬──────┘          └──────┬──────┘
       │                        │                        │
       │  1. User taps          │                        │
       │     "Sign in with      │                        │
       │      Google"           │                        │
       │                        │                        │
       │  2. Open OAuth URL ────┼───────────────────────►│
       │                        │                        │
       │                        │       3. User grants   │
       │                        │          permission    │
       │                        │                        │
       │  4. Redirect with code │◄───────────────────────┤
       │                        │                        │
       │  5. Send code ─────────►                        │
       │                        │                        │
       │                        │  6. Exchange for       │
       │                        │     tokens ───────────►│
       │                        │                        │
       │                        │  7. User info ◄────────┤
       │                        │                        │
       │  8. JWT + Refresh ◄────┤                        │
       │     Token              │                        │
       │                        │                        │
       │  9. Store tokens       │                        │
       │     securely           │                        │
       ▼                        ▼                        ▼
```

### JWT Token Structure

```json
{
  "sub": "user_uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "roles": ["user"],
  "permissions": ["read", "write"],
  "iat": 1702800000,
  "exp": 1703404800
}
```

### Token Refresh Flow

1. Access token expires after 7 days
2. Refresh token valid for 30 days
3. Client automatically refreshes using interceptor
4. If refresh fails, user redirected to login

---

## 📅 Google Calendar Sync

### Two-Way Sync Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                     SYNC ENGINE                                 │
│                                                                 │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     │
│   │   Local     │     │    Sync     │     │   Google    │     │
│   │   Tasks     │◄───►│   Service   │◄───►│  Calendar   │     │
│   └─────────────┘     └─────────────┘     └─────────────┘     │
│                              │                                  │
│                       ┌──────▼──────┐                          │
│                       │  Conflict   │                          │
│                       │  Resolver   │                          │
│                       └─────────────┘                          │
└────────────────────────────────────────────────────────────────┘
```

### Sync Rules

| TodoListi Action | Google Calendar Result |
|------------------|------------------------|
| Create task with time | Create calendar event |
| Update task time | Update event time |
| Complete task | Mark event as completed (extended prop) |
| Delete task | Delete event |
| Add reminder | Add event notification |

| Google Calendar Action | TodoListi Result |
|------------------------|------------------|
| Create event | Create time-blocked task |
| Update event | Update task |
| Delete event | Mark task as deleted (soft) |
| Move event | Update task time |

### Conflict Resolution

1. **Last Write Wins**: Most recent change takes precedence
2. **User Notification**: User informed of conflicts
3. **Conflict Log**: All conflicts logged for audit
4. **Manual Override**: User can choose which version to keep

### Sync Frequency

- **Real-time**: WebSocket for immediate updates
- **Background**: Every 5 minutes when app is open
- **Push**: Google Calendar webhook notifications
- **Manual**: User can force sync anytime

---

## 👥 Assistant/PA Permission Model

### Role Hierarchy

```
┌─────────────────────────────────────────────────┐
│                    OWNER                         │
│  Full control of account and all data           │
│  Can assign/revoke PA permissions               │
└─────────────────────┬───────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────┐  ┌───────────┐  ┌───────────┐
│   FULL    │  │   EDIT    │  │   VIEW    │
│  CONTROL  │  │           │  │   ONLY    │
└───────────┘  └───────────┘  └───────────┘
```

### Permission Levels

| Permission | View Tasks | Edit Tasks | Delete Tasks | Manage Calendar | Invite Others |
|------------|------------|------------|--------------|-----------------|---------------|
| View Only | ✅ | ❌ | ❌ | ❌ | ❌ |
| Edit | ✅ | ✅ | ❌ | ✅ | ❌ |
| Full Control | ✅ | ✅ | ✅ | ✅ | ✅ |

### Permission Assignment Flow

```
1. Owner opens Settings → Assistants
2. Owner clicks "Invite Assistant"
3. Owner enters PA email and selects permission level
4. System sends invitation email
5. PA clicks link and signs in with Google
6. PA now has access to Owner's tasks (per permission level)
7. All PA actions logged in audit trail
```

### Audit Trail

Every action by a PA is logged:

```json
{
  "id": "uuid",
  "actor": "pa_user_id",
  "owner": "owner_user_id",
  "action": "UPDATE_TASK",
  "resource": "task_id",
  "before": { "title": "Old Title" },
  "after": { "title": "New Title" },
  "timestamp": "2024-01-15T10:30:00Z",
  "ip_address": "192.168.1.1",
  "user_agent": "TodoListi/1.0 (Windows)"
}
```

---

## 🗄 Database Schema

### Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    users    │       │ permissions │       │    tasks    │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │◄──────│ owner_id    │       │ id (PK)     │
│ email       │       │ assistant_id│───────│ user_id (FK)│
│ name        │       │ level       │       │ title       │
│ avatar_url  │       │ created_at  │       │ description │
│ google_id   │       │ expires_at  │       │ priority    │
│ created_at  │       └─────────────┘       │ due_date    │
│ updated_at  │                             │ completed   │
└─────────────┘                             │ parent_id   │
       │                                    │ project_id  │
       │                                    │ created_at  │
       │                                    │ updated_at  │
       │                                    │ deleted_at  │
       │                                    └─────────────┘
       │                                           │
       │       ┌─────────────┐                     │
       │       │  projects   │                     │
       │       ├─────────────┤                     │
       └──────►│ id (PK)     │◄────────────────────┘
               │ user_id (FK)│
               │ name        │       ┌─────────────┐
               │ color       │       │    tags     │
               │ icon        │       ├─────────────┤
               │ created_at  │       │ id (PK)     │
               └─────────────┘       │ user_id (FK)│
                                     │ name        │
┌─────────────┐                      │ color       │
│ audit_logs  │                      └─────────────┘
├─────────────┤                             │
│ id (PK)     │       ┌─────────────┐       │
│ actor_id    │       │  task_tags  │       │
│ owner_id    │       ├─────────────┤       │
│ action      │       │ task_id(FK) │───────┘
│ resource_id │       │ tag_id (FK) │
│ before      │       └─────────────┘
│ after       │
│ created_at  │       ┌─────────────┐
└─────────────┘       │  reminders  │
                      ├─────────────┤
┌─────────────┐       │ id (PK)     │
│calendar_sync│       │ task_id(FK) │
├─────────────┤       │ remind_at   │
│ id (PK)     │       │ type        │
│ user_id (FK)│       │ sent        │
│ google_id   │       └─────────────┘
│ sync_token  │
│ last_sync   │       ┌─────────────┐
└─────────────┘       │  recurrence │
                      ├─────────────┤
                      │ id (PK)     │
                      │ task_id(FK) │
                      │ pattern     │
                      │ interval    │
                      │ end_date    │
                      └─────────────┘
```

### Key Tables

#### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    google_id VARCHAR(255) UNIQUE,
    google_refresh_token TEXT, -- Encrypted
    settings JSONB DEFAULT '{}',
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### tasks
```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    priority INTEGER DEFAULT 0, -- 0=None, 1=Low, 2=Med, 3=High, 4=Urgent
    due_date TIMESTAMP,
    completed_at TIMESTAMP,
    google_event_id VARCHAR(255),
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP, -- Soft delete
    sync_version BIGINT DEFAULT 0
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_deleted ON tasks(deleted_at) WHERE deleted_at IS NULL;
```

#### permissions
```sql
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    assistant_id UUID REFERENCES users(id) ON DELETE CASCADE,
    level VARCHAR(20) NOT NULL, -- 'view', 'edit', 'full'
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    revoked_at TIMESTAMP,
    UNIQUE(owner_id, assistant_id)
);

CREATE INDEX idx_permissions_assistant ON permissions(assistant_id);
```

---

## 📚 API Documentation

### Base URL

```
Production: https://api.todolisti.com/v1
Development: http://localhost:3000/api/v1
```

### Authentication

All API requests (except auth endpoints) require a Bearer token:

```
Authorization: Bearer <jwt_token>
```

### Endpoints Summary

#### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/auth/google` | Initiate Google OAuth |
| GET | `/auth/google/callback` | Google OAuth callback |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout and invalidate tokens |

#### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | List all tasks |
| GET | `/tasks/:id` | Get single task |
| POST | `/tasks` | Create task |
| PATCH | `/tasks/:id` | Update task |
| DELETE | `/tasks/:id` | Delete task (soft) |
| POST | `/tasks/:id/complete` | Mark complete |
| POST | `/tasks/:id/reorder` | Reorder task |

#### Projects
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/projects` | List projects |
| POST | `/projects` | Create project |
| PATCH | `/projects/:id` | Update project |
| DELETE | `/projects/:id` | Delete project |

#### Permissions (PA System)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/permissions` | List my assistants |
| POST | `/permissions/invite` | Invite assistant |
| PATCH | `/permissions/:id` | Update permission level |
| DELETE | `/permissions/:id` | Revoke access |
| GET | `/permissions/accessible` | Accounts I can access |

#### Calendar Sync
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/calendar/connect` | Connect Google Calendar |
| DELETE | `/calendar/disconnect` | Disconnect calendar |
| POST | `/calendar/sync` | Force sync now |
| GET | `/calendar/status` | Get sync status |

#### Sync (WebSocket)
| Event | Direction | Description |
|-------|-----------|-------------|
| `sync:subscribe` | Client → Server | Subscribe to updates |
| `sync:push` | Client → Server | Push local changes |
| `sync:update` | Server → Client | Receive updates |
| `sync:conflict` | Server → Client | Conflict notification |

### Example Requests

#### Create Task
```http
POST /api/v1/tasks
Content-Type: application/json
Authorization: Bearer <token>

{
    "title": "Review quarterly report",
    "description": "Check all figures and charts",
    "priority": 3,
    "dueDate": "2024-01-20T14:00:00Z",
    "projectId": "uuid-here",
    "tags": ["work", "urgent"],
    "reminders": [
        {"type": "notification", "offset": 30}
    ]
}
```

#### Response
```json
{
    "success": true,
    "data": {
        "id": "task-uuid",
        "title": "Review quarterly report",
        "description": "Check all figures and charts",
        "priority": 3,
        "dueDate": "2024-01-20T14:00:00Z",
        "completed": false,
        "project": {
            "id": "uuid-here",
            "name": "Q1 Reports"
        },
        "tags": [
            {"id": "tag-1", "name": "work", "color": "#FF5722"},
            {"id": "tag-2", "name": "urgent", "color": "#F44336"}
        ],
        "createdAt": "2024-01-15T10:00:00Z",
        "updatedAt": "2024-01-15T10:00:00Z"
    }
}
```

---

## 🔄 Offline-First & Sync Strategy

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      FLUTTER APP                             │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │     UI       │───►│   Provider   │───►│  Repository  │  │
│  │   Layer      │    │    Layer     │    │    Layer     │  │
│  └──────────────┘    └──────────────┘    └───────┬──────┘  │
│                                                   │         │
│                      ┌────────────────────────────┼────┐    │
│                      │         SYNC ENGINE        │    │    │
│                      │  ┌─────────────────────────▼─┐  │    │
│                      │  │      Operation Queue      │  │    │
│                      │  │  (Pending Sync Actions)   │  │    │
│                      │  └─────────────┬─────────────┘  │    │
│                      │                │                │    │
│                      │  ┌─────────────▼─────────────┐  │    │
│                      │  │    Conflict Resolver      │  │    │
│                      │  └─────────────┬─────────────┘  │    │
│                      │                │                │    │
│                      └────────────────┼────────────────┘    │
│                                       │                     │
│  ┌──────────────┐                     │                     │
│  │   SQLite     │◄────────────────────┘                     │
│  │  (Drift DB)  │                                           │
│  └──────────────┘                                           │
└───────────────────────────────────────┬─────────────────────┘
                                        │
                            When Online │
                                        ▼
                              ┌─────────────────┐
                              │   REST API /    │
                              │   WebSocket     │
                              └─────────────────┘
```

### Sync States

| State | Description | UI Indicator |
|-------|-------------|--------------|
| `synced` | All changes uploaded | ✓ checkmark |
| `pending` | Changes queued | ↻ rotating |
| `syncing` | Currently syncing | ↑ uploading |
| `conflict` | Needs resolution | ⚠ warning |
| `error` | Sync failed | ✗ retry |

### Operation Queue

Every local change creates a sync operation:

```dart
class SyncOperation {
  final String id;
  final String entityType; // 'task', 'project', etc.
  final String entityId;
  final String action; // 'create', 'update', 'delete'
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;
}
```

### Conflict Resolution Strategy

1. **Version Vectors**: Each entity has a sync version
2. **Detection**: Server compares versions on update
3. **Resolution Options**:
   - **Auto (Last-Write-Wins)**: Most recent timestamp wins
   - **Manual**: User chooses which version to keep
   - **Merge**: Combine non-conflicting fields

### Background Sync

```dart
/// Sync service that runs in background
/// Uses workmanager for periodic sync on mobile
/// Uses timer for desktop platforms
class SyncService {
  // Sync every 5 minutes when app is open
  static const syncInterval = Duration(minutes: 5);
  
  // Retry failed syncs with exponential backoff
  // 1s → 2s → 4s → 8s → 16s (max)
  Future<void> syncWithRetry() async {
    // Implementation
  }
}
```

---

## 🔒 Security Practices

### Authentication Security

- ✅ OAuth 2.0 with PKCE for mobile
- ✅ JWT tokens with short expiry (7 days)
- ✅ Refresh tokens with longer expiry (30 days)
- ✅ Token rotation on refresh
- ✅ Secure token storage (flutter_secure_storage)

### Data Security

- ✅ HTTPS only (TLS 1.3)
- ✅ Sensitive data encrypted at rest (Google refresh tokens)
- ✅ Database passwords hashed (bcrypt)
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS prevention (input sanitization)

### API Security

- ✅ Rate limiting (100 req/min per user)
- ✅ Request validation (class-validator)
- ✅ CORS configuration
- ✅ Helmet.js for HTTP headers
- ✅ Request logging and monitoring

### Access Control

- ✅ Role-Based Access Control (RBAC)
- ✅ Permission checks on every request
- ✅ Audit logging for sensitive operations
- ✅ IP-based anomaly detection

### Mobile Security

- ✅ Certificate pinning
- ✅ Biometric authentication option
- ✅ Jailbreak/root detection
- ✅ Secure storage for credentials

---

## 🚀 Deployment Instructions

### Docker Deployment

```bash
# Build images
docker build -t todolisti-backend ./backend
docker build -t todolisti-web ./flutter_app/build/web

# Push to registry
docker push your-registry/todolisti-backend:v1.0
docker push your-registry/todolisti-web:v1.0

# Deploy with docker-compose
docker-compose -f docker-compose.prod.yml up -d
```

### AWS Deployment

1. **Infrastructure Setup**:
   - RDS PostgreSQL (db.t3.medium)
   - ElastiCache Redis (cache.t3.micro)
   - ECS Fargate for backend
   - S3 for static hosting and uploads
   - CloudFront for CDN
   - ALB for load balancing

2. **Secrets Management**:
   - Store secrets in AWS Secrets Manager
   - Use IAM roles for service access

3. **Deployment Steps**:
```bash
# Configure AWS CLI
aws configure

# Deploy infrastructure (using Terraform or CloudFormation)
cd infrastructure
terraform init
terraform apply

# Deploy application
aws ecr get-login-password | docker login --username AWS --password-stdin <ecr-url>
docker push <ecr-url>/todolisti-backend:latest
aws ecs update-service --cluster todolisti --service backend --force-new-deployment
```

### Mobile App Deployment

#### Android (Play Store)
```bash
# Build release
flutter build appbundle --release

# Upload to Play Console
# Use internal testing track first
```

#### iOS (App Store)
```bash
# Build release (requires macOS)
flutter build ios --release

# Archive in Xcode
# Upload to App Store Connect
```

### Environment Checklist

- [ ] Database migrations run
- [ ] Redis connection verified
- [ ] Google OAuth credentials updated for production
- [ ] Sentry DSN configured
- [ ] SSL certificates installed
- [ ] Environment variables set
- [ ] Monitoring alerts configured
- [ ] Backup strategy implemented
- [ ] Rate limiting tested
- [ ] Load testing completed

---

## 🔧 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # Backend Tests
  backend-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: cd backend && npm ci
      - run: cd backend && npm run lint
      - run: cd backend && npm run test
      - run: cd backend && npm run test:e2e

  # Flutter Tests
  flutter-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: cd flutter_app && flutter pub get
      - run: cd flutter_app && flutter analyze
      - run: cd flutter_app && flutter test

  # Build & Deploy (on main only)
  deploy:
    needs: [backend-test, flutter-test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Build and push Docker image
      # Deploy to cloud platform
```

### Pipeline Stages

1. **Lint & Format**: Code quality checks
2. **Unit Tests**: Business logic tests
3. **Integration Tests**: API and database tests
4. **Build**: Compile applications
5. **Security Scan**: Dependency vulnerability check
6. **Deploy Staging**: Auto-deploy to staging
7. **E2E Tests**: Full integration tests
8. **Deploy Production**: Manual approval + deploy

---

## 🤝 Contribution Guidelines

### Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Run tests: `npm test` and `flutter test`
6. Commit: `git commit -m 'feat: add amazing feature'`
7. Push: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

### Code Style

#### Dart/Flutter
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Format with `dart format`

#### TypeScript/NestJS
- Follow [NestJS Style Guide](https://docs.nestjs.com/)
- Use ESLint + Prettier
- Run `npm run lint` before committing

### Pull Request Checklist

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No linting errors
- [ ] Conventional commit messages
- [ ] PR description explains changes
- [ ] Screenshots for UI changes

---

## 🗺 Future Roadmap

### Q1 2024 (MVP Launch)
- [x] Core task management
- [x] Calendar view
- [x] Google Calendar sync
- [x] PA/Assistant system
- [x] Authentication
- [ ] Public beta launch

### Q2 2024 (Power Features)
- [ ] Notion import
- [ ] Focus timer (Pomodoro)
- [ ] Productivity analytics
- [ ] Goal tracking
- [ ] Templates

### Q3 2024 (Mobile Excellence)
- [ ] Widgets (Android/iOS)
- [ ] Apple Watch app
- [ ] Wear OS app
- [ ] Siri/Google Assistant integration
- [ ] Offline voice capture

### Q4 2024 (Monetization)
- [ ] Free/Pro tier launch
- [ ] Team workspaces
- [ ] Enterprise features
- [ ] API for integrations
- [ ] Zapier integration

### 2025 Vision
- [ ] AI-powered task suggestions
- [ ] Natural language processing
- [ ] Smart scheduling
- [ ] White-label solution
- [ ] Desktop apps (Electron)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- NestJS team for the powerful backend framework
- All contributors and early adopters

---

## 📞 Support

- **Documentation**: [docs.todolisti.com](https://docs.todolisti.com)
- **Issues**: [GitHub Issues](https://github.com/your-org/todolisti/issues)
- **Email**: support@todolisti.com
- **Discord**: [Join our community](https://discord.gg/todolisti)

---

**Built with ❤️ for productivity enthusiasts worldwide**
