using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace IslamicApp.Api.Data;

public class IslamicAppContextFactory : IDesignTimeDbContextFactory<IslamicAppContext>
{
    public IslamicAppContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<IslamicAppContext>();
        // Design-time connection string for generating migrations
        optionsBuilder.UseSqlServer("Server=db77070.public.databaseasp.net; Database=db77070; User Id=db77070; Password=********; Encrypt=False; MultipleActiveResultSets=True; TrustServerCertificate=True;");

        return new IslamicAppContext(optionsBuilder.Options);
    }
}

