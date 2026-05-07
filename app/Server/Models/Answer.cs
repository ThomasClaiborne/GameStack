namespace Server.Models;

public class Answer
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    // Foreign key to AppUser
    public int UserId { get; set; }
    // Foreign key to Question
    public int QuestionId { get; set; }
    public string Body { get; set; } = null!;

    // Navigation — EF Core populates these via .Include()
    public AppUser Author { get; set; } = null!;
    public Question Question { get; set; } = null!;
    public List<Comment> Comments { get; set; } = new();
}