namespace Server.Tests.Data;

using Microsoft.EntityFrameworkCore;
using Server.Data;
using Server.Models;

public class EfQuestionRepositoryTest : IAsyncLifetime
{
        private readonly AppDbContext _db;
        private readonly IQuestionRepository _repository;
    public EfQuestionRepositoryTest()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseMySql("server=localhost;port=3306;database=gamestack_test;user=root;password=top-secret-password",
                ServerVersion.AutoDetect("server=localhost;port=3306;database=gamestack_test;user=root;password=top-secret-password"))
            .UseSnakeCaseNamingConvention()
            .Options;

        _db = new AppDbContext(options);
        _repository = new EfQuestionRepository(_db);
    }

    public async Task InitializeAsync()
    {
        await _db.Database.ExecuteSqlRawAsync("CALL set_known_good_state();");
    }

    public Task DisposeAsync() => Task.CompletedTask;

    [Fact]
    public async Task GetAllAsync_ShouldReturnAllQuestions()
    {
        var result = await _repository.GetAllAsync();
        Assert.Equal(3, result.Count);
    }

    [Fact]
    public async Task GetALlAsync_ShouldIncludeAuthor()
    {
        var result = await _repository.GetAllAsync();
        Assert.All(result, q => Assert.NotNull(q.Author));
    }

    [Fact]
    public async Task GetAllAsync_ReturnResultsNewestFirst()
    {
        var result = await _repository.GetAllAsync();
        Assert.True(result[0].CreatedAt > result[1].CreatedAt);
        Assert.True(result[1].CreatedAt > result[2].CreatedAt);
    }
}   