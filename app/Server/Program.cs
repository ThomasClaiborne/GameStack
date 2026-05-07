using Microsoft.EntityFrameworkCore;
using Server.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();

var connectionString = builder.Configuration
    .GetConnectionString("GameStack");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString,
        ServerVersion.AutoDetect(connectionString)));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();