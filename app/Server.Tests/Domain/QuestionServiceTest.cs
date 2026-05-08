namespace Server.Tests.Domain;

using Moq;
using Server.Data;
using Server.Domain;
using Server.Models;
using Server.DTOs;

public class QuestionServiceTest
{
    private readonly Mock<IQuestionRepository> _mockRepository;
    private readonly IQuestionService _service;

    public QuestionServiceTest()
    {
        _mockRepository = new Mock<IQuestionRepository>();
        _service = new QuestionService(_mockRepository.Object);
    }

    [Fact]
    public async Task GetAllAsync_ShouldReturnSuccessWithQuestions()
    {
        // Arrange
        var fakeQuestions = new List<Question>
{
        new Question { Id = 1, Title = "Test Question 1", Body = "Body 1", UserId = 1,
            Author = new AppUser { Id = 1, Username = "test_user1" } },
        new Question { Id = 2, Title = "Test Question 2", Body = "Body 2", UserId = 1,
            Author = new AppUser { Id = 1, Username = "test_user1" } },
        new Question { Id = 3, Title = "Test Question 3", Body = "Body 3", UserId = 2,
            Author = new AppUser { Id = 2, Username = "test_user2" } }
};

        _mockRepository.Setup(r => r.GetAllAsync())
            .ReturnsAsync(fakeQuestions);

        // Act
        var result = await _service.GetAllAsync();

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal(3, result.Payload!.Count);
        Assert.Equal("test_user1", result.Payload[0].AuthorUsername);
        Assert.Equal("Test Question 1", result.Payload[0].Title);
    }

    [Fact]
    public async Task GetAllAsync_ShouldReturnSuccessWithEmptyList_WhenNoQuestionsExist()
    {
        // Arrange
        _mockRepository.Setup(r => r.GetAllAsync())
            .ReturnsAsync(new List<Question>());

        // Act
        var result = await _service.GetAllAsync();

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Empty(result.Payload!);
    }
}