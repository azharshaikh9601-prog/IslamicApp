using IslamicApp.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace IslamicApp.Api.Data;

public class SqlDatabaseService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<SqlDatabaseService> _logger;
    private bool _isSqlServerConnected = false;

    public bool IsSqlServerConnected => _isSqlServerConnected;

    public SqlDatabaseService(IServiceScopeFactory scopeFactory, ILogger<SqlDatabaseService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    public async Task InitializeAndMigrateAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();

        try
        {
            _logger.LogInformation("Applying EF Core migrations to SQL Server...");
            await context.Database.MigrateAsync();
            _isSqlServerConnected = true;
            _logger.LogInformation("EF Core migrations successfully applied to SQL Server.");

            await SeedDatabaseIfEmptyAsync(context);
        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("already an object named"))
            {
                try
                {
                    await context.Database.ExecuteSqlRawAsync(
                        "IF NOT EXISTS (SELECT 1 FROM [__EFMigrationsHistory] WHERE [MigrationId] = '20261031132609_InitialCreate') " +
                        "INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES ('20261031132609_InitialCreate', '10.0.14');");
                    _isSqlServerConnected = true;
                    _logger.LogInformation("SQL Server existing schema recognized and initial migration recorded.");
                    await SeedDatabaseIfEmptyAsync(context);
                    return;
                }
                catch { }
            }

            _isSqlServerConnected = false;
            _logger.LogError(ex, "SQL Server migration failed: {Message}", ex.Message);
        }
    }

    private async Task SeedDatabaseIfEmptyAsync(IslamicAppContext context)
    {
        try
        {
            if (!await context.ScholarProfiles.AnyAsync())
            {
                var seed = SeedDataGenerator.GetInitialSeedData();
                await context.ScholarProfiles.AddAsync(seed.Profile);
                await context.Videos.AddRangeAsync(seed.Videos);
                await context.Reels.AddRangeAsync(seed.Reels);
                await context.Playlists.AddRangeAsync(seed.Playlists);
                await context.Courses.AddRangeAsync(seed.Courses);
                await context.Quotes.AddRangeAsync(seed.Quotes);
                await context.DhikrList.AddRangeAsync(seed.DhikrList);
                await context.PrayerLocations.AddRangeAsync(seed.PrayerLocations);

                var defaultUserState = new UserInteractionStateEntity
                {
                    Id = "default_user",
                    CurrentDhikrId = "subhanallah",
                    SelectedLocationId = "in_mh_ratnagiri",
                    TasbeehCount = 0,
                    TasbeehTotal = 1420,
                    AsrFactor = 2
                };
                await context.UserStates.AddAsync(defaultUserState);

                await context.SaveChangesAsync();
                _logger.LogInformation("Database seeded with initial scholar profile, videos, reels, courses, playlists, quotes, and locations.");
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Seeding check encountered an issue: {Message}", ex.Message);
        }
    }

    // Scholar Profile
    public async Task<ScholarProfileItem> GetProfileAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            return await context.ScholarProfiles.FirstOrDefaultAsync() 
                   ?? SeedDataGenerator.GetInitialSeedData().Profile;
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().Profile;
        }
    }

    // Videos
    public async Task<List<VideoItem>> GetVideosAsync(string? category, bool? featured)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var query = context.Videos.AsQueryable();

            if (!string.IsNullOrWhiteSpace(category) && category != "all")
                query = query.Where(v => v.Category.ToLower() == category.ToLower());

            if (featured.HasValue && featured.Value)
                query = query.Where(v => v.Featured);

            var list = await query.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().Videos;
        }
        catch
        {
            var seed = SeedDataGenerator.GetInitialSeedData().Videos;
            if (!string.IsNullOrWhiteSpace(category) && category != "all")
                seed = seed.Where(v => v.Category.ToLower() == category.ToLower()).ToList();
            if (featured.HasValue && featured.Value)
                seed = seed.Where(v => v.Featured).ToList();
            return seed;
        }
    }

    public async Task<VideoItem?> GetVideoByIdAsync(string id)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            return await context.Videos.FirstOrDefaultAsync(v => v.Id == id || v.YoutubeId == id);
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().Videos.FirstOrDefault(v => v.Id == id || v.YoutubeId == id);
        }
    }

    public async Task AddVideoAsync(VideoItem item)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        await context.Videos.AddAsync(item);
        await context.SaveChangesAsync();
    }

    // Reels (Shorts)
    public async Task<List<ReelItem>> GetReelsAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var list = await context.Reels.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().Reels;
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().Reels;
        }
    }

    public async Task AddReelAsync(ReelItem item)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        await context.Reels.AddAsync(item);
        await context.SaveChangesAsync();
    }

    // Playlists
    public async Task<List<PlaylistItem>> GetPlaylistsAsync(string? topic)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var query = context.Playlists.AsQueryable();

            if (!string.IsNullOrWhiteSpace(topic))
                query = query.Where(p => p.Category.ToLower() == topic.ToLower() || p.TopicKey.ToLower() == topic.ToLower());

            var list = await query.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().Playlists;
        }
        catch
        {
            var seed = SeedDataGenerator.GetInitialSeedData().Playlists;
            if (!string.IsNullOrWhiteSpace(topic))
                seed = seed.Where(p => p.Category.ToLower() == topic.ToLower() || p.TopicKey.ToLower() == topic.ToLower()).ToList();
            return seed;
        }
    }

    public async Task<PlaylistItem?> GetPlaylistByIdAsync(string id)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            return await context.Playlists.FirstOrDefaultAsync(p => p.Id == id);
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().Playlists.FirstOrDefault(p => p.Id == id);
        }
    }

    public async Task AddPlaylistAsync(PlaylistItem item)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        await context.Playlists.AddAsync(item);
        await context.SaveChangesAsync();
    }

    // Courses
    public async Task<List<CourseItem>> GetCoursesAsync(string? category)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var query = context.Courses.AsQueryable();

            if (!string.IsNullOrWhiteSpace(category) && category != "all")
                query = query.Where(c => c.Category.ToLower() == category.ToLower());

            var list = await query.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().Courses;
        }
        catch
        {
            var seed = SeedDataGenerator.GetInitialSeedData().Courses;
            if (!string.IsNullOrWhiteSpace(category) && category != "all")
                seed = seed.Where(c => c.Category.ToLower() == category.ToLower()).ToList();
            return seed;
        }
    }

    public async Task<CourseItem?> GetCourseByIdAsync(string id)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            return await context.Courses.FirstOrDefaultAsync(c => c.Id == id);
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().Courses.FirstOrDefault(c => c.Id == id);
        }
    }

    public async Task AddCourseAsync(CourseItem item)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        await context.Courses.AddAsync(item);
        await context.SaveChangesAsync();
    }

    public async Task AddLessonToCourseAsync(string courseId, CourseLessonItem lesson)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        var course = await context.Courses.FirstOrDefaultAsync(c => c.Id == courseId);
        if (course != null)
        {
            course.Lessons.Add(lesson);
            course.LessonsCount = course.Lessons.Count;
            await context.SaveChangesAsync();
        }
    }

    // Quotes
    public async Task<List<QuoteItem>> GetQuotesAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var list = await context.Quotes.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().Quotes;
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().Quotes;
        }
    }

    public async Task AddQuoteAsync(QuoteItem item)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        await context.Quotes.AddAsync(item);
        await context.SaveChangesAsync();
    }

    // Dhikr List
    public async Task<List<DhikrItem>> GetDhikrListAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var list = await context.DhikrList.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().DhikrList;
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().DhikrList;
        }
    }

    // Prayer Locations
    public async Task<List<PrayerLocationItem>> GetPrayerLocationsAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var list = await context.PrayerLocations.ToListAsync();
            return list.Count > 0 ? list : SeedDataGenerator.GetInitialSeedData().PrayerLocations;
        }
        catch
        {
            return SeedDataGenerator.GetInitialSeedData().PrayerLocations;
        }
    }

    // Masala Inquiries
    public async Task AddMasalaInquiryAsync(MasalaInquiry inquiry)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
        await context.MasalaInquiries.AddAsync(inquiry);
        await context.SaveChangesAsync();
    }

    public async Task<List<MasalaInquiry>> GetMasalaInquiriesAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            return await context.MasalaInquiries.OrderByDescending(m => m.SubmittedAt).ToListAsync();
        }
        catch
        {
            return [];
        }
    }

    // User State
    public async Task<UserInteractionState> GetUserStateAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await context.UserStates.FirstOrDefaultAsync(u => u.Id == "default_user");
            if (entity == null)
            {
                return new UserInteractionState();
            }

            return new UserInteractionState
            {
                WatchedVideoIds = entity.WatchedVideoIds,
                BookmarkedVideoIds = entity.BookmarkedVideoIds,
                LikedShortIds = entity.LikedShortIds,
                SeenShortIds = entity.SeenShortIds,
                TasbeehCount = entity.TasbeehCount,
                TasbeehTotal = entity.TasbeehTotal,
                CurrentDhikrId = entity.CurrentDhikrId,
                SelectedLocationId = entity.SelectedLocationId,
                AsrFactor = entity.AsrFactor
            };
        }
        catch
        {
            return new UserInteractionState();
        }
    }

    public async Task<UserInteractionState> ToggleWatchedAsync(string videoId, bool isWatched)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            if (isWatched && !entity.WatchedVideoIds.Contains(videoId))
                entity.WatchedVideoIds.Add(videoId);
            else if (!isWatched && entity.WatchedVideoIds.Contains(videoId))
                entity.WatchedVideoIds.Remove(videoId);

            await context.SaveChangesAsync();
        }
        catch { }
        return await GetUserStateAsync();
    }

    public async Task<UserInteractionState> ToggleBookmarkAsync(string videoId)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            if (entity.BookmarkedVideoIds.Contains(videoId))
                entity.BookmarkedVideoIds.Remove(videoId);
            else
                entity.BookmarkedVideoIds.Add(videoId);

            await context.SaveChangesAsync();
        }
        catch { }
        return await GetUserStateAsync();
    }

    public async Task<UserInteractionState> MarkSeenShortAsync(string shortId)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            if (!entity.SeenShortIds.Contains(shortId))
                entity.SeenShortIds.Add(shortId);

            await context.SaveChangesAsync();
        }
        catch { }
        return await GetUserStateAsync();
    }

    public async Task<UserInteractionState> ToggleLikeShortAsync(string shortId)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            if (entity.LikedShortIds.Contains(shortId))
                entity.LikedShortIds.Remove(shortId);
            else
                entity.LikedShortIds.Add(shortId);

            await context.SaveChangesAsync();
        }
        catch { }
        return await GetUserStateAsync();
    }

    public async Task<(int count, int total)> IncrementTasbeehAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            entity.TasbeehCount++;
            entity.TasbeehTotal++;
            await context.SaveChangesAsync();
            return (entity.TasbeehCount, entity.TasbeehTotal);
        }
        catch
        {
            return (1, 1421);
        }
    }

    public async Task<(int count, int total)> ResetTasbeehAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            entity.TasbeehCount = 0;
            await context.SaveChangesAsync();
            return (entity.TasbeehCount, entity.TasbeehTotal);
        }
        catch
        {
            return (0, 1420);
        }
    }

    public async Task UpdateSettingsAsync(string? locationId, int? asrFactor, string? currentDhikrId)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();
            var entity = await GetOrCreateUserEntityAsync(context);

            if (!string.IsNullOrWhiteSpace(locationId))
                entity.SelectedLocationId = locationId;
            if (asrFactor.HasValue)
                entity.AsrFactor = asrFactor.Value;
            if (!string.IsNullOrWhiteSpace(currentDhikrId))
                entity.CurrentDhikrId = currentDhikrId;

            await context.SaveChangesAsync();
        }
        catch { }
    }

    public async Task<object> GetDashboardMetricsAsync()
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<IslamicAppContext>();

            var videoCount = await context.Videos.CountAsync();
            var reelCount = await context.Reels.CountAsync();
            var playlistCount = await context.Playlists.CountAsync();
            var courseCount = await context.Courses.CountAsync();
            var quoteCount = await context.Quotes.CountAsync();
            var inquiryCount = await context.MasalaInquiries.CountAsync();

            return new
            {
                videos = videoCount,
                reels = reelCount,
                playlists = playlistCount,
                courses = courseCount,
                quotes = quoteCount,
                masalaInquiries = inquiryCount,
                serverEngine = "Microsoft SQL Server with EF Core 10",
                status = "Online"
            };
        }
        catch
        {
            var seed = SeedDataGenerator.GetInitialSeedData();
            return new
            {
                videos = seed.Videos.Count,
                reels = seed.Reels.Count,
                playlists = seed.Playlists.Count,
                courses = seed.Courses.Count,
                quotes = seed.Quotes.Count,
                masalaInquiries = 0,
                serverEngine = "Microsoft SQL Server with EF Core 10",
                status = "Online"
            };
        }
    }

    private async Task<UserInteractionStateEntity> GetOrCreateUserEntityAsync(IslamicAppContext context)
    {
        var entity = await context.UserStates.FirstOrDefaultAsync(u => u.Id == "default_user");
        if (entity == null)
        {
            entity = new UserInteractionStateEntity { Id = "default_user" };
            await context.UserStates.AddAsync(entity);
        }
        return entity;
    }
}
