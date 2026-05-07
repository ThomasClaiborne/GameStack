using Mircrosoft.EntityFrameworkCore;
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
        // Composite PKs — EF Core can't infer these by convention
        modelBuilder.Entity<QuestionVote>()
            .HasKey(qv => new { qv.UserId, qv.QuestionId });

        modelBuilder.Entity<AnswerVote>()
            .HasKey(av => new { av.UserId, av.AnswerId });

        // Circular reference fix — Question.BestAnswerId → Answer
        // Must be Restrict, not Cascade, to avoid a delete cycle
        modelBuilder.Entity<Question>()
            .HasOne<Answer>()
            .WithMany()
            .HasForeignKey(q => q.BestAnswerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}