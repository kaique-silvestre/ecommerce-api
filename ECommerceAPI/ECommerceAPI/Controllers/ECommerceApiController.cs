using ECommerceAPI.Data;
using ECommerceAPI.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ECommerceApiController : ControllerBase
    {
        private readonly ECommerceApiDbContext _context;

        public ECommerceApiController(ECommerceApiDbContext context)
        {
                _context = context;
        }
        
        [HttpGet]
        public ActionResult Get()
        {
            var products = _context.Products.ToList();
            return Ok(products);
        }

        [HttpPost]
        public ActionResult<Product> Post(Product product)
        {
            _context.Products.Add(product);
            _context.SaveChanges();
            return Ok(product);
        }


    }
}
