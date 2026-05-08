namespace Server.Controllers;


using Microsoft.AspNetCore.Mvc;
using Server.Domain;
using Server.Models;

[ApiController]
[Route("api/questions")]
public class QuestionController : ControllerBase
{
    private readonly IQuestionService _questionService;

    public QuestionController(IQuestionService questionService)
    {
        _questionService = questionService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await _questionService.GetAllAsync();

        return result.Type switch
        {
            ResultType.Success  => Ok(result.Payload),
            ResultType.NotFound => NotFound(result.Messages),
            _                   => BadRequest(result.Messages)
        };
    }
}