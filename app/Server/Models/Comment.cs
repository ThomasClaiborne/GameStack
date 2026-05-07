namespace Server.Models;
public class Comment
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    // Foreign key to AppUser
    public int UserId { get; set; }
    // Foreign key to Answer
    public int AnswerId { get; set; }
    public string Body { get; set; } = null!;

    // Navigation — EF Core populates these via .Include()
    public AppUser Author { get; set; } = null!;
    public Answer Answer { get; set; } = null!;
}