using System.ComponentModel.DataAnnotations;

namespace ECommerceAPI.DTOs
{
    public class RegisterDto
    {
        [Required, MinLength(2)]
        public string Name { get; set; } = "";

        [Required, EmailAddress]
        public string Email { get; set; } = "";

        [Required, MinLength(8)]
        public string Password { get; set; } = "";
    }
}
