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
app.UseStaticFiles();

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
// Real Live YouTube Feed for Hafiz Hasnain Jaani (@HAFIZHASNAINJAANI)
// ---------------------------------------------------------------------------
app.MapGet("/api/youtube/live-feed", async (SqlDatabaseService db) =>
{
    const string channelId = "UC1NRrbs7Ys4yVNsQx83NhsA";
    var feedUrl = $"https://www.youtube.com/feeds/videos.xml?channel_id={channelId}";
    
    using var http = new HttpClient();
    http.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)");
    
    try
    {
        var xml = await http.GetStringAsync(feedUrl);
        var doc = System.Xml.Linq.XDocument.Parse(xml);
        System.Xml.Linq.XNamespace atom = "http://www.w3.org/2005/Atom";
        System.Xml.Linq.XNamespace yt = "http://www.youtube.com/xml/schemas/2015";
        System.Xml.Linq.XNamespace media = "http://search.yahoo.com/mrss/";

        var entries = doc.Root?.Elements(atom + "entry") ?? Enumerable.Empty<System.Xml.Linq.XElement>();
        var resultVideos = new List<VideoItem>();

        foreach (var entry in entries)
        {
            var videoId = entry.Element(yt + "videoId")?.Value;
            var title = entry.Element(atom + "title")?.Value;
            var publishedStr = entry.Element(atom + "published")?.Value;
            var mediaGroup = entry.Element(media + "group");
            
            var viewsCount = "0";
            var likesCount = "0";
            var description = "";
            var thumbUrl = $"https://img.youtube.com/vi/{videoId}/hqdefault.jpg";

            if (mediaGroup != null)
            {
                var community = mediaGroup.Element(media + "community");
                if (community != null)
                {
                    viewsCount = community.Element(media + "statistics")?.Attribute("views")?.Value ?? "0";
                    likesCount = community.Element(media + "starRating")?.Attribute("count")?.Value ?? "0";
                }
                var mediaThumb = mediaGroup.Element(media + "thumbnail")?.Attribute("url")?.Value;
                if (!string.IsNullOrEmpty(mediaThumb)) thumbUrl = mediaThumb;
                description = mediaGroup.Element(media + "description")?.Value ?? "";
            }

            if (!string.IsNullOrEmpty(videoId) && !string.IsNullOrEmpty(title))
            {
                // Format views
                var formattedViews = viewsCount;
                if (long.TryParse(viewsCount, out var vCount))
                {
                    formattedViews = vCount >= 1000000 ? $"{(vCount / 1000000.0):0.#}M views" :
                                     vCount >= 1000 ? $"{(vCount / 1000.0):0.#}K views" : $"{vCount} views";
                }

                var item = new VideoItem
                {
                    Id = $"vid-{videoId}",
                    YoutubeId = videoId,
                    Title = title,
                    Duration = "Lesson",
                    Views = formattedViews,
                    Date = publishedStr ?? "",
                    Category = title.Contains("Surah", StringComparison.OrdinalIgnoreCase) || title.Contains("Quran", StringComparison.OrdinalIgnoreCase) ? "qaida" :
                               title.Contains("Wuzu", StringComparison.OrdinalIgnoreCase) || title.Contains("Wudu", StringComparison.OrdinalIgnoreCase) ? "wudu" : "namaz",
                    Featured = true,
                    Description = description
                };

                resultVideos.Add(item);
                // Also add/sync to database asynchronously
                _ = db.AddVideoAsync(item);
            }
        }

        return Results.Ok(new
        {
            channelId,
            handle = "@HAFIZHASNAINJAANI",
            subscribers = "413K Subscribers",
            totalVideos = resultVideos.Count,
            videos = resultVideos
        });
    }
    catch (Exception ex)
    {
        return Results.Problem($"Failed to fetch YouTube feed: {ex.Message}");
    }
});

// ---------------------------------------------------------------------------
// In-App Video & Shorts Player Embed
// ---------------------------------------------------------------------------
app.MapGet("/api/player", (HttpContext httpContext, string? v, bool? isShort) =>
{
    var videoId = v ?? "";
    var isShortVideo = isShort == true;
    var isDirectVideo = videoId.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                        videoId.StartsWith("https://", StringComparison.OrdinalIgnoreCase) ||
                        videoId.StartsWith("/uploads/", StringComparison.OrdinalIgnoreCase) ||
                        videoId.EndsWith(".mp4", StringComparison.OrdinalIgnoreCase) ||
                        videoId.EndsWith(".webm", StringComparison.OrdinalIgnoreCase) ||
                        videoId.EndsWith(".mov", StringComparison.OrdinalIgnoreCase);

    httpContext.Response.Headers.Append("Referrer-Policy", "unsafe-url");
    httpContext.Response.Headers.Append("Access-Control-Allow-Origin", "*");

    if (isDirectVideo)
    {
        var fullUrl = videoId.StartsWith("/uploads/") ? $"http://localhost:5000{videoId}" : videoId;
        var directHtml = $@"<!DOCTYPE html>
<html>
<head>
  <meta charset=""utf-8"">
  <meta name=""viewport"" content=""width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"">
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
    video {{
      width: 100%;
      height: 100%;
      max-height: 100vh;
      object-fit: contain;
      outline: none;
    }}
  </style>
</head>
<body>
  <video src=""{fullUrl}"" controls autoplay controlsList=""nodownload"" oncontextmenu=""return false;""></video>
</body>
</html>";
        return Results.Content(directHtml, "text/html");
    }

    var loopParam = isShortVideo ? $"&loop=1&playlist={videoId}&controls=0" : "&controls=1";

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

// Upload In-App Course Video (Private, self-hosted, NOT on YouTube)
app.MapPost("/api/courses/upload-video", async (HttpRequest request) =>
{
    if (!request.HasFormContentType || request.Form.Files.Count == 0)
    {
        return Results.BadRequest(new { success = false, message = "No video file provided." });
    }

    var file = request.Form.Files[0];
    if (file.Length == 0)
    {
        return Results.BadRequest(new { success = false, message = "Empty video file." });
    }

    var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "course_videos");
    if (!Directory.Exists(uploadsFolder))
    {
        Directory.CreateDirectory(uploadsFolder);
    }

    var ext = Path.GetExtension(file.FileName);
    if (string.IsNullOrEmpty(ext)) ext = ".mp4";
    var safeName = $"{Guid.NewGuid():N}{ext}";
    var filePath = Path.Combine(uploadsFolder, safeName);

    using (var stream = new FileStream(filePath, FileMode.Create))
    {
        await file.CopyToAsync(stream);
    }

    var relativeUrl = $"/uploads/course_videos/{safeName}";
    return Results.Ok(new 
    { 
        success = true, 
        videoUrl = relativeUrl, 
        fileName = file.FileName,
        message = "In-App Private Course Video uploaded successfully!" 
    });
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

app.MapPut("/api/courses/{id}", async (SqlDatabaseService db, string id, UpdateCourseRequest req) =>
{
    var updated = await db.UpdateCourseAsync(id, req);
    return updated is not null ? Results.Ok(updated) : Results.NotFound();
});

app.MapDelete("/api/courses/{id}", async (SqlDatabaseService db, string id) =>
{
    var deleted = await db.DeleteCourseAsync(id);
    return deleted ? Results.NoContent() : Results.NotFound();
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
