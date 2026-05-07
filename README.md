# GameStack

A gaming-flavored Q&A community platform — ask questions, post answers, vote on content, and find the best solutions together.

Built as a full-stack pre-capstone project using the Neuberger Berman production stack: **C# / ASP.NET Core** backend and **Angular** frontend.

---

## Features

**Unauthenticated users can:**
- View all questions, sorted newest first
- Click into a question to read it and its answers in full
- See vote totals, authors, and post timestamps

**Authenticated users can:**
- Post new questions
- Edit or delete their own questions
- Post answers to any question
- Edit or delete their own answers
- Post comments on answers
- Edit or delete their own comments
- Vote +1 or -1 on any question or answer
- Select a best answer on their own question

---

## Tech Stack

| Layer      | Technology                              |
|------------|-----------------------------------------|
| Frontend   | Angular 19 (TypeScript)                 |
| Styling    | Bootstrap 5                             |
| Backend    | ASP.NET Core Web API (.NET 9)           |
| Database   | MySQL                                   |
| ORM        | Entity Framework Core (Pomelo connector)|
| Auth       | JWT (Bearer tokens) + BCrypt            |
| Testing    | xUnit + Moq                             |

---

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- [Node.js + npm](https://nodejs.org/)
- [Angular CLI](https://angular.dev/tools/cli) — `npm install -g @angular/cli`
- [MySQL](https://dev.mysql.com/downloads/)

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/ThomasClaiborne/GameStack.git
cd GameStack
```

### 2. Set up the database

Create a MySQL database named `gamestack` and run the schema script:

```bash
mysql -u root -p gamestack < docs/Database\ Design/schema.sql
```

### 3. Configure the backend

Create a `.env` file in `app/Server/` (never committed):

```
DB_CONNECTION_STRING=server=localhost;database=gamestack;user=root;password=yourpassword
JWT_SECRET=your-secret-key-here
```

### 4. Run the backend

```bash
cd app/Server
dotnet run
```

API runs at `http://localhost:5000`
Swagger UI at `http://localhost:5000/swagger`

### 5. Run the frontend

```bash
cd app/Client
ng serve
```

App runs at `http://localhost:4200`

---

## Project Structure

```
GameStack/
├── app/
│   ├── Client/                  ← Angular frontend
│   │   └── src/
│   │       ├── app/
│   │       │   ├── core/        ← AuthService, HTTP interceptor
│   │       │   ├── shared/      ← reusable components (Vote, ActionsMenu, Navbar)
│   │       │   ├── features/    ← page components (Home, QuestionDetail, Login, Register)
│   │       │   └── models/      ← TypeScript interfaces mirroring backend models
│   │       └── styles.css
│   └── Server/                  ← ASP.NET Core backend
│       ├── Controllers/         ← HTTP layer ([ApiController] classes)
│       ├── Domain/              ← Business logic (services + Result<T> + ResultType)
│       ├── Data/                ← Repository interfaces + EF Core implementations
│       ├── Models/              ← Plain C# POCOs (EF Core entities)
│       ├── DTOs/                ← Request objects with validation annotations
│       └── Program.cs           ← Entry point + dependency registration
└── docs/
    ├── Database Design/         ← Schema diagram + DBML
    ├── Backend Design/          ← Class diagram
    └── Frontend Design/         ← Component plan
```

---

## API Endpoints

| Method | Endpoint                                    | Auth     | Description                  |
|--------|---------------------------------------------|----------|------------------------------|
| POST   | `/api/auth/register`                        | Public   | Create account                |
| POST   | `/api/auth/login`                           | Public   | Log in, receive JWT           |
| GET    | `/api/questions`                            | Public   | All questions, newest first   |
| GET    | `/api/questions/:id`                        | Public   | Single question               |
| POST   | `/api/questions`                            | Required | Post a question               |
| PUT    | `/api/questions/:id`                        | Required | Edit own question             |
| DELETE | `/api/questions/:id`                        | Required | Delete own question           |
| PUT    | `/api/questions/:id/best-answer/:answerId`  | Required | Set best answer               |
| GET    | `/api/questions/:id/answers`               | Public   | All answers for a question    |
| POST   | `/api/questions/:id/answers`               | Required | Post an answer                |
| PUT    | `/api/answers/:id`                          | Required | Edit own answer               |
| DELETE | `/api/answers/:id`                          | Required | Delete own answer             |
| GET    | `/api/answers/:id/comments`                | Public   | All comments on an answer     |
| POST   | `/api/answers/:id/comments`                | Required | Post a comment                |
| PUT    | `/api/comments/:id`                         | Required | Edit own comment              |
| DELETE | `/api/comments/:id`                         | Required | Delete own comment            |
| POST   | `/api/questions/:id/vote`                   | Required | Vote on a question            |
| POST   | `/api/answers/:id/vote`                     | Required | Vote on an answer             |

---

## Architecture

This project follows a **domain-driven, layered architecture**:

- **Controllers** receive HTTP requests and delegate to services — no business logic lives here
- **Services** own all validation, business rules, and ownership checks — return `Result<T>` with a `ResultType` so the controller knows which HTTP status code to send
- **Repositories** handle all database access through interfaces — EF Core implementations are swappable
- **Models** are plain C# classes (POCOs) — EF Core maps these to database tables via convention and navigation properties

---

## Developer

**Thomas Claiborne** — Dev10 Cohort 2026-3