using ECommerceAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerceAPI.Data
{
    public class ECommerceApiDbContext : DbContext
    {
        public ECommerceApiDbContext(DbContextOptions<ECommerceApiDbContext> options) : base(options) { }

        public DbSet<Product> Products { get; set; }
    }
}
