# GameStack — Frontend Plan

---

## Tech Stack

| Concern        | Tool                          |
|----------------|-------------------------------|
| Framework      | Angular (TypeScript)          |
| Styling        | Bootstrap 5 (CDN)             |
| HTTP           | Angular HttpClient            |
| Routing        | Angular Router                |
| Auth state     | AuthService + BehaviorSubject |
| Forms          | Angular Reactive Forms        |

---

## Routes

| Path                | Component               | Guard         |
|---------------------|-------------------------|---------------|
| `/`                 | HomeComponent           | public        |
| `/questions/:id`    | QuestionDetailComponent | public        |
| `/login`            | LoginComponent          | PublicOnly    |
| `/register`         | RegisterComponent       | PublicOnly    |

> PublicOnly guard redirects logged-in users away from login/register back to `/`.
> No AuthGuard needed yet — posting requires login but we handle that inline
> (redirect to /login if not logged in when they try to post).

---

## Auth State

```
AuthService
  - currentUser$  : BehaviorSubject<AppUser | null>
                    null = logged out
                    AppUser object = logged in

  + login(token: string, user: AppUser) : void
    Stores JWT in localStorage. Emits user to currentUser$.

  + logout() : void
    Clears localStorage. Emits null to currentUser$.

  + getToken() : string | null
    Reads JWT from localStorage. Used by HTTP interceptor.

  + isLoggedIn() : boolean
    Returns currentUser$.value !== null.

  + getCurrentUserId() : number | null
    Returns currentUser$.value?.id ?? null.
```

> NavbarComponent subscribes to currentUser$ to decide which nav to render.
> Components that need the current user inject AuthService directly.
> HTTP interceptor reads getToken() and attaches Authorization header
> to every outbound request automatically.

---

## Component Tree

```
AppComponent
├── NavbarComponent
└── <router-outlet>
    ├── HomeComponent
    │   └── QuestionCardComponent        (*ngFor — one per question)
    ├── QuestionDetailComponent
    │   ├── VoteComponent                (question votes)
    │   ├── ActionsMenuComponent         (edit/delete — owner only)
    │   ├── AnswerFormComponent          (post answer — logged in only)
    │   └── AnswerItemComponent          (*ngFor — one per answer)
    │       ├── VoteComponent            (answer votes — same component reused)
    │       ├── ActionsMenuComponent     (edit/delete — owner only)
    │       ├── CommentItemComponent     (*ngFor — one per comment)
    │       │   └── ActionsMenuComponent (edit/delete — owner only)
    │       └── CommentFormComponent     (post comment — logged in only)
    ├── LoginComponent
    └── RegisterComponent
```

---

## Component Specs

---

### NavbarComponent

**Responsibility:** Global navigation. Switches between logged-out and logged-in state.

**Template (logged out):**
```
[ GameStack logo/image ]  [ Search bar ]  [ Log In ]  [ Sign Up ]
```

**Template (logged in):**
```
[ GameStack logo/image ]  [ Search bar ]  [ Username ]
```

**State:**
```typescript
currentUser$ = this.authService.currentUser$  // subscribed via async pipe
```

**Notes:**
- Logo links to `/`
- Search bar is a placeholder for now (stretch goal)
- Username button does nothing for now
- Uses `*ngIf="currentUser$ | async as user; else loggedOut"` to switch templates
- Login → `/login`, Sign Up → `/register`

---

### HomeComponent

**Responsibility:** Fetches and displays all questions, newest first.

**State:**
```typescript
questions : Question[]   // fetched on ngOnInit
isLoading : boolean
error     : string | null
```

**Template layout:**
```
[ Page heading: "All Questions" ]   [ Ask Question button — logged in only ]
────────────────────────────────────────────────────────
[ QuestionCardComponent ]   ← repeated via *ngFor
[ QuestionCardComponent ]
[ QuestionCardComponent ]
...
```

**Notes:**
- Calls `GET /api/questions` on `ngOnInit()`
- Questions sorted by `createdAt` descending (newest first) — handled by backend
- "Ask Question" button navigates to `/questions/new` (stretch) or opens inline form (stretch)
- For MVP: asking a question is handled inside QuestionDetailComponent flow

---

### QuestionCardComponent

**Responsibility:** Displays a summary row for one question in the list.

**Inputs:**
```typescript
@Input() question: Question
```

**Template layout:**
```
┌──────────────────────────────────────────────────────────────┐
│  [vote total]  [answer count]  │  Question title (link)       │
│                                │  Body preview (truncated)    │
│                                │  author · created/updated    │
└──────────────────────────────────────────────────────────────┘
```

**Notes:**
- Title is a `[routerLink]` to `/questions/:id`
- Body truncated to ~150 characters with `...`
- Shows `updated: X hours ago` if `updatedAt > createdAt`, otherwise `asked: X hours ago`
- Answer count badge is green if answers > 0, gray if 0
- No vote buttons here — vote total is display only in the list

---

### QuestionDetailComponent  (routed: `/questions/:id`)

**Responsibility:** Full question view + answer list + answer form.

**State:**
```typescript
question      : Question | null
answers       : Answer[]
isLoading     : boolean
currentUserId : number | null    // from AuthService
isEditing     : boolean          // toggles inline edit form
```

**Template layout:**
```
[ Question title ]
[ vote total + upvote/downvote buttons ]   [ ... menu — if owner ]
[ Question body  (or inline edit form if isEditing) ]
[ author · asked/updated timestamp ]

────────────────────── Your Answer ───────────────────────
[ AnswerFormComponent — visible if logged in ]
[ "Log in to post an answer" link — if logged out ]

────────────────────── Answers ────────────────────────────
[ filter dropdown — placeholder ]
[ AnswerItemComponent ]   ← *ngFor, best answer pinned first
[ AnswerItemComponent ]
...
```

**Notes:**
- Fetches `GET /api/questions/:id` and `GET /api/questions/:id/answers` on `ngOnInit()`
- Best answer sorted to top, rendered with green left border
- Delete triggers `ConfirmDeleteComponent` inline
- Inline edit shows separate title input + body textarea, prepopulated

---

### VoteComponent  (reusable)

**Responsibility:** Displays vote total and handles upvote/downvote for a question or answer.

**Inputs:**
```typescript
@Input() targetId   : number
@Input() targetType : VoteTargetType   // enum: Question | Answer
@Input() voteTotal  : number
```

**Outputs:**
```typescript
@Output() voteCast = new EventEmitter<number>()  // emits new total after vote
```

**Template layout:**
```
▲  (upvote button)
[vote total]
▼  (downvote button)
```

**Notes:**
- Picks URL based on targetType:
  - `Question` → `POST /api/questions/:id/vote`
  - `Answer`   → `POST /api/answers/:id/vote`
- Sends `{ value: 1 }` or `{ value: -1 }`
- If not logged in, clicking redirects to `/login`
- Emits new total to parent via `voteCast`
- Parent updates its own `voteTotal` binding on emit

**VoteTargetType enum:**
```typescript
export enum VoteTargetType {
  Question,
  Answer
}
```

---

### ActionsMenuComponent  (reusable)

**Responsibility:** The `...` dropdown shown on owned questions, answers, and comments.

**Inputs:**
```typescript
@Input() showEdit   : boolean   // show Edit option
@Input() showDelete : boolean   // show Delete option
```

**Outputs:**
```typescript
@Output() onEdit   = new EventEmitter<void>()
@Output() onDelete = new EventEmitter<void>()
```

**Template:**
```
[ ··· ]  →  dropdown:  [ Edit ]  [ Delete ]
```

**Notes:**
- Parent decides whether to render this component at all (`*ngIf="isOwner"`)
- Parent listens to `(onEdit)` and `(onDelete)` and handles the logic
- Used identically on QuestionDetailComponent, AnswerItemComponent, CommentItemComponent

---

### AnswerFormComponent

**Responsibility:** Text input + Post button for submitting a new answer.

**Inputs:**
```typescript
@Input() questionId: number
```

**Outputs:**
```typescript
@Output() answerPosted = new EventEmitter<Answer>()  // emits new answer to parent
```

**Template:**
```
[ Your Answer ]
[ textarea — Reactive Form control ]
[ Post Your Answer button ]
```

**Notes:**
- Uses Angular Reactive Forms (`FormGroup` + `FormControl`)
- On success, emits the new `Answer` to `QuestionDetailComponent`
  which prepends it to the answer list without a full page reload
- Only rendered when user is logged in

---

### AnswerItemComponent

**Responsibility:** Displays one answer with its votes, edit/delete, and comment section.

**Inputs:**
```typescript
@Input() answer        : Answer
@Input() currentUserId : number | null
@Input() isBestAnswer  : boolean
@Input() isQuestionOwner : boolean   // controls Best Answer button visibility
```

**Outputs:**
```typescript
@Output() bestAnswerSelected = new EventEmitter<number>()  // emits answerId
@Output() answerDeleted      = new EventEmitter<number>()  // emits answerId
@Output() answerUpdated      = new EventEmitter<Answer>()
```

**Template layout:**
```
┌─────────────────────────────────────────── (green border if best answer)
│  [VoteComponent]   Answer body (or inline edit textarea)
│                    author · asked/updated timestamp
│                    [Best Answer button — question owner only]
│                    [... ActionsMenuComponent — answer owner only]
│
│  ── Comments ──────────────────────────────────────────────────
│      [CommentItemComponent]   ← *ngFor, indented
│      [CommentItemComponent]
│      [CommentFormComponent]   ← at bottom of comment list
│  [Show/Hide comments toggle]
└─────────────────────────────────────────────────────────────────
```

**Notes:**
- Best answer has green left border + "✓ Best Answer" badge
- Comment list is collapsed by default, toggled by Show/Hide
- Inline edit prepopulates textarea with `answer.body`

---

### CommentItemComponent

**Responsibility:** Displays one comment with edit/delete for owner.

**Inputs:**
```typescript
@Input() comment       : Comment
@Input() currentUserId : number | null
```

**Outputs:**
```typescript
@Output() commentDeleted = new EventEmitter<number>()
@Output() commentUpdated = new EventEmitter<Comment>()
```

**Template:**
```
    [author]: [comment body]  · [timestamp]  [... ActionsMenuComponent — owner only]
```

**Notes:**
- Indented to visually nest under its answer (Bootstrap `ms-4`)
- Inline edit replaces body text with a small input + Save button

---

### CommentFormComponent

**Responsibility:** Input + Post button for submitting a new comment on an answer.

**Inputs:**
```typescript
@Input() answerId: number
```

**Outputs:**
```typescript
@Output() commentPosted = new EventEmitter<Comment>()
```

**Template:**
```
[ Add a comment... input ]  [ Post ]
```

**Notes:**
- Small, inline — not a full textarea
- Only rendered when user is logged in
- Emits new comment to `AnswerItemComponent` which appends it to the list

---

### LoginComponent  (routed: `/login`)

**Responsibility:** Login form. On success stores JWT and navigates to `/`.

**Template:**
```
[ Email input ]
[ Password input ]
[ Log In button ]
[ Link: "Don't have an account? Sign up" ]
```

---

### RegisterComponent  (routed: `/register`)

**Responsibility:** Register form. On success stores JWT and navigates to `/`.

**Template:**
```
[ Username input ]
[ Email input ]
[ Password input ]
[ Sign Up button ]
[ Link: "Already have an account? Log in" ]
```

---

## Folder Structure  (/client/src/app)

```
src/app/
├── core/
│   ├── auth.service.ts
│   ├── auth.interceptor.ts        (attaches JWT to every request)
│   └── vote-target-type.enum.ts
├── shared/
│   ├── vote/
│   │   ├── vote.component.ts
│   │   ├── vote.component.html
│   │   └── vote.component.css
│   ├── actions-menu/
│   │   ├── actions-menu.component.ts
│   │   ├── actions-menu.component.html
│   │   └── actions-menu.component.css
│   └── navbar/
│       ├── navbar.component.ts
│       ├── navbar.component.html
│       └── navbar.component.css
├── features/
│   ├── home/
│   │   ├── home.component.ts
│   │   ├── home.component.html
│   │   ├── question-card/
│   │   │   ├── question-card.component.ts
│   │   │   └── question-card.component.html
│   ├── question-detail/
│   │   ├── question-detail.component.ts
│   │   ├── question-detail.component.html
│   │   ├── answer-form/
│   │   ├── answer-item/
│   │   │   ├── answer-item.component.ts
│   │   │   ├── answer-item.component.html
│   │   │   ├── comment-item/
│   │   │   └── comment-form/
│   ├── login/
│   │   └── login.component.ts
│   └── register/
│       └── register.component.ts
├── models/
│   ├── app-user.model.ts
│   ├── question.model.ts
│   ├── answer.model.ts
│   └── comment.model.ts
└── app.routes.ts
```

---

## TypeScript Models  (/models)

> Mirror the C# backend models. These are just interfaces — no logic.

```typescript
export interface AppUser {
  id: number;
  username: string;
  email: string;
  createdAt: string;
}

export interface Question {
  id: number;
  userId: number;
  authorUsername: string;
  title: string;
  body: string;
  bestAnswerId: number | null;
  voteTotal: number;
  createdAt: string;
  updatedAt: string;
}

export interface Answer {
  id: number;
  userId: number;
  questionId: number;
  authorUsername: string;
  body: string;
  voteTotal: number;
  createdAt: string;
  updatedAt: string;
}

export interface Comment {
  id: number;
  userId: number;
  answerId: number;
  authorUsername: string;
  body: string;
  createdAt: string;
  updatedAt: string;
}
```
