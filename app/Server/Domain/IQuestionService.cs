namespace Server.Domain;

using Server.Models;

public interface IQuestionService
{
    Task<Result<List<Question>>> GetAllAsync();
}