// Dart
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';

// Internal
import 'package:songtube/internal/models/songFile.dart';
import 'package:songtube/internal/models/videoFile.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/internal/services/playerService.dart';
import 'package:songtube/player/videoPlayer.dart';

// Packages
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';

// UI
import 'package:songtube/screens/mediaScreen/widgets/downloads/downloadsEmpty.dart';

class MediaDownloadTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ManagerProvider manager = Provider.of<ManagerProvider>(context);
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: manager.songFileList.isEmpty
        ? const MediaDownloadsEmpty()
        : ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: manager.songFileList.length,
            itemBuilder: (context, index) {
              SongFile song = manager.songFileList[index];
              return ListTile(
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color
                  ),
                ),
                subtitle: Text(
                  song.author,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.6)
                  ),
                ),
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage(
                      fadeInDuration: Duration(milliseconds: 200),
                      placeholder: MemoryImage(kTransparentImage),
                      image: FileImage(File(song.coverPath)),
                      fit: BoxFit.cover,
                    )
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(MdiIcons.dotsVertical, size: 18),
                  onPressed: () {

                  },
                ),
                onTap: () async {
                  if (song.downloadType == "Audio") {
                    if (!AudioService.running) {
                      await AudioService.start(
                        backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
                        androidNotificationChannelName: 'SongTube',
                        // Enable this if you want the Android service to exit the foreground state on pause.
                        //androidStopForegroundOnPause: true,
                        androidNotificationColor: 0xFF2196f3,
                        androidNotificationIcon: 'drawable/ic_stat_music_note',
                        androidEnableQueue: true,
                      );
                    }
                    await AudioService.updateQueue(manager.getCurrentMediaItemList());
                    await AudioService.playFromMediaId(index.toString());
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => 
                        AppVideoPlayer(VideoFile(
                          name: song.title,
                          path: song.path,
                        )))
                    );
                  }
                },
              );
            },
          )
    );
  }
}