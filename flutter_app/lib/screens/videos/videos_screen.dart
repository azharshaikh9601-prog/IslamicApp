import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/video_model.dart';
import '../../models/playlist_model.dart';
import '../../services/storage_service.dart';
import '../../widgets/video_player/in_app_player_modal.dart';
import '../../widgets/video_selection_dialog.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  String _activeView = 'playlists'; // 'playlists' | 'all-videos'
  String _selectedTopicFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _playVideoInApp(
    BuildContext context,
    VideoModel video, {
    PlaylistModel? playlist,
    int? playlistIndex,
  }) {
    InAppPlayerModal.show(
      context,
      video: video,
      playlist: playlist,
      playlistIndex: playlistIndex,
    );
  }

  void _openYouTubeChannel() async {
    final uri = Uri.parse('https://www.youtube.com/@HAFIZHASNAINJAANI?sub_confirmation=1');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Admin dialog: Create Playlist
  void _showCreatePlaylistDialog(BuildContext context, AppStateService appState) {
    final titleCtrl = TextEditingController();
    final urduCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final thumbCtrl = TextEditingController();
    String topicKey = 'Namaz Ka Tarika';
    List<VideoModel> selectedVideos = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkEmerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.playlist_add, color: AppColors.primaryGold),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Admin: Create New Playlist',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Playlist Title (English/Hindi)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: urduCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Urdu Title (اردو عنوان)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Description / Fiqh details',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: thumbCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Thumbnail Image URL (optional, auto-picks from 1st video)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    hintText: 'Leave empty to auto-use first video thumbnail',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: topicKey,
                  dropdownColor: AppColors.darkEmerald,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Topic Category',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Namaz Ka Tarika', child: Text('Namaz Ka Tarika')),
                    DropdownMenuItem(value: 'Wazu & Ghusal', child: Text('Wazu & Ghusal')),
                    DropdownMenuItem(value: 'Aurat Ki Namaz', child: Text('Aurat Ki Namaz')),
                    DropdownMenuItem(value: 'Namaz ke Zaroori Masail', child: Text('Namaz ke Zaroori Masail')),
                    DropdownMenuItem(value: 'Qaza Namaz Ka Tarika', child: Text('Qaza Namaz Ka Tarika')),
                    DropdownMenuItem(value: 'Fatiha Dene ka tarika', child: Text('Fatiha Dene ka tarika')),
                    DropdownMenuItem(value: 'Imam Ke Peeche Namaz ka Tarika', child: Text('Imam Ke Peeche Namaz')),
                    DropdownMenuItem(value: 'Shariat ke Masail', child: Text('Shariat ke Masail')),
                    DropdownMenuItem(value: 'Baghdadi Qaida', child: Text('Baghdadi Qaida')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => topicKey = val);
                  },
                ),
                const SizedBox(height: 14),
                // Video Selection Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF082218),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderEmerald),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.video_library, color: AppColors.primaryGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Playlist Videos:',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              selectedVideos.isEmpty
                                  ? 'No videos selected'
                                  : '${selectedVideos.length} videos selected from uploaded library',
                              style: const TextStyle(color: AppColors.lightGold, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          VideoSelectionDialog.show(
                            context,
                            appState: appState,
                            initiallySelected: selectedVideos,
                            title: 'Select Playlist Videos',
                            onConfirmed: (chosen) {
                              setDialogState(() {
                                selectedVideos = chosen;
                                if (thumbCtrl.text.trim().isEmpty && chosen.isNotEmpty) {
                                  thumbCtrl.text = chosen.first.thumbnailUrl;
                                }
                              });
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.darkEmerald,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          selectedVideos.isEmpty ? 'Select Videos' : 'Change (${selectedVideos.length})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final thumb = thumbCtrl.text.trim().isEmpty
                    ? (selectedVideos.isNotEmpty
                        ? selectedVideos.first.thumbnailUrl
                        : 'https://img.youtube.com/vi/gMTvoRUgeXA/hqdefault.jpg')
                    : (thumbCtrl.text.trim().startsWith('http')
                        ? thumbCtrl.text.trim()
                        : 'https://img.youtube.com/vi/${thumbCtrl.text.trim()}/hqdefault.jpg');

                final newPl = PlaylistModel(
                  id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  urduTitle: urduCtrl.text.trim().isEmpty ? titleCtrl.text.trim() : urduCtrl.text.trim(),
                  category: topicKey,
                  topicKey: topicKey,
                  thumbnail: thumb,
                  description: descCtrl.text.trim().isEmpty
                      ? 'Authentic Islamic lessons by Hafiz Hasnain Jaani.'
                      : descCtrl.text.trim(),
                  videos: selectedVideos,
                );
                appState.addPlaylist(newPl);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ New Playlist successfully published!'),
                    backgroundColor: AppColors.darkEmerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkEmerald,
              ),
              child: const Text('Publish Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }



  // Edit Playlist Dialog: add/remove videos and modify details
  void _showEditPlaylistDialog(BuildContext context, PlaylistModel playlist, AppStateService appState) {
    final titleCtrl = TextEditingController(text: playlist.title);
    final urduCtrl = TextEditingController(text: playlist.urduTitle);
    final descCtrl = TextEditingController(text: playlist.description);
    String category = playlist.category;
    List<VideoModel> currentVideos = List<VideoModel>.from(playlist.videos);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF041E16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Edit Playlist',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                  tooltip: 'Delete Playlist',
                  onPressed: () {
                    appState.deletePlaylist(playlist.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playlist deleted.'), backgroundColor: Colors.redAccent),
                    );
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Playlist Title',
                        labelStyle: TextStyle(color: AppColors.lightGold),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                      ),
                    ),
                    TextField(
                      controller: urduCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Urdu Title (اردو عنوان)',
                        labelStyle: TextStyle(color: AppColors.lightGold),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Videos in Playlist (${currentVideos.length}):',
                            style: const TextStyle(color: AppColors.lightGold, fontSize: 12.5, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            VideoSelectionDialog.show(
                              context,
                              appState: appState,
                              initiallySelected: currentVideos,
                              title: 'Edit Playlist Videos',
                              onConfirmed: (selected) {
                                setDialogState(() {
                                  currentVideos = selected;
                                });
                              },
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate, size: 14, color: AppColors.primaryGold),
                          label: const Text('Add / Change Videos', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: const Color(0xFF082218),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderEmerald),
                      ),
                      child: currentVideos.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No videos in this playlist. Click "Add / Change Videos" above.',
                                    style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12), textAlign: TextAlign.center),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: currentVideos.length,
                              separatorBuilder: (_, __) => const Divider(color: AppColors.borderEmerald, height: 1),
                              itemBuilder: (ctx, idx) {
                                final v = currentVideos[idx];
                                return ListTile(
                                  dense: true,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: SizedBox(
                                      width: 44,
                                      height: 30,
                                      child: Image.network(v.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.white10)),
                                    ),
                                  ),
                                  title: Text(
                                    '${idx + 1}. ${v.title}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                                    tooltip: 'Remove from Playlist',
                                    onPressed: () {
                                      setDialogState(() {
                                        currentVideos.removeAt(idx);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final updatedPl = PlaylistModel(
                    id: playlist.id,
                    title: titleCtrl.text.trim(),
                    urduTitle: urduCtrl.text.trim().isEmpty ? titleCtrl.text.trim() : urduCtrl.text.trim(),
                    category: category,
                    topicKey: playlist.topicKey,
                    thumbnail: currentVideos.isNotEmpty ? currentVideos.first.thumbnailUrl : playlist.thumbnail,
                    description: descCtrl.text.trim().isEmpty ? playlist.description : descCtrl.text.trim(),
                    videos: currentVideos,
                  );
                  appState.updatePlaylist(updatedPl);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Playlist updated successfully!'),
                      backgroundColor: AppColors.darkEmerald,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkEmerald,
                ),
                child: const Text('Save Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Admin dialog: Upload Video Lesson
  void _showUploadVideoDialog(BuildContext context, AppStateService appState) {
    final titleCtrl = TextEditingController();
    final ytIdCtrl = TextEditingController();
    final durCtrl = TextEditingController(text: '15:20');
    final descCtrl = TextEditingController();
    String category = 'namaz';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final dialogWidth = math.min(460.0, MediaQuery.of(ctx).size.width * 0.92);

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            backgroundColor: AppColors.darkEmerald,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
            titlePadding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            title: Row(
              children: const [
                Icon(Icons.video_call, color: AppColors.primaryGold, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Admin: Upload Video Lesson',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: math.min(dialogWidth, MediaQuery.of(ctx).size.width - 48),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Video Title',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: ytIdCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'YouTube Video ID or Link',
                    hintText: 'e.g. gMTvoRUgeXA',
                    hintStyle: TextStyle(color: Colors.white38),
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: durCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Duration (e.g. 18:40)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Description / Fiqh references',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppColors.darkEmerald,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'namaz', child: Text('Namaz & Prayer')),
                    DropdownMenuItem(value: 'wudu', child: Text('Wazu & Ghusl')),
                    DropdownMenuItem(value: 'masail', child: Text('Shariat Masail')),
                    DropdownMenuItem(value: 'qaida', child: Text('Baghdadi Qaida / Quran')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || ytIdCtrl.text.trim().isEmpty) return;

                // Extract YouTube ID if full URL pasted
                String ytId = ytIdCtrl.text.trim();
                if (ytId.contains('v=')) {
                  ytId = ytId.split('v=')[1].split('&')[0];
                } else if (ytId.contains('youtu.be/')) {
                  ytId = ytId.split('youtu.be/')[1].split('?')[0];
                }

                final newVid = VideoModel(
                  id: 'vid-$ytId',
                  youtubeId: ytId,
                  title: titleCtrl.text.trim(),
                  category: category,
                  duration: durCtrl.text.trim().isEmpty ? '15:00' : durCtrl.text.trim(),
                  views: 'Just uploaded',
                  date: 'Just now',
                  description: descCtrl.text.trim().isEmpty
                      ? 'Authentic Islamic lesson by Hafiz Hasnain Jaani.'
                      : descCtrl.text.trim(),
                );
                appState.addVideo(newVid);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Video lesson successfully published to library!'),
                    backgroundColor: AppColors.darkEmerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkEmerald,
              ),
              child: const Text('Upload Video', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ),
  );
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        // If coming with a preselected playlist from Home, view that playlist detail
        if (appState.selectedPlaylistId != null) {
          final targetPlaylist = appState.playlists.firstWhere(
            (p) => p.id == appState.selectedPlaylistId,
            orElse: () => appState.playlists.first,
          );
          return _buildPlaylistDetailView(context, targetPlaylist, appState);
        }

        return CustomScrollView(
          slivers: [
            // 1. Top Header Banner with Admin Action Buttons (shown only if admin)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Learn Islam Easily',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Namaz, wudu, ghusal, islamic masail & more',
                                style: TextStyle(
                                  color: AppColors.darkTextMuted,
                                  fontSize: 11.5,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (appState.isAdmin) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showCreatePlaylistDialog(context, appState),
                              icon: const Icon(Icons.playlist_add, size: 16),
                              label: const Text('Create Playlist'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.darkEmerald,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showUploadVideoDialog(context, appState),
                              icon: const Icon(Icons.upload, size: 16),
                              label: const Text('Upload Video'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.darkEmerald,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // 2. Official YouTube Channel Card (Matching user screenshot)
                    _buildChannelCard(),

                    const SizedBox(height: 14),

                    // 3. View Switcher: Playlists vs All Video Lessons
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderEmerald),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeView = 'playlists'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _activeView == 'playlists'
                                      ? AppColors.primaryGold
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.playlist_play_rounded,
                                        size: 18,
                                        color: _activeView == 'playlists'
                                            ? AppColors.darkEmerald
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Playlists (प्लेलिस्ट्स)',
                                        style: TextStyle(
                                          color: _activeView == 'playlists'
                                              ? AppColors.darkEmerald
                                              : Colors.white70,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeView = 'all-videos'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _activeView == 'all-videos'
                                      ? AppColors.primaryGold
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.video_library_outlined,
                                        size: 16,
                                        color: _activeView == 'all-videos'
                                            ? AppColors.darkEmerald
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'All Video Lessons',
                                        style: TextStyle(
                                          color: _activeView == 'all-videos'
                                              ? AppColors.darkEmerald
                                              : Colors.white70,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 3.5. Search Bar for Lessons & Playlists
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceEmerald,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderEmerald),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: _activeView == 'playlists'
                              ? 'Search playlists (e.g. Namaz, Wudu, Masail)...'
                              : 'Search video lessons by title...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 4. Topic Filter Chips
                    _buildTopicFilterChips(appState),
                  ],
                ),
              ),
            ),

            // 5. Main 2-Column Grid of Cards (Matching user screenshot)
            _activeView == 'playlists'
                ? _buildPlaylistsGridSliver(context, appState)
                : _buildVideosGridSliver(context, appState),

            const SliverToBoxAdapter(
              child: SizedBox(height: 14),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // YouTube Channel Card (Matching screenshot)
  // ---------------------------------------------------------------------------
  Widget _buildChannelCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C241C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Flexible(
                          child: Text(
                            'Hafiz Hasnain Jaani',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.check_circle, color: AppColors.brightGold, size: 15),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: const Text(
                        'Official YouTube Channel',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '@HAFIZHASNAINJAANI • 413K Subscribers',
                      style: TextStyle(
                        color: AppColors.lightGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openYouTubeChannel,
                  icon: const Icon(Icons.subscriptions, size: 16, color: Colors.white),
                  label: const Text('Subscribe on YouTube'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Topic Filter Chips
  // ---------------------------------------------------------------------------
  Widget _buildTopicFilterChips(AppStateService appState) {
    final List<Map<String, String>> topics = [
      {'id': 'all', 'label': '✨ All Topics'},
      {'id': 'namaz-all', 'label': '🕌 Namaz Ka Tarika'},
      {'id': 'wudu', 'label': '💧 Wudu & Ghusl'},
      {'id': 'aurat-namaz', 'label': '🧕 Aurat Ki Namaz'},
      {'id': 'mardo-namaz', 'label': '👳 Mardon Ki Namaz'},
      {'id': 'namaz-masail', 'label': '⚖️ Namaz Ke Masail'},
      {'id': 'qaza', 'label': '⏱️ Qaza Namaz'},
      {'id': 'fatiha', 'label': '🤲 Fatiha Dene Ka Tarika'},
      {'id': 'imam', 'label': '👥 Imam Ke Peeche'},
      {'id': 'shariat', 'label': '📜 Shariat Masail'},
      {'id': 'qaida', 'label': '📖 Baghdadi Qaida'},
    ];

    final currentFilter = appState.selectedTopicFilter ?? _selectedTopicFilter;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final t = topics[index];
          final bool isSelected = (currentFilter == t['id']) ||
              (t['id'] == 'namaz-all' && currentFilter == 'Namaz Ka Tarika') ||
              (t['id'] == 'wudu' && currentFilter == 'Wazu & Ghusal') ||
              (t['id'] == 'aurat-namaz' && currentFilter == 'Aurat Ki Namaz') ||
              (t['id'] == 'namaz-masail' && currentFilter == 'Namaz ke Zaroori Masail') ||
              (t['id'] == 'shariat' && currentFilter == 'Shariat ke Masail') ||
              (t['id'] == 'qaza' && currentFilter == 'Qaza Namaz Ka Tarika') ||
              (t['id'] == 'fatiha' && currentFilter == 'Fatiha Dene ka tarika') ||
              (t['id'] == 'imam' && currentFilter == 'Imam Ke Peeche Namaz ka Tarika');

          return ChoiceChip(
            label: Text(t['label']!),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedTopicFilter = t['id']!);
                appState.selectTopic(null);
              }
            },
            selectedColor: AppColors.primaryGold,
            backgroundColor: AppColors.darkCard,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.darkEmerald : AppColors.darkTextSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isSelected ? AppColors.primaryGold : AppColors.borderEmerald,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2-Column Grid for Topic Playlists (Exact match with user screenshot)
  // ---------------------------------------------------------------------------
  Widget _buildPlaylistsGridSliver(BuildContext context, AppStateService appState) {
    final currentFilter = appState.selectedTopicFilter ?? _selectedTopicFilter;

    final filteredPlaylists = appState.playlists.where((pl) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesSearch = pl.title.toLowerCase().contains(q) ||
            pl.urduTitle.toLowerCase().contains(q) ||
            pl.description.toLowerCase().contains(q);
        if (!matchesSearch) return false;
      }

      if (currentFilter == 'all') return true;
      if (currentFilter == 'namaz-all' || currentFilter == 'Namaz Ka Tarika') {
        return pl.id == 'pl-aurat-namaz' ||
            pl.id == 'pl-mardo-namaz' ||
            pl.id == 'pl-masail-namaz' ||
            pl.id == 'pl-farq-namaz';
      }
      if (currentFilter == 'aurat-namaz' || currentFilter == 'Aurat Ki Namaz') {
        return pl.id == 'pl-aurat-namaz';
      }
      if (currentFilter == 'mardo-namaz') {
        return pl.id == 'pl-mardo-namaz';
      }
      if (currentFilter == 'namaz-masail' || currentFilter == 'Namaz ke Zaroori Masail') {
        return pl.id == 'pl-masail-namaz';
      }
      if (currentFilter == 'wudu' || currentFilter == 'Wazu & Ghusal') {
        return pl.id == 'pl-wudu-ghusl';
      }
      if (currentFilter == 'qaza' || currentFilter == 'Qaza Namaz Ka Tarika') {
        return pl.id == 'pl-qaza-namaz';
      }
      if (currentFilter == 'fatiha' || currentFilter == 'Fatiha Dene ka tarika') {
        return pl.id == 'pl-fatiha-tarika';
      }
      if (currentFilter == 'imam' || currentFilter == 'Imam Ke Peeche Namaz ka Tarika') {
        return pl.id == 'pl-imam-peeche';
      }
      if (currentFilter == 'shariat' || currentFilter == 'Shariat ke Masail') {
        return pl.id == 'pl-shariat-masail';
      }
      if (currentFilter == 'qaida' || currentFilter == 'Baghdadi Qaida') {
        return pl.id == 'pl-baghdadi-qaida';
      }
      return true;
    }).toList();

    if (filteredPlaylists.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(40),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Icon(Icons.playlist_remove, size: 48, color: AppColors.darkTextMuted),
              const SizedBox(height: 12),
              const Text('No playlists found for this topic', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _selectedTopicFilter = 'all');
                  appState.clearTopicSelection();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                child: const Text('Show All Playlists', style: TextStyle(color: AppColors.darkEmerald, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 28 - 10) / 2;
    final cardHeight = (cardWidth * (10 / 16)) + 84.0;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: cardHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final playlist = filteredPlaylists[index];
            return _build2ColPlaylistCard(context, playlist, appState);
          },
          childCount: filteredPlaylists.length,
        ),
      ),
    );
  }

  // 2-Column Playlist Card matching screenshot
  Widget _build2ColPlaylistCard(
    BuildContext context,
    PlaylistModel playlist,
    AppStateService appState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C241C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderEmerald, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 Thumbnail with Video Count Badge
            GestureDetector(
              onTap: () => appState.selectPlaylist(playlist.id),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      playlist.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceEmerald,
                        child: const Icon(Icons.playlist_play, color: AppColors.primaryGold, size: 36),
                      ),
                    ),
                  ),
                  // Badge: X VIDEOS
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.6), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.playlist_play, color: AppColors.primaryGold, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '${playlist.videoCount} VIDEOS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Admin Quick Edit Playlist Button
                  if (appState.isAdmin)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => _showEditPlaylistDialog(context, playlist, appState),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.primaryGold, width: 1),
                          ),
                          child: const Icon(Icons.edit, color: AppColors.primaryGold, size: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body (Title, Category / Edit link, Play button)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => appState.selectPlaylist(playlist.id),
                    child: Text(
                      playlist.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          playlist.category,
                          style: const TextStyle(color: AppColors.lightGold, fontSize: 9.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (appState.isAdmin)
                        InkWell(
                          onTap: () => _showEditPlaylistDialog(context, playlist, appState),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.brightGold,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // ▶ Play Entire Playlist Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (playlist.videos.isNotEmpty) {
                          _playVideoInApp(
                            context,
                            playlist.videos.first,
                            playlist: playlist,
                            playlistIndex: 0,
                          );
                        } else {
                          appState.selectPlaylist(playlist.id);
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: AppColors.darkEmerald, size: 14),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Play Entire Playlist',
                          style: TextStyle(
                            color: AppColors.darkEmerald,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2-Column Grid for All Video Lessons
  // ---------------------------------------------------------------------------
  Widget _buildVideosGridSliver(BuildContext context, AppStateService appState) {
    final filteredVideos = appState.videos.where((v) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = v.title.toLowerCase().contains(q) || v.description.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (_selectedTopicFilter == 'all') return true;
      if (_selectedTopicFilter == 'namaz-all' || _selectedTopicFilter == 'aurat-namaz' || _selectedTopicFilter == 'mardo-namaz' || _selectedTopicFilter == 'namaz-masail') {
        return v.category == 'namaz' || v.category == 'masail';
      }
      return v.category == _selectedTopicFilter;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 28 - 10) / 2;
    final cardHeight = (cardWidth * (10 / 16)) + 83.0;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: cardHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final video = filteredVideos[index];
            final isWatched = appState.isVideoWatched(video.id);

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C241C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isWatched ? Colors.redAccent.withOpacity(0.4) : AppColors.borderEmerald,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video Thumbnail with Duration & Watched badge
                    GestureDetector(
                      onTap: () => _playVideoInApp(context, video),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceEmerald,
                                child: const Icon(Icons.ondemand_video, color: AppColors.primaryGold, size: 36),
                              ),
                            ),
                          ),
                          // Duration badge
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                video.duration,
                                style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Watched badge
                          if (isWatched)
                            Positioned(
                              top: 5,
                              left: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.redAccent, width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check, color: Colors.redAccent, size: 10),
                                    SizedBox(width: 2),
                                    Text('Watched', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Video Body (Title, Views, Watch button with no empty space)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _playVideoInApp(context, video),
                            child: Text(
                              video.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                video.views,
                                style: const TextStyle(color: AppColors.lightGold, fontSize: 9.5),
                              ),
                              GestureDetector(
                                onTap: () => appState.toggleVideoWatched(video.id),
                                child: Icon(
                                  isWatched ? Icons.check_circle : Icons.check_circle_outline,
                                  color: isWatched ? Colors.redAccent : Colors.white38,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _playVideoInApp(context, video),
                              icon: const Icon(Icons.play_arrow_rounded, color: AppColors.darkEmerald, size: 14),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Watch Lesson',
                                  style: TextStyle(
                                    color: AppColors.darkEmerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: filteredVideos.length,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Playlist Detail View (When a playlist is opened to see its lessons)
  // ---------------------------------------------------------------------------
  Widget _buildPlaylistDetailView(
    BuildContext context,
    PlaylistModel playlist,
    AppStateService appState,
  ) {
    final watchedCount = playlist.videos
        .where((v) => appState.isVideoWatched(v.id))
        .length;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF07241A),
            border: const Border(bottom: BorderSide(color: AppColors.borderEmerald)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
                    onPressed: () => appState.clearTopicSelection(),
                    tooltip: 'Back to Playlists',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${playlist.videoCount} Lessons • $watchedCount Watched',
                          style: const TextStyle(
                            color: AppColors.lightGold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Play In-App Button
              ElevatedButton.icon(
                onPressed: () {
                  final firstUnwatchedIndex = playlist.videos.indexWhere(
                    (v) => !appState.isVideoWatched(v.id),
                  );
                  final targetIdx = firstUnwatchedIndex >= 0 ? firstUnwatchedIndex : 0;
                  final targetVideo = playlist.videos[targetIdx];

                  _playVideoInApp(
                    context,
                    targetVideo,
                    playlist: playlist,
                    playlistIndex: targetIdx,
                  );
                },
                icon: const Icon(Icons.play_circle_fill, color: AppColors.darkEmerald, size: 18),
                label: Text(
                  watchedCount > 0 ? 'Continue Playing In-App' : 'Play All Lessons In-App',
                  style: const TextStyle(
                    color: AppColors.darkEmerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  minimumSize: const Size.fromHeight(36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lessons List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: playlist.videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final video = playlist.videos[index];
              final isWatched = appState.isVideoWatched(video.id);

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWatched
                        ? Colors.redAccent.withOpacity(0.3)
                        : AppColors.borderEmerald,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _playVideoInApp(
                        context,
                        video,
                        playlist: playlist,
                        playlistIndex: index,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 100,
                              height: 58,
                              child: Stack(
                                children: [
                                  Image.network(
                                    video.thumbnailUrl,
                                    width: 100,
                                    height: 58,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surfaceEmerald,
                                      child: const Icon(Icons.play_arrow, color: AppColors.primaryGold),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        video.duration,
                                        style: const TextStyle(color: Colors.white, fontSize: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${video.title}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(video.views, style: const TextStyle(color: AppColors.lightGold, fontSize: 10)),
                                    const Spacer(),
                                    if (isWatched)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Watched', style: TextStyle(color: Colors.redAccent, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
