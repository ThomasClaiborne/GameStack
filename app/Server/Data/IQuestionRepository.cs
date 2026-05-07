namespace Server.Data;

using Server.Models;

public interface IQuestionRepository
{
    Task<List<Question>> GetAllAsync();
}