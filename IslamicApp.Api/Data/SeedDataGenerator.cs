using IslamicApp.Api.Models;

namespace IslamicApp.Api.Data;

public static class SeedDataGenerator
{
    public static AppData GetInitialSeedData()
    {
        var data = new AppData();

        data.Profile = new ScholarProfileItem
        {
            Name = "Hafiz Hasnain Jaani",
            Title = "Islamic Scholar & Content Creator",
            Handle = "@HAFIZHASNAINJAANI",
            YoutubeUrl = "https://youtube.com/@hafizhasnainjaani?si=KRhN69PuvMnkGMIQ",
            Domain = "hafizhasnainjaani.com",
            Subscribers = "411K+",
            TotalViews = "35M+",
            VideosCount = "776+",
            Bio = "Promoting authentic Islamic knowledge based on the Holy Quran, Sunnah, and Fiqh-e-Hanafi. Dedicated to teaching practical Namaz, Wudu, Quranic Tajweed, Masail of daily life, and spreading spiritual peace through Naats and Bayanaat.",
            Location = "Purnia, Bihar, India",
            Whatsapp = "+919876543210",
            Email = "contact@hafizhasnainjaani.com"
        };

        data.Videos =
        [
            new() { Id = "vid-IaJcljFpgBc", YoutubeId = "IaJcljFpgBc", Title = "Fajr Aur Asr Ke Baad Quran Padhna Kaisa? | Ahm Masla फ़ज्र और असर के बादक़ुरआन पढ़ सकते हैं?", Category = "qaida", Format = "video", Duration = "3:51", Views = "961 views", Date = "Recent", Featured = true, IsMasterclass = true, Description = "Official Islamic lecture by Hafiz Hasnain Jaani explaining whether recitation of the Holy Quran is permissible after Fajr and Asr prayers according to Fiqh-e-Hanafi." },
            new() { Id = "vid-Ys4wYLMyyMo", YoutubeId = "Ys4wYLMyyMo", Title = "Namaz Mein Kaunsi Surah Padhein? | 4 Qul Ki Tartib Aur Namaz Ka Tarika", Category = "namaz", Format = "video", Duration = "6:59", Views = "14K views", Date = "Popular", Featured = true, IsMasterclass = true, Description = "Complete guide by Hafiz Hasnain Jaani on the sequence of Surahs to recite during Farz, Sunnat, and Nafl prayers, highlighting the 4 Quls order." },
            new() { Id = "vid-p34oV0PLpmQ", YoutubeId = "p34oV0PLpmQ", Title = "Namaz Mein Sana Bhool Gaye To Sajda Sahw Hoga? Pehli Rakat Mein Surah Naas Padh Li To Kya Karein?", Category = "namaz", Format = "video", Duration = "7:39", Views = "15K views", Date = "Trending", Featured = true, Description = "Clear fatwa and practical rulings regarding forgetting Thana (SubhanakAllahumma) in Salah and unintentional reversal of Surah order." },
            new() { Id = "vid-Y-6v6x3YJgE", YoutubeId = "Y-6v6x3YJgE", Title = "Khatam Sharif Padhne Ka Sahi Sunnat Tarika | Fatiha Ka Mukammal Bayan", Category = "masail", Format = "video", Duration = "11:42", Views = "28K views", Date = "Featured", IsMasterclass = true, Description = "Complete step-by-step guidance on reciting Fatiha and Isal-e-Sawab for deceased Muslims according to authentic Ahle Sunnat traditions." },
            new() { Id = "vid-Q9tG82Xv6oE", YoutubeId = "Q9tG82Xv6oE", Title = "Wudu Ke Faraiz Aur Sunnatein | Ghusl Ke 3 Farz Aur Janabat Ka Masla", Category = "wudu", Format = "video", Duration = "14:20", Views = "54K views", Date = "Essential", IsMasterclass = true, Description = "In-depth practical demonstration of the 4 obligatory acts of Wudu and the 3 obligatory acts of ritual purification (Ghusl)." },
            new() { Id = "vid-gMTvoRUgeXA", YoutubeId = "gMTvoRUgeXA", Title = "Aurat ki Namaz ka tarika practically | औरत के नमाज पढ़ने का सही तरीका", Category = "namaz", Format = "video", Duration = "22:06", Views = "3.8M views", Date = "Masterclass", IsMasterclass = true, Description = "Step-by-step practical demonstration of Namaz for women according to Fiqh-e-Hanafi." },
            new() { Id = "vid-h1RO3NyMdQg", YoutubeId = "h1RO3NyMdQg", Title = "5 Waqt ki Farz Namaz imam ke piche padhne ka tarika | Jamat se Namaz", Category = "namaz", Format = "video", Duration = "1:20:53", Views = "757K views", Date = "Popular", IsMasterclass = true, Description = "Comprehensive guide for praying 5 daily Farz prayers behind the Imam in congregation." },
            new() { Id = "vid-ZQRo2roF4DM", YoutubeId = "ZQRo2roF4DM", Title = "Wudu Ka Sunnat Tariqa | Roza Mein Wudu Kaise Karein? Complete Guide", Category = "wudu", Format = "video", Duration = "10:21", Views = "10K views", Date = "Essential", Description = "Sunnah method of performing Wudu, including rulings for fasting and common doubts." }
        ];

        data.Reels =
        [
            new() { Id = "short-VRBs2E20VUg", YoutubeId = "VRBs2E20VUg", Title = "Imam Attahiyat Padh Kar Foran Khada Ho Jaye To Muqtadi Kya Kare? #namaz #islamicvideo", Views = "8.8K views", Likes = "255", Shares = "63", Category = "namaz", Duration = "0:55", Description = "Quick Islamic ruling by Hafiz Hasnain Jaani on congregational prayer." },
            new() { Id = "short-OjFpWDy6sS0", YoutubeId = "OjFpWDy6sS0", Title = "Namaz me Surah Fatiha Se Pehle Bhool Kar Koi Surah Padh Li To Kya Karein? #namaz", Views = "10K views", Likes = "262", Shares = "65", Category = "namaz", Duration = "0:55", Description = "Essential Namaz rule for rectifying mistakes in recitation." },
            new() { Id = "short-9nEz_ewjJio", YoutubeId = "9nEz_ewjJio", Title = "Shab-e-Barat ki 6 Rakat Nafl Namaz फुल वीडियो #namaz #shabebarat #islamicvideo", Views = "20K views", Likes = "269", Shares = "67", Category = "namaz", Duration = "0:55", Description = "Method and intention for special night voluntary prayers." },
            new() { Id = "short-XJgadChADLM", YoutubeId = "XJgadChADLM", Title = "दुआ ए कुनूत के बदले कौन सी दुआ पढ़े #islamicvideo #namaz", Views = "8.4K views", Likes = "164", Shares = "41", Category = "namaz", Duration = "0:55", Description = "Alternative Duas if you have not memorized Dua-e-Qunoot for Witr." },
            new() { Id = "short-lB7eYzDBVpE", YoutubeId = "lB7eYzDBVpE", Title = "Sajda Tilawat Ka Sahi Tarika | Khade Aur Baith Kar #shorts #islamic #tutorial", Views = "7K views", Likes = "150", Shares = "38", Category = "namaz", Duration = "0:55", Description = "Prostration of recitation method and sunnah etiquettes." }
        ];

        data.Playlists =
        [
            new()
            {
                Id = "pl-aurat-namaz",
                Title = "Aurat Ki Namaz Ka Mukammal Tarika (औरत की नमाज़)",
                UrduTitle = "عورت کی نماز کا مکمل طریقہ اور مسائل",
                Category = "namaz",
                TopicKey = "Aurat Ki Namaz",
                Thumbnail = "https://img.youtube.com/vi/gMTvoRUgeXA/hqdefault.jpg",
                Description = "Fiqh-e-Hanafi ke mutabiq khawateen ki 5 waqt namaz, parda, ruku aur sajde ke tareeqe.",
                Videos =
                [
                    new() { Id = "pl-an-1", YoutubeId = "gMTvoRUgeXA", Title = "Aurat ki Namaz ka tarika practically", Category = "namaz", Duration = "22:06", Views = "3.8M views", Date = "Top Video", Description = "Practical demonstration of women prayer according to Hanafi Fiqh." },
                    new() { Id = "pl-an-2", YoutubeId = "EQLQdn1r5nQ", Title = "Aurat Fajr Ki Namaz Kaise Padhe", Category = "namaz", Duration = "16:26", Views = "327K views", Date = "Recommended", Description = "Fajr prayer method step-by-step for women." },
                    new() { Id = "pl-an-3", YoutubeId = "TYgIemWxQyM", Title = "Zohar ki Namaz ka tarika | Aurat ki namaz", Category = "namaz", Duration = "34:13", Views = "294K views", Date = "Complete", Description = "Zuhr prayer for women." },
                    new() { Id = "pl-an-4", YoutubeId = "PBLSO6znBjk", Title = "Aurat Asar Ki Namaz Kaise Padhe", Category = "namaz", Duration = "22:17", Views = "123K views", Date = "Step by Step", Description = "Asr prayer method for ladies." },
                    new() { Id = "pl-an-5", YoutubeId = "VAXVvfLdaXA", Title = "मगरिब की नमाज़ का मुकम्मल तरीका", Category = "namaz", Duration = "24:52", Views = "36K views", Date = "Maghrib", Description = "Maghrib prayer for women." },
                    new() { Id = "pl-an-6", YoutubeId = "lx176WsaLU4", Title = "ईशा की नमाज़ का मुकम्मل तरीका", Category = "namaz", Duration = "50:37", Views = "53K views", Date = "Isha", Description = "Complete Isha prayer for women." },
                    new() { Id = "pl-an-7", YoutubeId = "8U1v-gW25fs", Title = "Witr ki Namaz ka tarika for ladies", Category = "namaz", Duration = "10:40", Views = "27K views", Date = "Wajib", Description = "3 Rakat Wajib Witr prayer for women." },
                    new() { Id = "pl-an-8", YoutubeId = "wUxsUgyR2eM", Title = "Tahajjud ki Namaz Aurat kaise padhe", Category = "namaz", Duration = "15:18", Views = "2.4M views", Date = "Tahajjud", Description = "Tahajjud night prayer guide for women." },
                    new() { Id = "pl-an-9", YoutubeId = "mjOL7A2jmm4", Title = "Namaz Ka Tarika for Ladies | 5 Waqt Mega Guide", Category = "namaz", Duration = "2:22:22", Views = "29K views", Date = "Full Masterclass", IsMasterclass = true, Description = "All 5 daily prayers in a single mega masterclass video." }
                ]
            },
            new()
            {
                Id = "pl-mardo-namaz",
                Title = "Mardon Ki Namaz Ka Mukammal Tarika (मर्दों की नमाज़)",
                UrduTitle = "مردوں کی نماز کا مکمل طریقہ اور احکام",
                Category = "namaz",
                TopicKey = "Namaz Ka Aasan Tarika",
                Thumbnail = "https://img.youtube.com/vi/h1RO3NyMdQg/hqdefault.jpg",
                Description = "Mardon ke liye Sunnat ke mutabiq namaz ki takbeer, qayaam, ruku aur sajdah ka tariqa.",
                Videos =
                [
                    new() { Id = "pl-mn-1", YoutubeId = "h1RO3NyMdQg", Title = "5 Waqt ki Farz Namaz imam ke piche padhne ka tarika", Category = "namaz", Duration = "1:20:53", Views = "757K views", Date = "Congregation", IsMasterclass = true, Description = "How men should pray all 5 daily prayers behind the Imam." },
                    new() { Id = "pl-mn-2", YoutubeId = "zPeeS6vFspA", Title = "Fajar ki namaz imam ke piche kaise padhe", Category = "namaz", Duration = "12:42", Views = "206K views", Date = "Fajr Jamat", Description = "Fajr congregational prayer rules." },
                    new() { Id = "pl-mn-3", YoutubeId = "oeAVEv4cOp4", Title = "Zohar ki Namaz imam ke piche kaise padhe", Category = "namaz", Duration = "13:10", Views = "156K views", Date = "Zuhr Jamat", Description = "Zuhr prayer behind the Imam." },
                    new() { Id = "pl-mn-4", YoutubeId = "RbEADofMxMY", Title = "Asar ki Namaz imam ke piche kaise padhe", Category = "namaz", Duration = "13:26", Views = "95K views", Date = "Asr Jamat", Description = "Asr congregational prayer rules." },
                    new() { Id = "pl-mn-5", YoutubeId = "datypQCTIpE", Title = "Magrib ki farz Namaz imam ke piche", Category = "namaz", Duration = "16:41", Views = "73K views", Date = "Maghrib Jamat", Description = "Maghrib prayer behind Imam." },
                    new() { Id = "pl-mn-6", YoutubeId = "0E29U6IlwxQ", Title = "Isha ki Farz Namaz ka tarika imam ke piche", Category = "namaz", Duration = "17:57", Views = "52K views", Date = "Isha Jamat", Description = "Isha prayer in congregation." },
                    new() { Id = "pl-mn-7", YoutubeId = "QU7mjlS3_VY", Title = "Namaz ki rakat nikal jaye to kaise padhe", Category = "namaz", Duration = "22:48", Views = "857K views", Date = "Essential", Description = "Masbooq prayer guide: joining late." },
                    new() { Id = "pl-mn-8", YoutubeId = "DIOJT4cHzgw", Title = "Namaz Mein Nazar Kahan Rakhein?", Category = "namaz", Duration = "03:40", Views = "1.3K views", Date = "Sunnah", Description = "Where to look during each posture of Namaz." },
                    new() { Id = "pl-mn-9", YoutubeId = "HZlo992DFS4", Title = "Witr Namaz ka tariqa | 3 rakat witr", Category = "namaz", Duration = "21:01", Views = "233K views", Date = "Witr Guide", Description = "Authentic Hanafi method for 3 Rakat Witr." },
                    new() { Id = "pl-mn-10", YoutubeId = "zBwONoMO_6g", Title = "Kursi Par Namaz ka Tarika Practically", Category = "namaz", Duration = "11:20", Views = "260K views", Date = "Special", Description = "Practical guide for praying Salah on a chair." }
                ]
            },
            new()
            {
                Id = "pl-masail-namaz",
                Title = "Namaz Ke Zaroori Masail & Ghalatiyan (नमाज़ के मसाइल)",
                UrduTitle = "نماز کے ضروری مسائل اور عام غلطیوں کی اصلاح",
                Category = "namaz",
                TopicKey = "Namaz ke Zaroori Masail",
                Thumbnail = "https://img.youtube.com/vi/Ys4wYLMyyMo/hqdefault.jpg",
                Description = "Sajda Sahw ke masail, namaz me surah ki tartib, bhool chook ke ahkam.",
                Videos =
                [
                    new() { Id = "pl-ms-1", YoutubeId = "Ys4wYLMyyMo", Title = "Namaz Mein Kaunsi Surah Padhein? 4 Qul Tartib", Category = "namaz", Duration = "06:59", Views = "14K views", Date = "Surah Order", Description = "Sequence of reciting Surahs in Namaz." },
                    new() { Id = "pl-ms-2", YoutubeId = "p34oV0PLpmQ", Title = "Namaz Mein Sana Bhool Gaye To Sajda Sahw Hoga?", Category = "namaz", Duration = "07:39", Views = "15K views", Date = "Sajda Sahw", Description = "Rulings on forgetting Sana." },
                    new() { Id = "pl-ms-3", YoutubeId = "uCXUdYTzEi8", Title = "4 Rakat Mein Bhool Kar Teesri Rakat Par Baith Jaye To?", Category = "namaz", Duration = "04:55", Views = "1.8K views", Date = "Mistakes", Description = "Sitting down unintentionally on third rakat." },
                    new() { Id = "pl-ms-4", YoutubeId = "CdJxFP0SZY8", Title = "4 Rakat Mein 3 Rakat Par Salam Pher Diya To Kya Karein?", Category = "namaz", Duration = "04:11", Views = "1.8K views", Date = "Early Salam", Description = "Accidentally making Salam early." },
                    new() { Id = "pl-ms-5", YoutubeId = "0JJc-l6yBek", Title = "Surah Fatiha Ki Jagah Attahiyat Padh Li To?", Category = "namaz", Duration = "04:31", Views = "3.6K views", Date = "Recitation", Description = "Interchanging Surah Fatiha and Tashahhud." }
                ]
            },
            new()
            {
                Id = "pl-wudu-ghusl",
                Title = "Wazu & Ghusl Ka Masnoon Tarika (वुज़ू और ग़ुस्ल)",
                UrduTitle = "وضو اور غسل کا مسنون طریقہ اور طہارت کے احکام",
                Category = "wudu",
                TopicKey = "Wazu & Ghusal",
                Thumbnail = "https://img.youtube.com/vi/ZQRo2roF4DM/hqdefault.jpg",
                Description = "Namaz ki pehli shart Paaki aur Taharat hai. Wudu ke 4 Farz, Ghusl ke 3 Farz.",
                Videos =
                [
                    new() { Id = "pl-wg-1", YoutubeId = "ZQRo2roF4DM", Title = "Wudu Ka Sunnat Tariqa Complete Guide", Category = "wudu", Duration = "10:21", Views = "10K views", Date = "Essential", Description = "Step by step Sunnah method of ablution." },
                    new() { Id = "pl-wg-2", YoutubeId = "Ml7muvtbM6k", Title = "Ghusal ka sunnat tarika For Men And Women", Category = "wudu", Duration = "09:45", Views = "762K views", Date = "Trending", Description = "Ritual purification method." },
                    new() { Id = "pl-wg-3", YoutubeId = "czTAESgupJc", Title = "Ghusl Karne Ka Sunnat Tarika in Ramzan", Category = "wudu", Duration = "19:13", Views = "76K views", Date = "Ramzan", Description = "Purification during fasting days." },
                    new() { Id = "pl-wg-4", YoutubeId = "_274tAeBMcw", Title = "Wazu ka tarika for women Practical", Category = "wudu", Duration = "07:02", Views = "413K views", Date = "Women Wudu", Description = "Practical ablution for women." },
                    new() { Id = "pl-wg-5", YoutubeId = "Zz-A6oBzIcM", Title = "Wuzu Ki 22 Ghaltiyan Jo Makrooh Karti Hain", Category = "wudu", Duration = "12:23", Views = "2.8K views", Date = "Mistakes", Description = "Common mistakes in Wudu." }
                ]
            },
            new()
            {
                Id = "pl-qaza-namaz",
                Title = "Qaza Namaz Ka Aasan Tarika (قضا نماز کا طریقہ)",
                UrduTitle = "قضا نمازوں کا حساب، نیت اور پڑھنے کا آسان طریقہ",
                Category = "namaz",
                TopicKey = "Qaza Namaz Ka Tarika",
                Thumbnail = "https://img.youtube.com/vi/Vk4O2AIKhXc/hqdefault.jpg",
                Description = "Qaza-e-Umri ka aasan tareeqa aur schedule.",
                Videos =
                [
                    new() { Id = "pl-qz-1", YoutubeId = "Vk4O2AIKhXc", Title = "Qaza Namaz ka tarika Complete Guide", Category = "namaz", Duration = "15:02", Views = "756K views", Date = "Must Watch", Description = "Complete calculation and swift recitation guide." },
                    new() { Id = "pl-qz-2", YoutubeId = "Bh2MKaRtqBQ", Title = "Qaza Namaz ki niyat kaise kare", Category = "namaz", Duration = "05:43", Views = "21K views", Date = "Niyat Guide", Description = "Exact niyat words for missed Salah." },
                    new() { Id = "pl-qz-3", YoutubeId = "QU7mjlS3_VY", Title = "Namaz ki rakat nikal jaye to kaise padhe", Category = "namaz", Duration = "22:48", Views = "857K views", Date = "Missed Rakats", Description = "How to complete missed rakats." }
                ]
            },
            new()
            {
                Id = "pl-fatiha-tarika",
                Title = "Fatiha Dene Ka Sahi Tarika (فاتحہ دینے کا طریقہ)",
                UrduTitle = "فاتحہ، نیاز اور ایصال ثواب کا صحیح مسنون طریقہ",
                Category = "masail",
                TopicKey = "Fatiha Dene ka tarika",
                Thumbnail = "https://img.youtube.com/vi/Y-6v6x3YJgE/hqdefault.jpg",
                Description = "Khatam Sharif, Fatiha khwani aur Isal-e-Sawab ka sunnat tareeqa.",
                Videos =
                [
                    new() { Id = "pl-ft-1", YoutubeId = "Y-6v6x3YJgE", Title = "Khatam Sharif Padhne Ka Sahi Sunnat Tarika", Category = "masail", Duration = "11:42", Views = "28K views", Date = "Official Bayan", IsMasterclass = true, Description = "Step by step Khatam Sharif and Fatiha." },
                    new() { Id = "pl-ft-2", YoutubeId = "0JJc-l6yBek", Title = "Namaz Mein Surah Fatiha Ki Jagah Attahiyat Padh Li To?", Category = "masail", Duration = "04:31", Views = "3.6K views", Date = "Essential", Description = "Ahkam of reciting Surah Fatiha." }
                ]
            },
            new()
            {
                Id = "pl-imam-peeche",
                Title = "Imam Ke Peeche Namaz Ka Tarika (इमाम के पीछे नमाज़)",
                UrduTitle = "امام کے پیچھے باجماعت نماز پڑھنے کا طریقہ اور مسائل",
                Category = "namaz",
                TopicKey = "Imam Ke Peeche Namaz ka Tarika",
                Thumbnail = "https://img.youtube.com/vi/h1RO3NyMdQg/hqdefault.jpg",
                Description = "Jamat se namaz padhte waqt muqtadi ke zaroori ahkam.",
                Videos =
                [
                    new() { Id = "pl-ip-1", YoutubeId = "h1RO3NyMdQg", Title = "5 Waqt ki Farz Namaz imam ke piche", Category = "namaz", Duration = "1:20:53", Views = "757K views", Date = "Full Guide", IsMasterclass = true, Description = "Praying all 5 daily prayers behind Imam." },
                    new() { Id = "pl-ip-2", YoutubeId = "zPeeS6vFspA", Title = "Fajar ki namaz imam ke piche kaise padhe", Category = "namaz", Duration = "12:42", Views = "206K views", Date = "Fajr", Description = "Fajr congregational prayer." },
                    new() { Id = "pl-ip-3", YoutubeId = "H65gTP4kqS8", Title = "Imam Ke Peeche Surah Fatiha Padhna Jaiz Hai Ya Nahi?", Category = "namaz", Duration = "07:47", Views = "12K views", Date = "Key Fatwa", Description = "Detailed analysis of reciting Surah Fatiha behind Imam." }
                ]
            },
            new()
            {
                Id = "pl-shariat-masail",
                Title = "Shariat Ke Aham Masail & Fiqh Ahkam (شریعت کے مسائل)",
                UrduTitle = "شریعت کے روزمرہ ضروری مسائل اور شرعی رہنمائی",
                Category = "masail",
                TopicKey = "Shariat ke Masail",
                Thumbnail = "https://img.youtube.com/vi/822Np6q_zQQ/hqdefault.jpg",
                Description = "Rozmarrah zindagi ke ahem shar'i masail aur Fiqh-e-Hanafi ke fatawa.",
                Videos =
                [
                    new() { Id = "pl-sm-1", YoutubeId = "822Np6q_zQQ", Title = "Namaz ko todne wali cheezain | Mufsidat e Namaz", Category = "masail", Duration = "22:33", Views = "74K views", Date = "Mufsidat", Description = "Things that break your prayer." },
                    new() { Id = "pl-sm-2", YoutubeId = "IaJcljFpgBc", Title = "Fajr Aur Asr Ke Baad Quran Padhna Kaisa?", Category = "masail", Duration = "03:51", Views = "961 views", Date = "Recitation", Description = "Reciting Holy Quran after Fajr and Asr." },
                    new() { Id = "pl-sm-3", YoutubeId = "nntTFbC4Dp0", Title = "Aurat Namaz Se Pehle Azaan Aqamat Kahengi?", Category = "masail", Duration = "03:19", Views = "1.5K views", Date = "Women Azan", Description = "Whether women should call Azan." }
                ]
            },
            new()
            {
                Id = "pl-baghdadi-qaida",
                Title = "Baghdadi Qaida & Quran Recitation Classes (क़ुरआन सबक)",
                UrduTitle = "بغدادی قاعدہ اور قرآن پاک سیکھنے کی کلاسز",
                Category = "qaida",
                TopicKey = "Baghdadi Qaida",
                Thumbnail = "https://img.youtube.com/vi/4Sc6U4ISWHw/hqdefault.jpg",
                Description = "Baghdadi Qaida series jisme zero se Quran Majeed padhna seekhein.",
                Videos =
                [
                    new() { Id = "pl-bq-1", YoutubeId = "4Sc6U4ISWHw", Title = "Quran kaise sikhe online Part 01 | Bagdadi qaida", Category = "qaida", Duration = "08:33", Views = "11K views", Date = "Part 1", Description = "Arabic alphabets from basic." },
                    new() { Id = "pl-bq-2", YoutubeId = "Lvbt6krrNkw", Title = "Quran kaise sikhe online Part 02 | Zabar lessons", Category = "qaida", Duration = "03:23", Views = "5.3K views", Date = "Part 2", Description = "Harakat - Zabar lessons." },
                    new() { Id = "pl-bq-3", YoutubeId = "PSyCiiMCvjM", Title = "Quran kaise sikhe online Part 03 | Zer lessons", Category = "qaida", Duration = "03:18", Views = "3.7K views", Date = "Part 3", Description = "Harakat - Zer lessons." },
                    new() { Id = "pl-bq-4", YoutubeId = "jlG_-cZqgkQ", Title = "Quran kaise sikhe online Part 04 | Pesh lessons", Category = "qaida", Duration = "03:53", Views = "3.6K views", Date = "Part 4", Description = "Harakat - Pesh lessons." },
                    new() { Id = "pl-bq-5", YoutubeId = "nrvzzxMUzvg", Title = "Quran kaise sikhe online Part 05 | Combined Harakat", Category = "qaida", Duration = "05:02", Views = "2.5K views", Date = "Part 5", Description = "Combined Harakat practice." }
                ]
            }
        ];

        data.Courses =
        [
            new()
            {
                Id = "course-namaz-masterclass",
                Title = "Namaz Ka Mukammal Tarika (Fiqh-e-Hanafi Masterclass)",
                UrduTitle = "نماز کا مکمل طریقہ (حنفی فقہ کے مطابق)",
                Category = "namaz",
                Price = 499,
                OriginalPrice = 1499,
                DiscountPercent = 67,
                Duration = "8h 45m",
                LessonsCount = 24,
                Badge = "Best Seller",
                Instructor = "Hafiz Hasnain Jaani",
                Rating = 4.95,
                StudentsEnrolled = 3840,
                Thumbnail = "https://img.youtube.com/vi/h1RO3NyMdQg/hqdefault.jpg",
                Description = "Learn authentic 5 daily prayers, step-by-step recitation with Tajweed, Sajda Sahw masail, and prayer behind the Imam.",
                Highlights =
                [
                    "Complete practical video breakdown for men and women",
                    "Downloadable Namaz PDF Charts & Dua book",
                    "Direct Q&A Masala Support with Hafiz Hasnain Jaani"
                ],
                Lessons =
                [
                    new() { Id = "les-nm-1", Title = "Lesson 1: Namaz Ki Sharait, Niyat Aur Takbeer-e-Tehrima", Duration = "18:40", YoutubeId = "h1RO3NyMdQg", IsFreePreview = true, Summary = "Introduction to Salah prerequisites and raising hands." },
                    new() { Id = "les-nm-2", Title = "Lesson 2: Mardon Ki Namaz: Qayaam, Sana, Surah Fatiha Aur Ruku", Duration = "24:15", YoutubeId = "zPeeS6vFspA", Summary = "Breakdown of standing posture and Ruku." }
                ]
            },
            new()
            {
                Id = "course-baghdadi-qaida",
                Title = "Baghdadi Qaida & Quran Tajweed Masterclass",
                UrduTitle = "بغدادی قاعدہ اور قرآن تجوید ماسٹرکلاس",
                Category = "qaida",
                Price = 399,
                OriginalPrice = 999,
                DiscountPercent = 60,
                Duration = "6h 15m",
                LessonsCount = 16,
                Badge = "Featured",
                Instructor = "Hafiz Hasnain Jaani",
                Rating = 4.9,
                StudentsEnrolled = 2310,
                Thumbnail = "https://img.youtube.com/vi/IaJcljFpgBc/hqdefault.jpg",
                Description = "Learn to recite the Holy Quran with correct Makharij, Tajweed rules, and authentic articulation.",
                Highlights =
                [
                    "Complete 16-part step-by-step video curriculum",
                    "Accurate Arabic Makharij pronunciation",
                    "Direct practice with Hafiz Hasnain Jaani"
                ],
                Lessons = []
            },
            new()
            {
                Id = "course-wudu-ghusl",
                Title = "Taharat, Wudu & Ghusl Mukammal Course",
                UrduTitle = "طہارت، وضو اور غسل مکمل کورس",
                Category = "wudu",
                Price = 299,
                OriginalPrice = 799,
                DiscountPercent = 62,
                Duration = "3h 10m",
                LessonsCount = 8,
                Badge = "Essential",
                Instructor = "Hafiz Hasnain Jaani",
                Rating = 4.8,
                StudentsEnrolled = 1420,
                Thumbnail = "https://img.youtube.com/vi/Q9tG82Xv6oE/hqdefault.jpg",
                Description = "Practical demonstration of 4 Faraiz of Wudu, 3 Faraiz of Ghusl, and solving daily purification doubts.",
                Highlights =
                [
                    "Hanafi jurisprudence of ritual purity",
                    "Common wudu & ghusl mistakes explained"
                ],
                Lessons = []
            }
        ];

        data.Quotes =
        [
            new() { Id = "quote-1", Category = "Daily Hadith", Arabic = "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ", Urdu = "تم میں سب سے بہترین شخص وہ ہے جو قرآن سیکھے اور دوسروں کو سکھائے۔", English = "The best among you are those who learn the Quran and teach it to others.", Reference = "Sahih Al-Bukhari 5027", Theme = "theme-emerald", Likes = 342 },
            new() { Id = "quote-2", Category = "Quranic Ayah", Arabic = "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ", Urdu = "سن لو! اللہ کے ذکر ہی سے دلوں کو اطمینان اور سکون حاصل ہوتا ہے۔", English = "Unquestionably, by the remembrance of Allah hearts are assured.", Reference = "Surah Ar-Ra'd [13:28]", Theme = "theme-gold", Likes = 512 },
            new() { Id = "quote-3", Category = "Golden Saying", Arabic = "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ", Urdu = "بے شک نماز بے حیائی اور برے کاموں سے روکتی ہے۔", English = "Indeed, prayer prohibits immorality and wrongdoing.", Reference = "Surah Al-Ankabut [29:45]", Theme = "theme-royal", Likes = 289 },
            new() { Id = "quote-4", Category = "Daily Hadith", Arabic = "مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللَّهُ عَلَيْهِ بِهَا عَشْرًا", Urdu = "جو شخص مجھ پر ایک بار درود بھیجے، اللہ تعالیٰ اس پر دس رحمتیں نازل فرماتا ہے۔", English = "Whoever sends blessings upon me once, Allah sends ten blessings upon him.", Reference = "Sahih Muslim 408", Theme = "theme-emerald", Likes = 820 }
        ];

        data.DhikrList =
        [
            new() { Id = "subhanallah", Name = "SubhanAllah", Arabic = "سُبْحَانَ اللَّهِ", Meaning = "Glory be to Allah", Target = 33 },
            new() { Id = "alhamdulillah", Name = "Alhamdulillah", Arabic = "الْحَمْدُ لِلَّهِ", Meaning = "All praise is due to Allah", Target = 33 },
            new() { Id = "allahuakbar", Name = "Allahu Akbar", Arabic = "اللَّهُ أَكْبَرُ", Meaning = "Allah is the Greatest", Target = 34 },
            new() { Id = "astaghfirullah", Name = "Astaghfirullah", Arabic = "أَسْتَغْفِرُ اللَّهَ", Meaning = "I seek forgiveness from Allah", Target = 100 },
            new() { Id = "durood", Name = "Allahumma Salli Ala Sayyidina Muhammad", Arabic = "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ", Meaning = "O Allah, send blessings upon our Master Muhammad", Target = 100 }
        ];

        data.PrayerLocations =
        [
            new() { Id = "purnia", Name = "Purnia, Bihar (Scholar HQ)", Lat = 25.7771, Lng = 87.4753, Tz = 5.5, Group = "🌟 Featured & Scholar HQ" },
            new() { Id = "sa_makkah_hq", Name = "Makkah al-Mukarramah (Kaaba)", Lat = 21.4225, Lng = 39.8262, Tz = 3.0, Group = "🌟 Featured & Holy Sites" },
            new() { Id = "sa_madinah_hq", Name = "Madinah al-Munawwarah (Masjid Nabawi)", Lat = 24.4672, Lng = 39.6111, Tz = 3.0, Group = "🌟 Featured & Holy Sites" },
            new() { Id = "ps_alquds_hq", Name = "Jerusalem / Al-Quds (Masjid Al-Aqsa)", Lat = 31.7767, Lng = 35.2345, Tz = 3.0, Group = "🌟 Featured & Holy Sites" },
            new() { Id = "in_up_bareilly_hq", Name = "Bareilly Sharif, UP (Markaz Ahle Sunnat)", Lat = 28.3670, Lng = 79.4304, Tz = 5.5, Group = "🌟 Featured & Scholar HQ" },
            new() { Id = "in_dl_newdelhi_hq", Name = "New Delhi (Capital, India)", Lat = 28.6139, Lng = 77.2090, Tz = 5.5, Group = "🇮🇳 India - Major Metros" },
            new() { Id = "in_mh_mumbai_hq", Name = "Mumbai, Maharashtra", Lat = 18.9777, Lng = 72.8080, Tz = 5.5, Group = "🇮🇳 India - Major Metros" },
            new() { Id = "in_mh_ratnagiri", Name = "Ratnagiri", Lat = 16.9902, Lng = 73.3120, Tz = 5.5, Group = "🇮🇳 Maharashtra Districts" },
            new() { Id = "in_wb_kolkata_hq", Name = "Kolkata, West Bengal", Lat = 22.5726, Lng = 88.3639, Tz = 5.5, Group = "🇮🇳 India - Major Metros" },
            new() { Id = "in_tg_hyderabad_hq", Name = "Hyderabad, Telangana", Lat = 17.3850, Lng = 78.4867, Tz = 5.5, Group = "🇮🇳 India - Major Metros" },
            new() { Id = "in_br_patna", Name = "Patna, Bihar", Lat = 25.5941, Lng = 85.1376, Tz = 5.5, Group = "🇮🇳 Bihar Districts" },
            new() { Id = "in_br_katihar", Name = "Katihar, Bihar", Lat = 25.5394, Lng = 87.5702, Tz = 5.5, Group = "🇮🇳 Bihar Districts" },
            new() { Id = "in_br_kishanganj", Name = "Kishanganj, Bihar", Lat = 26.1030, Lng = 87.9400, Tz = 5.5, Group = "🇮🇳 Bihar Districts" },
            new() { Id = "in_br_araria", Name = "Araria, Bihar", Lat = 26.1517, Lng = 87.4930, Tz = 5.5, Group = "🇮🇳 Bihar Districts" },
            new() { Id = "in_br_bhagalpur", Name = "Bhagalpur, Bihar", Lat = 25.2425, Lng = 86.9842, Tz = 5.5, Group = "🇮🇳 Bihar Districts" },
            new() { Id = "in_br_darbhanga", Name = "Darbhanga, Bihar", Lat = 26.1542, Lng = 85.8918, Tz = 5.5, Group = "🇮🇳 Bihar Districts" },
            new() { Id = "in_up_lucknow", Name = "Lucknow, Uttar Pradesh", Lat = 26.8467, Lng = 80.9462, Tz = 5.5, Group = "🇮🇳 Uttar Pradesh Districts" },
            new() { Id = "in_up_kanpur", Name = "Kanpur, Uttar Pradesh", Lat = 26.4499, Lng = 80.3319, Tz = 5.5, Group = "🇮🇳 Uttar Pradesh Districts" },
            new() { Id = "in_up_varanasi", Name = "Varanasi, Uttar Pradesh", Lat = 25.3176, Lng = 82.9739, Tz = 5.5, Group = "🇮🇳 Uttar Pradesh Districts" },
            new() { Id = "in_up_aligarh", Name = "Aligarh, Uttar Pradesh", Lat = 27.8974, Lng = 78.0880, Tz = 5.5, Group = "🇮🇳 Uttar Pradesh Districts" },
            new() { Id = "in_rj_ajmer", Name = "Ajmer Sharif, Rajasthan", Lat = 26.4499, Lng = 74.6399, Tz = 5.5, Group = "🇮🇳 Rajasthan Districts" },
            new() { Id = "uk_london", Name = "London, United Kingdom", Lat = 51.5074, Lng = -0.1278, Tz = 0.0, Group = "🌍 International" },
            new() { Id = "us_newyork", Name = "New York, United States", Lat = 40.7128, Lng = -74.0060, Tz = -5.0, Group = "🌍 International" },
            new() { Id = "ae_dubai", Name = "Dubai, UAE", Lat = 25.2048, Lng = 55.2708, Tz = 4.0, Group = "🌍 International" }
        ];

        return data;
    }
}

