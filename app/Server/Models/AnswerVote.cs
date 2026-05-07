namespace Server.Models;

public class AnswerVote
{
    public int UserId { get; set; }
    public int AnswerId { get; set; }
    public int Value { get; set; }
}