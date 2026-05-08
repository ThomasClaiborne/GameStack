namespace Server.Domain;

using Server.Data;
using Server.Models;
public class QuestionService : IQuestionService
{
    private readonly IQuestionRepository _repository;

    public QuestionService(IQuestionRepository repository)
    {
        _repository = repository;
    }

    public async Task<Result<List<Question>>> GetAllAsync()
    {
        var result = new Result<List<Question>>();
        result.Payload = await _repository.GetAllAsync();
        return result;
    }
}