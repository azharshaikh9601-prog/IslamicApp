namespace IslamicApp.Api.Models;

public class VideoItem
{
    public string Id { get; set; } = string.Empty;
    public string YoutubeId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Category { get; set; } = "all";
    public string Format { get; set; } = "video";
    public string Duration { get; set; } = string.Empty;
    public string Views { get; set; } = string.Empty;
    public string Date { get; set; } = string.Empty;
    public bool Featured { get; set; }
    public bool IsMasterclass { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class ReelItem
{
    public string Id { get; set; } = string.Empty;
    public string YoutubeId { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Views { get; set; } = string.Empty;
    public string Likes { get; set; } = "0";
    public string Shares { get; set; } = "0";
    public string Category { get; set; } = "namaz";
    public string Format { get; set; } = "short";
    public string Duration { get; set; } = "0:55";
    public string Description { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class PlaylistItem
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string UrduTitle { get; set; } = string.Empty;
    public string Category { get; set; } = "namaz";
    public string TopicKey { get; set; } = string.Empty;
    public string Thumbnail { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public List<VideoItem> Videos { get; set; } = [];
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class CourseLessonItem
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Duration { get; set; } = string.Empty;
    public string YoutubeId { get; set; } = string.Empty;
    public bool IsFreePreview { get; set; }
    public string Summary { get; set; } = string.Empty;
}

public class CourseItem
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string UrduTitle { get; set; } = string.Empty;
    public string Category { get; set; } = "namaz";
    public int Price { get; set; }
    public int OriginalPrice { get; set; }
    public int DiscountPercent { get; set; }
    public string Duration { get; set; } = string.Empty;
    public int LessonsCount { get; set; }
    public string Badge { get; set; } = string.Empty;
    public string Instructor { get; set; } = "Hafiz Hasnain Jaani";
    public double Rating { get; set; } = 4.9;
    public int StudentsEnrolled { get; set; }
    public string Thumbnail { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public List<string> Highlights { get; set; } = [];
    public List<CourseLessonItem> Lessons { get; set; } = [];
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class QuoteItem
{
    public string Id { get; set; } = string.Empty;
    public string Category { get; set; } = "Daily Hadith";
    public string Arabic { get; set; } = string.Empty;
    public string Urdu { get; set; } = string.Empty;
    public string English { get; set; } = string.Empty;
    public string Reference { get; set; } = string.Empty;
    public string Theme { get; set; } = "theme-emerald";
    public int Likes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class DhikrItem
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Arabic { get; set; } = string.Empty;
    public string Meaning { get; set; } = string.Empty;
    public int Target { get; set; } = 33;
}

public class PrayerLocationItem
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public double Lat { get; set; }
    public double Lng { get; set; }
    public double Tz { get; set; }
    public string Group { get; set; } = string.Empty;
}

public class ScholarProfileItem
{
    public string Name { get; set; } = "Hafiz Hasnain Jaani";
    public string Title { get; set; } = "Islamic Scholar & Content Creator";
    public string Handle { get; set; } = "@HAFIZHASNAINJAANI";
    public string YoutubeUrl { get; set; } = "https://youtube.com/@hafizhasnainjaani";
    public string Domain { get; set; } = "hafizhasnainjaani.com";
    public string Subscribers { get; set; } = "411K+";
    public string TotalViews { get; set; } = "35M+";
    public string VideosCount { get; set; } = "776+";
    public string Bio { get; set; } = string.Empty;
    public string Location { get; set; } = "Purnia, Bihar, India";
    public string Whatsapp { get; set; } = "+919876543210";
    public string Email { get; set; } = "contact@hafizhasnainjaani.com";
}

public class UserInteractionState
{
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

public class MasalaInquiry
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string Name { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Question { get; set; } = string.Empty;
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
}

public class AppData
{
    public ScholarProfileItem Profile { get; set; } = new();
    public List<VideoItem> Videos { get; set; } = [];
    public List<ReelItem> Reels { get; set; } = [];
    public List<PlaylistItem> Playlists { get; set; } = [];
    public List<CourseItem> Courses { get; set; } = [];
    public List<QuoteItem> Quotes { get; set; } = [];
    public List<DhikrItem> DhikrList { get; set; } = [];
    public List<PrayerLocationItem> PrayerLocations { get; set; } = [];
    public UserInteractionState UserState { get; set; } = new();
    public List<MasalaInquiry> MasalaInquiries { get; set; } = [];
}


