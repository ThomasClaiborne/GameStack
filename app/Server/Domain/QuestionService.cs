namespace Server.Domain;

using Server.Data;
using Server.Models;
using Server.DTOs;
public class QuestionService : IQuestionService
{
    private readonly IQuestionRepository _repository;

    public QuestionService(IQuestionRepository repository)
    {
        _repository = repository;
    }

    public async Task<Result<List<QuestionSummaryResponse>>> GetAllAsync()
    {
        var result = new Result<List<QuestionSummaryResponse>>();
        var questions = await _repository.GetAllAsync();

        result.Payload = questions.Select(q => new QuestionSummaryResponse
        {
            Id = q.Id,
            Title = q.Title,
            Body = q.Body,
            AuthorUsername = q.Author.Username,
            BestAnswerId = q.BestAnswerId,
            CreatedAt = q.CreatedAt,
            UpdatedAt = q.UpdatedAt
        }).ToList();

        return result;
    }
}