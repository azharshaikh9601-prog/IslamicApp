import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/video_model.dart';
import '../services/storage_service.dart';

class VideoSelectionDialog {
  static void show(
    BuildContext context, {
    required AppStateService appState,
    required List<VideoModel> initiallySelected,
    required ValueChanged<List<VideoModel>> onConfirmed,
    String title = 'Select Videos / Lessons',
  }) {
    // Deduplicate initial list strictly by youtubeId
    final Map<String, VideoModel> selectedMap = {};
    for (final v in initiallySelected) {
      if (v.youtubeId.trim().isNotEmpty) {
        selectedMap[v.youtubeId.trim()] = v;
      }
    }

    String dialogSearchQuery = '';
    String selectedPlaylistFilter = 'all'; // 'all' or playlist.id
    final customUrlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Source pool: either all videos or videos from selected YouTube playlist
          List<VideoModel> sourcePool = appState.videos;
          if (selectedPlaylistFilter != 'all') {
            final matchingPl = appState.playlists.firstWhere(
              (p) => p.id == selectedPlaylistFilter,
              orElse: () => appState.playlists.first,
            );
            sourcePool = matchingPl.videos;
          }

          // Strict Deduplication: eliminate any duplicate video entries by youtubeId
          final Map<String, VideoModel> uniquePoolMap = {};
          for (final v in sourcePool) {
            final yId = v.youtubeId.trim();
            if (yId.isNotEmpty && !uniquePoolMap.containsKey(yId)) {
              uniquePoolMap[yId] = v;
            }
          }
          final deduplicatedPool = uniquePoolMap.values.toList();

          final displayedVideos = dialogSearchQuery.trim().isEmpty
              ? deduplicatedPool
              : deduplicatedPool.where((v) {
                  final q = dialogSearchQuery.toLowerCase();
                  return v.title.toLowerCase().contains(q) ||
                      v.category.toLowerCase().contains(q) ||
                      v.description.toLowerCase().contains(q);
                }).toList();

          final screenWidth = MediaQuery.of(ctx).size.width;
          final screenHeight = MediaQuery.of(ctx).size.height;
          final dialogWidth = math.min(520.0, screenWidth * 0.94);
          final dialogHeight = math.min(540.0, screenHeight * 0.85);

          return AlertDialog(
            backgroundColor: const Color(0xFF041E16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
            titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            title: Row(
              children: [
                const Icon(Icons.video_library, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${selectedMap.length} Selected',
                    style: const TextStyle(color: Color(0xFF032B1F), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Column(
                children: [
                  // 1. YouTube Playlist Source Filter Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07271B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderEmerald),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_play, color: AppColors.primaryGold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPlaylistFilter,
                              dropdownColor: AppColors.darkEmerald,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All Available Videos (Full Library)'),
                                ),
                                ...appState.playlists.map((pl) => DropdownMenuItem(
                                      value: pl.id,
                                      child: Text(
                                        'Playlist: ${pl.title} (${pl.videos.length})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedPlaylistFilter = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        if (selectedPlaylistFilter != 'all')
                          TextButton.icon(
                            onPressed: () {
                              final pl = appState.playlists.firstWhere((p) => p.id == selectedPlaylistFilter);
                              setDialogState(() {
                                for (final pv in pl.videos) {
                                  if (pv.youtubeId.trim().isNotEmpty) {
                                    selectedMap[pv.youtubeId.trim()] = pv;
                                  }
                                }
                              });
                            },
                            icon: const Icon(Icons.playlist_add_check, size: 15, color: AppColors.primaryGold),
                            label: const Text(
                              'Add All',
                              style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 2. Search & Direct YouTube ID/Link Input
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceEmerald,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderEmerald),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      onChanged: (val) {
                        setDialogState(() {
                          dialogSearchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search title, category or topic...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold, size: 18),
                        suffixIcon: dialogSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                                onPressed: () {
                                  setDialogState(() {
                                    dialogSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),

                  // Direct YouTube URL Quick Adder
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF031A12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderEmerald.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_link, color: AppColors.lightGold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: customUrlCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                            decoration: const InputDecoration(
                              hintText: 'Paste YouTube Link or Video ID to add',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 10.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 6),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final raw = customUrlCtrl.text.trim();
                            if (raw.isEmpty) return;
                            String ytId = raw;
                            if (ytId.contains('v=')) {
                              ytId = ytId.split('v=')[1].split('&')[0];
                            } else if (ytId.contains('youtu.be/')) {
                              ytId = ytId.split('youtu.be/')[1].split('?')[0];
                            }
                            ytId = ytId.trim();
                            if (ytId.isNotEmpty) {
                              final directVid = VideoModel(
                                id: 'vid-$ytId',
                                youtubeId: ytId,
                                title: 'YouTube Lesson: $ytId',
                                category: 'namaz',
                                duration: 'Full Lesson',
                                views: 'YouTube',
                                date: 'Online',
                                description: 'Islamic class video imported from YouTube.',
                              );
                              setDialogState(() {
                                selectedMap[ytId] = directVid;
                                customUrlCtrl.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.darkEmerald,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('+ Add', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // 3. Selection Summary / Select All / Clear Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${displayedVideos.length} Available Videos',
                          style: const TextStyle(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  for (final v in displayedVideos) {
                                    if (v.youtubeId.trim().isNotEmpty) {
                                      selectedMap[v.youtubeId.trim()] = v;
                                    }
                                  }
                                });
                              },
                              child: const Text('Select All',
                                  style: TextStyle(color: AppColors.brightGold, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedMap.clear();
                                });
                              },
                              child: const Text('Clear',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 4. Videos List
                  Expanded(
                    child: displayedVideos.isEmpty
                        ? const Center(
                            child: Text('No videos match your search.', style: TextStyle(color: Colors.white70)),
                          )
                        : ListView.separated(
                            itemCount: displayedVideos.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.borderEmerald, height: 1),
                            itemBuilder: (ctx, idx) {
                              final v = displayedVideos[idx];
                              final isChecked = selectedMap.containsKey(v.youtubeId.trim());

                              return CheckboxListTile(
                                activeColor: AppColors.primaryGold,
                                checkColor: AppColors.darkEmerald,
                                tileColor: isChecked ? AppColors.surfaceEmerald.withOpacity(0.35) : null,
                                dense: true,
                                value: isChecked,
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      selectedMap[v.youtubeId.trim()] = v;
                                    } else {
                                      selectedMap.remove(v.youtubeId.trim());
                                    }
                                  });
                                },
                                secondary: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: SizedBox(
                                    width: 52,
                                    height: 36,
                                    child: Image.network(
                                      v.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.white12),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  v.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${v.duration} • ${v.category}',
                                  style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10),
                                ),
                              );
                            },
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
                  onConfirmed(selectedMap.values.toList());
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkEmerald,
                ),
                child: Text('Done (${selectedMap.length} Videos)', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
