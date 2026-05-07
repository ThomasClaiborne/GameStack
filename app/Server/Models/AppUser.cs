namespace Server.Models;

public class AppUser
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Username { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string PasswordHash { get; set; } = null!;

    // Navigation — EF Core populates these via .Include()
    public List<Question> Questions { get; set; } = new();
    public List<Answer> Answers { get; set; } = new();
}