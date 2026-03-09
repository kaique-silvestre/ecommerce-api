namespace ECommerceAPI.DTOs
{
    public class ProductCreateDto
    {
        public string? Name { get; set; }
        public decimal Price { get; set; }
        public string? Description { get; set; }
        public int Stock { get; set; }
        public string? ImageUrl { get; set; }
    }
}
