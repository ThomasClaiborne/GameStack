# GameStack — Class Diagram

---

## Notes on the NB Stack vs Java Stack

| Java (Dev10)             | C# / NB Stack                        |
|--------------------------|---------------------------------------|
| RowMapper<T>             | Not needed — EF Core maps automatically via navigation properties |
| JdbcClient               | AppDbContext (EF Core)                |
| @Service / @Repository   | Registered in Program.cs via builder.Services |
| ResponseEntity<T>        | IActionResult / ActionResult<T>       |
| @RestController          | [ApiController]                       |
| @GetMapping etc.         | [HttpGet], [HttpPost], etc.           |
| Result<T> (synchronous)  | Task<Result<T>> — async wrapper. await unwraps it. |
| ResultType enum          | ResultType enum — same concept, adds Forbidden |
| @NotNull / @NotBlank     | [Required] on DTOs (not domain models) |
| List<String> errors      | List<string> errors (C# lowercase)   |

---

## Models  (/Models)

> Plain C# classes (POCOs). No annotations needed on these.
> Validation annotations go on DTOs (request objects) instead.
> EF Core maps these to DB tables automatically by convention.
> Navigation properties (Author, Question, etc.) are NOT database columns.
> They are C# objects EF Core populates in memory via .Include() —
> the equivalent of writing a JOIN + RowMapper in Java.

```
┌─────────────────────────────────────────────────────────────┐
│ AppUser                                                     │
│ Represents a registered user. Maps to app_user table.       │
├─────────────────────────────────────────────────────────────┤
│ Fields                                                      │
│  - Id           : int                                       │
│  - CreatedAt    : DateTime                                  │
│  - UpdatedAt    : DateTime                                  │
│  - Username     : string                                    │
│  - Email        : string                                    │
│  - PasswordHash : string                                    │
│                                                             │
│  [Navigation — populated by EF Core .Include()]             │
│  - Questions    : List<Question>                            │
│  - Answers      : List<Answer>                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Question                                                    │
│ A question posted by a user. Maps to question table.        │
├─────────────────────────────────────────────────────────────┤
│ Fields                                                      │
│  - Id            : int                                      │
│  - CreatedAt     : DateTime                                 │
│  - UpdatedAt     : DateTime                                 │
│  - UserId        : int          (FK → app_user)             │
│  - Title         : string                                   │
│  - Body          : string                                   │
│  - BestAnswerId  : int?         (FK → answer, nullable)     │
│                                                             │
│  [Navigation]                                               │
│  - Author        : AppUser                                  │
│  - Answers       : List<Answer>                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Answer                                                      │
│ A response to a question. Maps to answer table.             │
├─────────────────────────────────────────────────────────────┤
│ Fields                                                      │
│  - Id          : int                                        │
│  - CreatedAt   : DateTime                                   │
│  - UpdatedAt   : DateTime                                   │
│  - UserId      : int       (FK → app_user)                  │
│  - QuestionId  : int       (FK → question)                  │
│  - Body        : string                                     │
│                                                             │
│  [Navigation]                                               │
│  - Author      : AppUser                                    │
│  - Question    : Question                                   │
│  - Comments    : List<Comment>                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Comment                                                     │
│ A short remark on an answer. Maps to comment table.         │
├─────────────────────────────────────────────────────────────┤
│ Fields                                                      │
│  - Id         : int                                         │
│  - CreatedAt  : DateTime                                    │
│  - UpdatedAt  : DateTime                                    │
│  - UserId     : int      (FK → app_user)                    │
│  - AnswerId   : int      (FK → answer)                      │
│  - Body       : string                                      │
│                                                             │
│  [Navigation]                                               │
│  - Author     : AppUser                                     │
│  - Answer     : Answer                                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ QuestionVote                                                │
│ A user's vote on a question. Composite PK.                  │
├─────────────────────────────────────────────────────────────┤
│ Fields                                                      │
│  - UserId      : int   (PK + FK → app_user)                 │
│  - QuestionId  : int   (PK + FK → question)                 │
│  - Value       : int   (1 or -1 only)                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ AnswerVote                                                  │
│ A user's vote on an answer. Composite PK.                   │
├─────────────────────────────────────────────────────────────┤
│ Fields                                                      │
│  - UserId    : int   (PK + FK → app_user)                   │
│  - AnswerId  : int   (PK + FK → answer)                     │
│  - Value     : int   (1 or -1 only)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Request DTOs  (/DTOs)

> Incoming HTTP request bodies are deserialized into these objects.
> Validation annotations ([Required], [StringLength], etc.) live here —
> NOT on domain models. [ApiController] auto-validates and returns
> 400 Bad Request before the controller method runs if invalid.
> Java equivalent: @RequestBody model classes annotated with @NotBlank etc.

```
┌─────────────────────────────────────────┐
│ RegisterRequest                         │
├─────────────────────────────────────────┤
│  - Username  : string   [Required]      │
│  - Email     : string   [EmailAddress]  │
│  - Password  : string   [Required]      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ LoginRequest                            │
├─────────────────────────────────────────┤
│  - Email     : string   [Required]      │
│  - Password  : string   [Required]      │
└─────────────────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│ CreateQuestionRequest                                │
├──────────────────────────────────────────────────────┤
│  - Title  : string   [Required] [StringLength(255)]  │
│  - Body   : string   [Required]                      │
└──────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│ UpdateQuestionRequest                                │
├──────────────────────────────────────────────────────┤
│  - Title  : string   [Required] [StringLength(255)]  │
│  - Body   : string   [Required]                      │
└──────────────────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ CreateAnswerRequest                     │
├─────────────────────────────────────────┤
│  - Body  : string   [Required]          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ UpdateAnswerRequest                     │
├─────────────────────────────────────────┤
│  - Body  : string   [Required]          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ CreateCommentRequest                    │
├─────────────────────────────────────────┤
│  - Body  : string   [Required]          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ UpdateCommentRequest                    │
├─────────────────────────────────────────┤
│  - Body  : string   [Required]          │
└─────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ VoteRequest                                      │
├──────────────────────────────────────────────────┤
│  - Value  : int   [Range(-1, 1)] (1 or -1 only)  │
└──────────────────────────────────────────────────┘
```

---

## Data Layer  (/Data)

> Repositories handle all DB reads and writes.
> Each interface (I*) has one EF Core implementation (Ef*Repository).
> AppDbContext is the EF Core equivalent of JdbcClient / DataSource.
> Java: interface + JdbcClientRepository injecting JdbcClient.
> C#:   interface + EfRepository injecting AppDbContext.

```
┌──────────────────────────────────────────────────────────────────────┐
│ AppDbContext  extends DbContext                                       │
│ The EF Core session. One instance per HTTP request (scoped).         │
│ Registered in Program.cs via builder.Services.AddDbContext<>().      │
├──────────────────────────────────────────────────────────────────────┤
│ DbSets (one per table — EF Core uses these to query/write)           │
│  - Users          : DbSet<AppUser>                                   │
│  - Questions      : DbSet<Question>                                  │
│  - Answers        : DbSet<Answer>                                    │
│  - Comments       : DbSet<Comment>                                   │
│  - QuestionVotes  : DbSet<QuestionVote>                              │
│  - AnswerVotes    : DbSet<AnswerVote>                                │
├──────────────────────────────────────────────────────────────────────┤
│  # OnModelCreating(builder: ModelBuilder) : void                     │
│    Configures composite PKs for QuestionVote and AnswerVote,         │
│    and any relationships EF Core cannot infer by convention.         │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IUserRepository  (interface)                                         │
│ Read and create users. Auth layer only — no update/delete.           │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByEmail(email: string)  : Task<AppUser?>                       │
│  + GetById(id: int)           : Task<AppUser?>                       │
│  + Create(user: AppUser)      : Task<AppUser>                        │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ EfUserRepository  implements IUserRepository                         │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _db : AppDbContext                                                │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByEmail(email: string)  : Task<AppUser?>                       │
│  + GetById(id: int)           : Task<AppUser?>                       │
│  + Create(user: AppUser)      : Task<AppUser>                        │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IQuestionRepository  (interface)                                     │
│ Full CRUD on questions + best answer selection + user scoping.       │
├──────────────────────────────────────────────────────────────────────┤
│  + GetAll()                                : Task<List<Question>>    │
│  + GetById(id: int)                        : Task<Question?>         │
│  + GetByUserId(userId: int)                : Task<List<Question>>    │
│  + Create(question: Question)              : Task<Question>          │
│  + Update(question: Question)              : Task<Question?>         │
│  + Delete(id: int)                         : Task<bool>              │
│  + SetBestAnswer(questionId: int,                                    │
│        answerId: int)                      : Task<bool>              │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ EfQuestionRepository  implements IQuestionRepository                 │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _db : AppDbContext                                                │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all IQuestionRepository methods)                        │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IAnswerRepository  (interface)                                       │
│ Full CRUD on answers. Scoped to a question or a user.                │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByQuestionId(questionId: int)  : Task<List<Answer>>            │
│  + GetByUserId(userId: int)          : Task<List<Answer>>            │
│  + GetById(id: int)                  : Task<Answer?>                 │
│  + Create(answer: Answer)            : Task<Answer>                  │
│  + Update(answer: Answer)            : Task<Answer?>                 │
│  + Delete(id: int)                   : Task<bool>                    │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ EfAnswerRepository  implements IAnswerRepository                     │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _db : AppDbContext                                                │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all IAnswerRepository methods)                          │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ ICommentRepository  (interface)                                      │
│ Full CRUD on comments. Scoped to an answer.                          │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByAnswerId(answerId: int)  : Task<List<Comment>>               │
│  + GetById(id: int)              : Task<Comment?>                    │
│  + Create(comment: Comment)      : Task<Comment>                     │
│  + Update(comment: Comment)      : Task<Comment?>                    │
│  + Delete(id: int)               : Task<bool>                        │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ EfCommentRepository  implements ICommentRepository                   │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _db : AppDbContext                                                │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all ICommentRepository methods)                         │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IVoteRepository  (interface)                                         │
│ Handles both question and answer votes (one domain concept).         │
├──────────────────────────────────────────────────────────────────────┤
│  + GetQuestionVoteTotal(questionId: int)         : Task<int>         │
│  + GetAnswerVoteTotal(answerId: int)             : Task<int>         │
│  + GetQuestionVote(userId: int,                                      │
│        questionId: int)                          : Task<QuestionVote?>│
│  + GetAnswerVote(userId: int,                                        │
│        answerId: int)                            : Task<AnswerVote?> │
│  + UpsertQuestionVote(vote: QuestionVote)        : Task              │
│  + UpsertAnswerVote(vote: AnswerVote)            : Task              │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ EfVoteRepository  implements IVoteRepository                         │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _db : AppDbContext                                                │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all IVoteRepository methods)                            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Domain Layer  (/Domain)

> Services contain all business logic, validation, and ownership checks.
> Each service depends on repository interfaces — never concrete classes.
> Java equivalent: @Service class injecting @Repository interfaces.
> Result<T> + ResultType mirror your Java pattern with one addition:
> ResultType.Forbidden covers ownership violations (403) —
> not needed in a console app but required in a Web API.

```
┌──────────────────────────────────────────────────────────────────────┐
│ ResultType  (enum)                                                   │
│ Signals to the controller which HTTP status code to return.          │
│ Java equivalent: your ResultType in learn.field_agent.domain.        │
│ Controller uses a switch on result.Type to pick the right response.  │
├──────────────────────────────────────────────────────────────────────┤
│ Values                                                               │
│  Success    → 200 OK / 201 Created / 204 No Content                  │
│  Invalid    → 400 Bad Request  (bad input, validation failure)       │
│  NotFound   → 404 Not Found    (resource does not exist)             │
│  Forbidden  → 403 Forbidden    (resource exists, user doesn't own it)│
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ Result<T>                                                            │
│ Wraps a service return — success payload or errors + result type.    │
│ Same concept as your Java Result<T>. Used across all services.       │
│ T is filled in at the call site: Result<Question>, Result<bool>, etc.│
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - Payload   : T?                                                    │
│  - Errors    : List<string>                                          │
│  - Type      : ResultType                    (default: Success)      │
├──────────────────────────────────────────────────────────────────────┤
│  + IsSuccess                               : bool (Type == Success)  │
│  + AddError(msg: string, type: ResultType) : void                    │
│    Sets both the error message and the result type together.         │
│    Java equivalent: addMessage(message, ResultType.INVALID)          │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IAuthService  (interface)                                            │
├──────────────────────────────────────────────────────────────────────┤
│  + Register(request: RegisterRequest)  : Task<Result<string>>        │
│    Validates input, hashes password (BCrypt), saves user,            │
│    returns signed JWT on success.                                    │
│                                                                      │
│  + Login(request: LoginRequest)        : Task<Result<string>>        │
│    GetByEmail → BCrypt.Verify → return JWT.                          │
│    Result.Type = NotFound if email missing.                          │
│    Result.Type = Invalid if password wrong.                          │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ AuthService  implements IAuthService                                 │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _userRepo  : IUserRepository                                      │
├──────────────────────────────────────────────────────────────────────┤
│  + Register(request: RegisterRequest)  : Task<Result<string>>        │
│  + Login(request: LoginRequest)        : Task<Result<string>>        │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IQuestionService  (interface)                                        │
├──────────────────────────────────────────────────────────────────────┤
│  + GetAll()                                  : Task<Result<List<Question>>>│
│  + GetById(id: int)                          : Task<Result<Question>>│
│  + GetByUserId(userId: int)                  : Task<Result<List<Question>>>│
│    Returns all questions posted by a specific user (profile page).   │
│                                                                      │
│  + Create(request: CreateQuestionRequest,                            │
│        userId: int)                          : Task<Result<Question>>│
│                                                                      │
│  + Update(id: int, request: UpdateQuestionRequest,                   │
│        userId: int)                          : Task<Result<Question>>│
│    Result.Type = NotFound if question missing.                       │
│    Result.Type = Forbidden if userId != question.UserId.             │
│                                                                      │
│  + Delete(id: int, userId: int)              : Task<Result<bool>>    │
│    Result.Type = NotFound if question missing.                       │
│    Result.Type = Forbidden if userId != question.UserId.             │
│                                                                      │
│  + SetBestAnswer(questionId: int,                                    │
│        answerId: int, userId: int)           : Task<Result<bool>>    │
│    Result.Type = Forbidden if userId != question.UserId.             │
│    Result.Type = Invalid if answer.QuestionId != questionId.         │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ QuestionService  implements IQuestionService                         │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _questionRepo  : IQuestionRepository                              │
│  - _answerRepo    : IAnswerRepository                                │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all IQuestionService methods)                           │
│  - Validate(request: CreateQuestionRequest) : Result<Question>       │
│    Private. Shared validation logic used by Create and Update.       │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IAnswerService  (interface)                                          │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByQuestionId(questionId: int)          : Task<Result<List<Answer>>>│
│  + GetByUserId(userId: int)                  : Task<Result<List<Answer>>>│
│    Returns all answers posted by a specific user (profile page).     │
│                                                                      │
│  + Create(questionId: int,                                           │
│        request: CreateAnswerRequest,                                 │
│        userId: int)                          : Task<Result<Answer>>  │
│    Result.Type = NotFound if question does not exist.                │
│                                                                      │
│  + Update(id: int, request: UpdateAnswerRequest,                     │
│        userId: int)                          : Task<Result<Answer>>  │
│    Result.Type = NotFound if answer missing.                         │
│    Result.Type = Forbidden if userId != answer.UserId.               │
│                                                                      │
│  + Delete(id: int, userId: int)              : Task<Result<bool>>    │
│    Result.Type = NotFound if answer missing.                         │
│    Result.Type = Forbidden if userId != answer.UserId.               │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ AnswerService  implements IAnswerService                             │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _answerRepo    : IAnswerRepository                                │
│  - _questionRepo  : IQuestionRepository                              │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all IAnswerService methods)                             │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ ICommentService  (interface)                                         │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByAnswerId(answerId: int)              : Task<Result<List<Comment>>>│
│                                                                      │
│  + Create(answerId: int,                                             │
│        request: CreateCommentRequest,                                │
│        userId: int)                          : Task<Result<Comment>> │
│    Result.Type = NotFound if answer does not exist.                  │
│                                                                      │
│  + Update(id: int, request: UpdateCommentRequest,                    │
│        userId: int)                          : Task<Result<Comment>> │
│    Result.Type = NotFound if comment missing.                        │
│    Result.Type = Forbidden if userId != comment.UserId.              │
│                                                                      │
│  + Delete(id: int, userId: int)              : Task<Result<bool>>    │
│    Result.Type = NotFound if comment missing.                        │
│    Result.Type = Forbidden if userId != comment.UserId.              │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ CommentService  implements ICommentService                           │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _commentRepo  : ICommentRepository                                │
│  - _answerRepo   : IAnswerRepository                                 │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all ICommentService methods)                            │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ IVoteService  (interface)                                            │
├──────────────────────────────────────────────────────────────────────┤
│  + VoteOnQuestion(questionId: int, userId: int,                      │
│        value: int)  : Task<Result<int>>                              │
│    Validates question exists first (NotFound if not).                │
│    Upserts vote row. Returns updated vote total on success.          │
│                                                                      │
│  + VoteOnAnswer(answerId: int, userId: int,                          │
│        value: int)  : Task<Result<int>>                              │
│    Validates answer exists first (NotFound if not).                  │
│    Upserts vote row. Returns updated vote total on success.          │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ VoteService  implements IVoteService                                 │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _voteRepo      : IVoteRepository                                  │
│  - _questionRepo  : IQuestionRepository   (existence check)          │
│  - _answerRepo    : IAnswerRepository     (existence check)          │
├──────────────────────────────────────────────────────────────────────┤
│  (implements all IVoteService methods)                               │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Controllers  (/Controllers)

> Thin HTTP layer. Receives request → calls service → maps ResultType → returns status code.
> userId is extracted from the JWT token via User.FindFirst() — never from the request body.
> [Authorize] marks endpoints that require a valid JWT.
> Java equivalent: @RestController using ResponseEntity + result.getType() switch.

```
┌──────────────────────────────────────────────────────────────────────┐
│ AuthController   [ApiController]  [Route("api/auth")]                │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _authService : IAuthService                                       │
├──────────────────────────────────────────────────────────────────────┤
│  + Register  [HttpPost("register")]                                  │
│      (request: RegisterRequest) : Task<IActionResult>               │
│    201 Created + JWT on success. 400 + errors on failure.            │
│                                                                      │
│  + Login     [HttpPost("login")]                                     │
│      (request: LoginRequest) : Task<IActionResult>                   │
│    200 OK + JWT on success. 404 or 400 mapped from ResultType.       │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ QuestionController   [ApiController]  [Route("api/questions")]       │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _questionService : IQuestionService                               │
├──────────────────────────────────────────────────────────────────────┤
│  + GetAll       [HttpGet]                                            │
│      () : Task<IActionResult>                                        │
│    200 OK + question list. Public.                                   │
│                                                                      │
│  + GetById      [HttpGet("{id}")]                                    │
│      (id: int) : Task<IActionResult>                                 │
│    200 OK + question. 404 if NotFound.                               │
│                                                                      │
│  + GetByUserId  [HttpGet("user/{userId}")]                           │
│      (userId: int) : Task<IActionResult>                             │
│    200 OK + question list. Public.                                   │
│                                                                      │
│  + Create       [HttpPost]  [Authorize]                              │
│      (request: CreateQuestionRequest) : Task<IActionResult>          │
│    201 Created + question. 400 if Invalid.                           │
│                                                                      │
│  + Update       [HttpPut("{id}")]  [Authorize]                       │
│      (id: int, request: UpdateQuestionRequest) : Task<IActionResult> │
│    200 OK + updated question. 404/403/400 mapped from ResultType.    │
│                                                                      │
│  + Delete       [HttpDelete("{id}")]  [Authorize]                    │
│      (id: int) : Task<IActionResult>                                 │
│    204 No Content. 404/403 mapped from ResultType.                   │
│                                                                      │
│  + SetBestAnswer  [HttpPut("{id}/best-answer/{answerId}")]  [Authorize]│
│      (id: int, answerId: int) : Task<IActionResult>                  │
│    200 OK. 404/403/400 mapped from ResultType.                       │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ AnswerController   [ApiController]  [Route("api")]                   │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _answerService : IAnswerService                                   │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByQuestionId  [HttpGet("questions/{questionId}/answers")]       │
│      (questionId: int) : Task<IActionResult>                         │
│    200 OK + answer list. Public.                                     │
│                                                                      │
│  + GetByUserId      [HttpGet("users/{userId}/answers")]               │
│      (userId: int) : Task<IActionResult>                             │
│    200 OK + answer list. Public.                                     │
│                                                                      │
│  + Create   [HttpPost("questions/{questionId}/answers")]  [Authorize] │
│      (questionId: int, request: CreateAnswerRequest)                 │
│      : Task<IActionResult>                                           │
│    201 Created + answer. 404 if question NotFound.                   │
│                                                                      │
│  + Update   [HttpPut("answers/{id}")]  [Authorize]                   │
│      (id: int, request: UpdateAnswerRequest) : Task<IActionResult>   │
│    200 OK + updated answer. 404/403 mapped from ResultType.          │
│                                                                      │
│  + Delete   [HttpDelete("answers/{id}")]  [Authorize]                │
│      (id: int) : Task<IActionResult>                                 │
│    204 No Content. 404/403 mapped from ResultType.                   │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ CommentController   [ApiController]  [Route("api")]                  │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _commentService : ICommentService                                 │
├──────────────────────────────────────────────────────────────────────┤
│  + GetByAnswerId  [HttpGet("answers/{answerId}/comments")]            │
│      (answerId: int) : Task<IActionResult>                           │
│    200 OK + comment list. Public.                                    │
│                                                                      │
│  + Create   [HttpPost("answers/{answerId}/comments")]  [Authorize]   │
│      (answerId: int, request: CreateCommentRequest)                  │
│      : Task<IActionResult>                                           │
│    201 Created + comment. 404 if answer NotFound.                    │
│                                                                      │
│  + Update   [HttpPut("comments/{id}")]  [Authorize]                  │
│      (id: int, request: UpdateCommentRequest) : Task<IActionResult>  │
│    200 OK + updated comment. 404/403 mapped from ResultType.         │
│                                                                      │
│  + Delete   [HttpDelete("comments/{id}")]  [Authorize]               │
│      (id: int) : Task<IActionResult>                                 │
│    204 No Content. 404/403 mapped from ResultType.                   │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│ VoteController   [ApiController]  [Route("api")]  [Authorize]        │
├──────────────────────────────────────────────────────────────────────┤
│ Fields                                                               │
│  - _voteService : IVoteService                                       │
├──────────────────────────────────────────────────────────────────────┤
│  + VoteOnQuestion  [HttpPost("questions/{id}/vote")]                  │
│      (id: int, request: VoteRequest) : Task<IActionResult>           │
│    200 OK + new vote total. 404 if question NotFound.                │
│    400 if value not 1 or -1.                                         │
│                                                                      │
│  + VoteOnAnswer    [HttpPost("answers/{id}/vote")]                    │
│      (id: int, request: VoteRequest) : Task<IActionResult>           │
│    200 OK + new vote total. 404 if answer NotFound.                  │
│    400 if value not 1 or -1.                                         │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Dependency Registration  (Program.cs)

> Java equivalent: your App.java composition root.
> AddScoped = one instance per HTTP request, then discarded.
> Use AddScoped for everything that touches EF Core — DbContext is
> scoped by default, and anything depending on it must also be scoped.
> AddSingleton would cause a "cannot consume scoped from singleton" error.

```
builder.Services.AddScoped<IUserRepository,     EfUserRepository>();
builder.Services.AddScoped<IQuestionRepository, EfQuestionRepository>();
builder.Services.AddScoped<IAnswerRepository,   EfAnswerRepository>();
builder.Services.AddScoped<ICommentRepository,  EfCommentRepository>();
builder.Services.AddScoped<IVoteRepository,     EfVoteRepository>();

builder.Services.AddScoped<IAuthService,        AuthService>();
builder.Services.AddScoped<IQuestionService,    QuestionService>();
builder.Services.AddScoped<IAnswerService,      AnswerService>();
builder.Services.AddScoped<ICommentService,     CommentService>();
builder.Services.AddScoped<IVoteService,        VoteService>();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));
```

---

## Project Folder Structure  (/server)

```
server/
├── Controllers/
│   ├── AuthController.cs
│   ├── QuestionController.cs
│   ├── AnswerController.cs
│   ├── CommentController.cs
│   └── VoteController.cs
├── Data/
│   ├── AppDbContext.cs
│   ├── IUserRepository.cs       EfUserRepository.cs
│   ├── IQuestionRepository.cs   EfQuestionRepository.cs
│   ├── IAnswerRepository.cs     EfAnswerRepository.cs
│   ├── ICommentRepository.cs    EfCommentRepository.cs
│   └── IVoteRepository.cs       EfVoteRepository.cs
├── Domain/
│   ├── ResultType.cs
│   ├── Result.cs
│   ├── IAuthService.cs          AuthService.cs
│   ├── IQuestionService.cs      QuestionService.cs
│   ├── IAnswerService.cs        AnswerService.cs
│   ├── ICommentService.cs       CommentService.cs
│   └── IVoteService.cs          VoteService.cs
├── Models/
│   ├── AppUser.cs
│   ├── Question.cs
│   ├── Answer.cs
│   ├── Comment.cs
│   ├── QuestionVote.cs
│   └── AnswerVote.cs
├── DTOs/
│   ├── RegisterRequest.cs
│   ├── LoginRequest.cs
│   ├── CreateQuestionRequest.cs
│   ├── UpdateQuestionRequest.cs
│   ├── CreateAnswerRequest.cs
│   ├── UpdateAnswerRequest.cs
│   ├── CreateCommentRequest.cs
│   ├── UpdateCommentRequest.cs
│   └── VoteRequest.cs
└── Program.cs
```