namespace Server.Domain;

using Server.Models;
using Server.DTOs;

public interface IQuestionService
{
    Task<Result<List<QuestionSummaryResponse>>> GetAllAsync();
}