using ECommerceAPI.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Configuração do Banco
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ECommerceApiDbContext>(options =>
    options.UseSqlServer(connectionString));

// ADICIONE ISTO AQUI: Configuração de CORS para permitir que o front-end acesse a API
builder.Services.AddCors(options =>
{
    options.AddPolicy("PermitirTudo", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

// ADICIONE ISTO AQUI: Ativa o CORS no pipeline
app.UseCors("PermitirTudo");

app.UseAuthorization();
app.MapControllers();
app.Run();