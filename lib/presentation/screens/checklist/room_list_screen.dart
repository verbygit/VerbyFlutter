import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verby_flutter/presentation/providers/room_list_provider.dart';
import 'package:verby_flutter/presentation/screens/checklist/room_checklist_screen.dart';
import 'package:verby_flutter/utils/navigation/navigate.dart';

import '../../theme/colors.dart';
import '../depa_and_room/room_item.dart';

class RoomListScreen extends ConsumerStatefulWidget {
  const RoomListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return RoomListState();
  }
}

class RoomListState extends ConsumerState<RoomListScreen> {
  void filterSearchResults(String query) {
    ref.read(roomlistProvider.notifier).filterItems(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomlistProvider);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Detect left-to-right swipe (iOS back gesture)
        if (Platform.isIOS) {
          if (details.delta.dx > 5) {
            // Adjust sensitivity as needed
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MColors().darkGrey,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Text(
            "rooms".tr(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15.r),
          child: Column(
            children: [
              20.verticalSpace,
              SearchBar(
                hintText: 'Search room',
                leading: Icon(Icons.search),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                onChanged: filterSearchResults,
              ),
              20.verticalSpace,

              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(6.r),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: state.filterRooms?.length ?? 0,
                  itemBuilder: (context, index) {
                    final depa = state.filterRooms?[index];

                    return roomCheckListItem(
                      depa,
                      MColors().freshGreen,
                      () async {
                        HapticFeedback.heavyImpact();
                        await Future.delayed(Duration(milliseconds: 150));
                        if (depa != null) {
                          safeNavigateToScreen(
                            context,
                            RoomCheckListScreen(room: depa),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
