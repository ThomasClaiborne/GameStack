namespace Server.DTOs;

public class QuestionSummaryResponse
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;

    public string Body { get; set; } = null!;

    public string AuthorUsername { get; set; } = null!;

    public int? BestAnswerId { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}