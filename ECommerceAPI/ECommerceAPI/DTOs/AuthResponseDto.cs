namespace ECommerceAPI.DTOs
{
    public class AuthResponseDto
    {
        public string AccessToken { get; set; } = "";
        public DateTime ExpiresAt { get; set; }
        public string Role { get; set; } = "";
        public string Name { get; set; } = "";
    }
}
