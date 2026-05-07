namespace Server.Models;

public class QuestionVote
{
    public int UserId { get; set; }
    public int QuestionId { get; set; }
    public int Value { get; set; }
}