using System.Text.Json;
using IslamicApp.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace IslamicApp.Api.Data;

public class IslamicAppContext : DbContext
{
    public IslamicAppContext(DbContextOptions<IslamicAppContext> options) : base(options)
    {
    }

    public DbSet<ScholarProfileItem> ScholarProfiles { get; set; } = null!;
    public DbSet<VideoItem> Videos { get; set; } = null!;
    public DbSet<ReelItem> Reels { get; set; } = null!;
    public DbSet<PlaylistItem> Playlists { get; set; } = null!;
    public DbSet<CourseItem> Courses { get; set; } = null!;
    public DbSet<QuoteItem> Quotes { get; set; } = null!;
    public DbSet<DhikrItem> DhikrList { get; set; } = null!;
    public DbSet<PrayerLocationItem> PrayerLocations { get; set; } = null!;
    public DbSet<UserInteractionStateEntity> UserStates { get; set; } = null!;
    public DbSet<MasalaInquiry> MasalaInquiries { get; set; } = null!;
    public DbSet<UserAccountEntity> Users { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Value comparer for List<string>
        var stringListComparer = new ValueComparer<List<string>>(
            (c1, c2) => c1 != null && c2 != null ? c1.SequenceEqual(c2) : c1 == c2,
            c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
            c => c.ToList());

        var videoListComparer = new ValueComparer<List<VideoItem>>(
            (c1, c2) => JsonSerializer.Serialize(c1, (JsonSerializerOptions?)null) == JsonSerializer.Serialize(c2, (JsonSerializerOptions?)null),
            c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
            c => JsonSerializer.Deserialize<List<VideoItem>>(JsonSerializer.Serialize(c, (JsonSerializerOptions?)null), (JsonSerializerOptions?)null)!);

        var lessonListComparer = new ValueComparer<List<CourseLessonItem>>(
            (c1, c2) => JsonSerializer.Serialize(c1, (JsonSerializerOptions?)null) == JsonSerializer.Serialize(c2, (JsonSerializerOptions?)null),
            c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
            c => JsonSerializer.Deserialize<List<CourseLessonItem>>(JsonSerializer.Serialize(c, (JsonSerializerOptions?)null), (JsonSerializerOptions?)null)!);

        // ScholarProfile
        modelBuilder.Entity<ScholarProfileItem>(entity =>
        {
            entity.HasKey(e => e.Name);
            entity.Property(e => e.Name).HasMaxLength(150);
            entity.Property(e => e.Title).HasMaxLength(200);
            entity.Property(e => e.Handle).HasMaxLength(100);
            entity.Property(e => e.Domain).HasMaxLength(150);
        });

        // Videos
        modelBuilder.Entity<VideoItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.YoutubeId).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Title).HasMaxLength(500).IsRequired();
            entity.Property(e => e.Category).HasMaxLength(100);
            entity.Property(e => e.Format).HasMaxLength(50);
            entity.Property(e => e.Duration).HasMaxLength(50);
            entity.Property(e => e.Views).HasMaxLength(50);
            entity.Property(e => e.Date).HasMaxLength(50);
        });

        // Reels (Shorts)
        modelBuilder.Entity<ReelItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.YoutubeId).HasMaxLength(50).IsRequired();
            entity.Property(e => e.Title).HasMaxLength(500).IsRequired();
            entity.Property(e => e.Views).HasMaxLength(50);
            entity.Property(e => e.Likes).HasMaxLength(50);
            entity.Property(e => e.Shares).HasMaxLength(50);
            entity.Property(e => e.Category).HasMaxLength(100);
            entity.Property(e => e.Format).HasMaxLength(50);
            entity.Property(e => e.Duration).HasMaxLength(50);
        });

        // Playlists
        modelBuilder.Entity<PlaylistItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Title).HasMaxLength(300).IsRequired();
            entity.Property(e => e.UrduTitle).HasMaxLength(300);
            entity.Property(e => e.Category).HasMaxLength(100);
            entity.Property(e => e.TopicKey).HasMaxLength(100);
            entity.Property(e => e.Thumbnail).HasMaxLength(500);

            entity.Property(e => e.Videos)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<VideoItem>>(v, (JsonSerializerOptions?)null) ?? new List<VideoItem>())
                .Metadata.SetValueComparer(videoListComparer);
        });

        // Courses
        modelBuilder.Entity<CourseItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Title).HasMaxLength(300).IsRequired();
            entity.Property(e => e.UrduTitle).HasMaxLength(300);
            entity.Property(e => e.Category).HasMaxLength(100);
            entity.Property(e => e.Duration).HasMaxLength(50);
            entity.Property(e => e.Badge).HasMaxLength(100);
            entity.Property(e => e.Instructor).HasMaxLength(150);
            entity.Property(e => e.Thumbnail).HasMaxLength(500);

            entity.Property(e => e.Highlights)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => string.IsNullOrEmpty(v) ? new List<string>() : JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>())
                .Metadata.SetValueComparer(stringListComparer);

            entity.Property(e => e.Lessons)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => string.IsNullOrEmpty(v) ? new List<CourseLessonItem>() : JsonSerializer.Deserialize<List<CourseLessonItem>>(v, (JsonSerializerOptions?)null) ?? new List<CourseLessonItem>())
                .Metadata.SetValueComparer(lessonListComparer);
        });

        // Quotes
        modelBuilder.Entity<QuoteItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Category).HasMaxLength(100);
            entity.Property(e => e.Arabic).HasMaxLength(1000);
            entity.Property(e => e.Urdu).HasMaxLength(1000);
            entity.Property(e => e.English).HasMaxLength(1000);
            entity.Property(e => e.Reference).HasMaxLength(200);
            entity.Property(e => e.Theme).HasMaxLength(100);
        });

        // Dhikr
        modelBuilder.Entity<DhikrItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Name).HasMaxLength(150);
            entity.Property(e => e.Arabic).HasMaxLength(300);
            entity.Property(e => e.Meaning).HasMaxLength(500);
        });

        // Prayer Locations
        modelBuilder.Entity<PrayerLocationItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Name).HasMaxLength(150);
            entity.Property(e => e.Group).HasMaxLength(100);
        });

        // User State
        modelBuilder.Entity<UserInteractionStateEntity>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(50);
            entity.Property(e => e.CurrentDhikrId).HasMaxLength(100);
            entity.Property(e => e.SelectedLocationId).HasMaxLength(100);

            entity.Property(e => e.WatchedVideoIds)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>())
                .Metadata.SetValueComparer(stringListComparer);

            entity.Property(e => e.BookmarkedVideoIds)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>())
                .Metadata.SetValueComparer(stringListComparer);

            entity.Property(e => e.LikedShortIds)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>())
                .Metadata.SetValueComparer(stringListComparer);

            entity.Property(e => e.SeenShortIds)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>())
                .Metadata.SetValueComparer(stringListComparer);
        });

        // Masala Inquiries
        modelBuilder.Entity<MasalaInquiry>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Name).HasMaxLength(150);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.Question).HasMaxLength(2000);
        });

        // User Accounts
        modelBuilder.Entity<UserAccountEntity>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasMaxLength(100);
            entity.Property(e => e.Username).HasMaxLength(150).IsRequired();
            entity.Property(e => e.Email).HasMaxLength(200).IsRequired();
            entity.Property(e => e.PasswordHash).HasMaxLength(500).IsRequired();

            entity.Property(e => e.EnrolledCourseIds)
                .HasConversion(
                    v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                    v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>())
                .Metadata.SetValueComparer(stringListComparer);
        });
    }
}

public class UserInteractionStateEntity
{
    public string Id { get; set; } = "default_user";
    public List<string> WatchedVideoIds { get; set; } = [];
    public List<string> BookmarkedVideoIds { get; set; } = [];
    public List<string> LikedShortIds { get; set; } = [];
    public List<string> SeenShortIds { get; set; } = [];
    public int TasbeehCount { get; set; }
    public int TasbeehTotal { get; set; } = 1420;
    public string CurrentDhikrId { get; set; } = "subhanallah";
    public string SelectedLocationId { get; set; } = "in_mh_ratnagiri";
    public int AsrFactor { get; set; } = 2;
}

