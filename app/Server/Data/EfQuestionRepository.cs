namespace Server.Data;

using Microsoft.EntityFrameworkCore;
using Server.Models;


public class EfQuestionRepository : IQuestionRepository
{
    private readonly AppDbContext _db;

    public EfQuestionRepository(AppDbContext context)
    {
        _db = context;
    }

    public async Task<List<Question>> GetAllAsync()
    {
        return await _db.Questions
        .Include(q => q.Author)
        .OrderByDescending(q => q.CreatedAt)
        .ToListAsync();
    }
}