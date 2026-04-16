using ECommerceAPI.Data;
using ECommerceAPI.DTOs;
using ECommerceAPI.Models;
using ECommerceAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ECommerceAPI.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly ECommerceApiDbContext _db;
        private readonly TokenService _tokenService;

        public AuthController(ECommerceApiDbContext db, TokenService tokenService)
        {
            _db = db;
            _tokenService = tokenService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            var email = dto.Email.Trim().ToLowerInvariant();

            if (await _db.Users.AnyAsync(u => u.Email == email))
                return Conflict(new { message = "Email já cadastrado." });

            var user = new User
            {
                Name = dto.Name.Trim(),
                Email = email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = "Customer"
            };

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            var (token, expiresAt) = _tokenService.GenerateToken(user);

            return Ok(new AuthResponseDto
            {
                AccessToken = token,
                ExpiresAt = expiresAt,
                Role = user.Role,
                Name = user.Name
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var email = dto.Email.Trim().ToLowerInvariant();

            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email);

            if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized(new { message = "Credenciais inválidas." });

            var (token, expiresAt) = _tokenService.GenerateToken(user);

            return Ok(new AuthResponseDto
            {
                AccessToken = token,
                ExpiresAt = expiresAt,
                Role = user.Role,
                Name = user.Name
            });
        }
    }
}
