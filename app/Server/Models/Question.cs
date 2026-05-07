namespace Server.Models;

public class Question
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    // Foreign key to AppUser
    public int UserId { get; set; }
    public string Title { get; set; } = null!;
    public string Body { get; set; } = null!;
    public int? BestAnswerId { get; set; }

    // Navigation — EF Core populates these via .Include()
    public AppUser Author { get; set; } = null!;
    public List<Answer> Answers { get; set; } = new();
}