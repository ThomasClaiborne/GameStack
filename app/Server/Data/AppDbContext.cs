using Microsoft.EntityFrameworkCore;
using Server.Models;

namespace Server.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<AppUser> Users { get; set; } = null!;
    public DbSet<Question> Questions { get; set; } = null!;
    public DbSet<Answer> Answers { get; set; } = null!;
    public DbSet<Comment> Comments { get; set; } = null!;
    public DbSet<QuestionVote> QuestionVotes { get; set; } = null!;
    public DbSet<AnswerVote> AnswerVotes { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // tell EF Core to use snake_case for table names
        modelBuilder.Entity<AppUser>().ToTable("app_user");
        modelBuilder.Entity<Answer>().ToTable("answer");
        modelBuilder.Entity<Comment>().ToTable("comment");
        modelBuilder.Entity<QuestionVote>().ToTable("question_vote");
        modelBuilder.Entity<AnswerVote>().ToTable("answer_vote");
        modelBuilder.Entity<Question>().ToTable("question");

        // Composite PKs — EF Core can't infer these by convention
        // treats combination of userid and question/answer id as primary key
        modelBuilder.Entity<QuestionVote>()
            .HasKey(qv => new { qv.UserId, qv.QuestionId });

        modelBuilder.Entity<AnswerVote>()
            .HasKey(av => new { av.UserId, av.AnswerId });


        // relationships - tells EF core how the entities are related and how to join them in queries
        modelBuilder.Entity<Question>()
            .HasOne(q => q.Author)
            .WithMany(u => u.Questions)
            .HasForeignKey(q => q.UserId);

        modelBuilder.Entity<Answer>()
            .HasOne(a => a.Author)
            .WithMany(u => u.Answers)
            .HasForeignKey(a => a.UserId);

        modelBuilder.Entity<Answer>()
            .HasOne(a => a.Question)
            .WithMany(q => q.Answers)
            .HasForeignKey(a => a.QuestionId);

        modelBuilder.Entity<Comment>()
            .HasOne(c => c.Author)
            .WithMany()
            .HasForeignKey(c => c.UserId);

        modelBuilder.Entity<Comment>()
            .HasOne(c => c.Answer)
            .WithMany(a => a.Comments)
            .HasForeignKey(c => c.AnswerId);

        // Circular reference fix — Question.BestAnswerId → Answer
        // Must be Restrict, not Cascade, to avoid a delete cycle
        // must clear the best answer reference before deleting a question or answer
        modelBuilder.Entity<Question>()
            .HasOne<Answer>()
            .WithMany()
            .HasForeignKey(q => q.BestAnswerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}