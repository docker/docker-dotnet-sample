using Microsoft.EntityFrameworkCore;
using myWebApp.Models;
using myWebApp.Data;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();

builder.Services.AddDbContext<SchoolContext>(options =>
   options.UseNpgsql(builder.Configuration.GetConnectionString("SchoolContext")));

var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
   var services = scope.ServiceProvider;
   try
   {
       var context = services.GetRequiredService<SchoolContext>();
       var created = context.Database.EnsureCreated();

   }
   catch (Exception ex)
   {
       var logger = services.GetRequiredService<ILogger<Program>>();
       logger.LogError(ex, "An error occurred creating the DB.");
   }
}


// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();