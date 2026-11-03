using IslamicApp.Api.Data;
using IslamicApp.Api.Models;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Register EF Core DbContext with SQL Server
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=db77070.public.databaseasp.net; Database=db77070; User Id=db77070; Password=********; Encrypt=False; MultipleActiveResultSets=True; TrustServerCertificate=True;";

builder.Services.AddDbContext<IslamicAppContext>(options =>
{
    options.UseSqlServer(connectionString);
});

// Add repository / database service
builder.Services.AddSingleton<SqlDatabaseService>();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseCors();

// Run SQL Server database schema initialization & migration on startup
using (var scope = app.Services.CreateScope())
{
    var sqlService = scope.ServiceProvider.GetRequiredService<SqlDatabaseService>();
    try
    {
        await sqlService.InitializeAndMigrateAsync();
    }
    catch (Exception ex)
    {
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Failed to initialize SQL Server database.");
    }
}

// ---------------------------------------------------------------------------
// Health check
// ---------------------------------------------------------------------------
app.MapGet("/api/health", (SqlDatabaseService db) => Results.Ok(new 
{ 
    status = "healthy", 
    framework = ".NET 10", 
    orm = "Entity Framework Core 10",
    sqlServerConnected = db.IsSqlServerConnected,
    database = db.IsSqlServerConnected ? "SQL Server (db77070.public.databaseasp.net)" : "SQL Server (Waiting for credentials / remote toggle)",
    timestamp = DateTime.UtcNow 
}));

// ---------------------------------------------------------------------------
// In-App Video & Shorts Player Embed
// ---------------------------------------------------------------------------
app.MapGet("/api/player", (HttpContext httpContext, string? v, bool? isShort) =>
{
    var videoId = v ?? "";
    var isShortVideo = isShort == true;
    var loopParam = isShortVideo ? $"&loop=1&playlist={videoId}&controls=0" : "&controls=1";

    httpContext.Response.Headers.Append("Referrer-Policy", "unsafe-url");
    httpContext.Response.Headers.Append("Access-Control-Allow-Origin", "*");

    var html = $@"<!DOCTYPE html>
<html>
<head>
  <meta charset=""utf-8"">
  <meta name=""viewport"" content=""width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"">
  <meta name=""referrer"" content=""unsafe-url"">
  <style>
    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
    html, body {{
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
    }}
    iframe {{
      width: 100%;
      height: 100%;
      border: 0;
    }}
  </style>
</head>
<body>
  <iframe
    src=""https://www.youtube-nocookie.com/embed/{videoId}?autoplay=1&rel=0&playsinline=1&modestbranding=1{loopParam}""
    referrerpolicy=""unsafe-url""
    allow=""accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share""
    allowfullscreen>
  </iframe>
</body>
</html>";
    return Results.Content(html, "text/html");
});

// ---------------------------------------------------------------------------
// Scholar Profile
// ---------------------------------------------------------------------------
app.MapGet("/api/profile", async (SqlDatabaseService db) => Results.Ok(await db.GetProfileAsync()));

// ---------------------------------------------------------------------------
// Videos API
// ---------------------------------------------------------------------------
app.MapGet("/api/videos", async (SqlDatabaseService db, string? category, bool? featured) => 
    Results.Ok(await db.GetVideosAsync(category, featured)));

app.MapGet("/api/videos/{id}", async (SqlDatabaseService db, string id) =>
{
    var video = await db.GetVideoByIdAsync(id);
    return video is not null ? Results.Ok(video) : Results.NotFound();
});

app.MapPost("/api/videos", async (SqlDatabaseService db, VideoItem item) =>
{
    if (string.IsNullOrWhiteSpace(item.Id))
        item.Id = $"vid-{item.YoutubeId}";
    await db.AddVideoAsync(item);
    return Results.Created($"/api/videos/{item.Id}", item);
});

// ---------------------------------------------------------------------------
// Reels / Shorts API
// ---------------------------------------------------------------------------
app.MapGet("/api/reels", async (SqlDatabaseService db) => Results.Ok(await db.GetReelsAsync()));

app.MapPost("/api/reels", async (SqlDatabaseService db, ReelItem item) =>
{
    if (string.IsNullOrWhiteSpace(item.Id))
        item.Id = $"short-{item.YoutubeId}";
    await db.AddReelAsync(item);
    return Results.Created($"/api/reels/{item.Id}", item);
});

// ---------------------------------------------------------------------------
// Playlists API
// ---------------------------------------------------------------------------
app.MapGet("/api/playlists", async (SqlDatabaseService db, string? topic) => 
    Results.Ok(await db.GetPlaylistsAsync(topic)));

app.MapGet("/api/playlists/{id}", async (SqlDatabaseService db, string id) =>
{
    var playlist = await db.GetPlaylistByIdAsync(id);
    return playlist is not null ? Results.Ok(playlist) : Results.NotFound();
});

app.MapPost("/api/playlists", async (SqlDatabaseService db, PlaylistItem item) =>
{
    if (string.IsNullOrWhiteSpace(item.Id))
        item.Id = $"pl-{Guid.NewGuid().ToString()[..8]}";
    await db.AddPlaylistAsync(item);
    return Results.Created($"/api/playlists/{item.Id}", item);
});

// ---------------------------------------------------------------------------
// Courses API
// ---------------------------------------------------------------------------
app.MapGet("/api/courses", async (SqlDatabaseService db, string? category) => 
    Results.Ok(await db.GetCoursesAsync(category)));

app.MapGet("/api/courses/{id}", async (SqlDatabaseService db, string id) =>
{
    var course = await db.GetCourseByIdAsync(id);
    return course is not null ? Results.Ok(course) : Results.NotFound();
});

app.MapPost("/api/courses", async (SqlDatabaseService db, CourseItem item) =>
{
    if (string.IsNullOrWhiteSpace(item.Id))
        item.Id = $"course-{Guid.NewGuid().ToString()[..8]}";
    await db.AddCourseAsync(item);
    return Results.Created($"/api/courses/{item.Id}", item);
});

app.MapPost("/api/courses/{id}/lessons", async (SqlDatabaseService db, string id, CourseLessonItem lesson) =>
{
    if (string.IsNullOrWhiteSpace(lesson.Id))
        lesson.Id = $"les-{Guid.NewGuid().ToString()[..8]}";
    await db.AddLessonToCourseAsync(id, lesson);
    var course = await db.GetCourseByIdAsync(id);
    return course is not null ? Results.Ok(course) : Results.NotFound();
});

app.MapPut("/api/courses/{id}/price", async (SqlDatabaseService db, string id, UpdateCoursePriceRequest req) =>
{
    var updated = await db.UpdateCoursePriceAsync(id, req);
    return updated is not null ? Results.Ok(updated) : Results.NotFound();
});

app.MapPost("/api/courses/{id}/enroll", async (SqlDatabaseService db, string id, EnrollCourseRequest req) =>
{
    var res = await db.EnrollCourseAsync(req.UserId, id);
    return res.Success ? Results.Ok(res) : Results.BadRequest(res);
});

// ---------------------------------------------------------------------------
// Authentication & User Accounts API
// ---------------------------------------------------------------------------
app.MapPost("/api/auth/register", async (SqlDatabaseService db, RegisterRequest req) =>
{
    var res = await db.RegisterUserAsync(req);
    return res.Success ? Results.Ok(res) : Results.BadRequest(res);
});

app.MapPost("/api/auth/login", async (SqlDatabaseService db, LoginRequest req) =>
{
    var res = await db.LoginUserAsync(req);
    return res.Success ? Results.Ok(res) : Results.BadRequest(res);
});

app.MapGet("/api/admin/users", async (SqlDatabaseService db) => Results.Ok(await db.GetAllUsersAsync()));

// ---------------------------------------------------------------------------
// Quotes API
// ---------------------------------------------------------------------------
app.MapGet("/api/quotes", async (SqlDatabaseService db) => Results.Ok(await db.GetQuotesAsync()));

app.MapPost("/api/quotes", async (SqlDatabaseService db, QuoteItem item) =>
{
    if (string.IsNullOrWhiteSpace(item.Id))
        item.Id = $"quote-{Guid.NewGuid().ToString()[..8]}";
    await db.AddQuoteAsync(item);
    return Results.Created($"/api/quotes/{item.Id}", item);
});

// ---------------------------------------------------------------------------
// Dhikr List API
// ---------------------------------------------------------------------------
app.MapGet("/api/dhikr", async (SqlDatabaseService db) => Results.Ok(await db.GetDhikrListAsync()));

// ---------------------------------------------------------------------------
// Prayer Locations API
// ---------------------------------------------------------------------------
app.MapGet("/api/prayer-locations", async (SqlDatabaseService db) => Results.Ok(await db.GetPrayerLocationsAsync()));

// ---------------------------------------------------------------------------
// Ask Mas'ala Form Submission API
// ---------------------------------------------------------------------------
app.MapPost("/api/masala", async (SqlDatabaseService db, MasalaInquiry inquiry) =>
{
    await db.AddMasalaInquiryAsync(inquiry);
    return Results.Ok(new { success = true, inquiryId = inquiry.Id });
});

app.MapGet("/api/masala", async (SqlDatabaseService db) => Results.Ok(await db.GetMasalaInquiriesAsync()));

// ---------------------------------------------------------------------------
// User State & Sync API
// ---------------------------------------------------------------------------
app.MapGet("/api/user/state", async (SqlDatabaseService db) => Results.Ok(await db.GetUserStateAsync()));

app.MapPost("/api/user/watched/{videoId}", async (SqlDatabaseService db, string videoId) => 
    Results.Ok(await db.ToggleWatchedAsync(videoId, true)));

app.MapDelete("/api/user/watched/{videoId}", async (SqlDatabaseService db, string videoId) => 
    Results.Ok(await db.ToggleWatchedAsync(videoId, false)));

app.MapPost("/api/user/bookmarks/{videoId}", async (SqlDatabaseService db, string videoId) => 
    Results.Ok(await db.ToggleBookmarkAsync(videoId)));

app.MapPost("/api/user/seen-shorts/{shortId}", async (SqlDatabaseService db, string shortId) => 
    Results.Ok(await db.MarkSeenShortAsync(shortId)));

app.MapPost("/api/user/likes/shorts/{shortId}", async (SqlDatabaseService db, string shortId) => 
    Results.Ok(await db.ToggleLikeShortAsync(shortId)));

app.MapPost("/api/user/tasbeeh/increment", async (SqlDatabaseService db) =>
{
    var (count, total) = await db.IncrementTasbeehAsync();
    return Results.Ok(new { count, total });
});

app.MapPost("/api/user/tasbeeh/reset", async (SqlDatabaseService db) =>
{
    var (count, total) = await db.ResetTasbeehAsync();
    return Results.Ok(new { count, total });
});

app.MapPost("/api/user/settings", async (SqlDatabaseService db, UserSettingsRequest req) =>
{
    await db.UpdateSettingsAsync(req.SelectedLocationId, req.AsrFactor, req.CurrentDhikrId);
    return Results.Ok(await db.GetUserStateAsync());
});

// ---------------------------------------------------------------------------
// Admin Dashboard KPI
// ---------------------------------------------------------------------------
app.MapGet("/api/admin/dashboard", async (SqlDatabaseService db) => 
    Results.Ok(await db.GetDashboardMetricsAsync()));

app.Run("http://0.0.0.0:5000");

public record UserSettingsRequest(string? SelectedLocationId, int? AsrFactor, string? CurrentDhikrId);
