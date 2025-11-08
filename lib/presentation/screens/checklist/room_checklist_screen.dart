import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';
import 'package:verby_flutter/presentation/providers/room_checlist_provider.dart';

import '../../theme/colors.dart';
import 'add_comment_pic_dialog.dart';

class RoomCheckListScreen extends ConsumerStatefulWidget {
  final DepaRestant room;

  // = DepaRestant(
  //   id: 1,
  //   name: "room1",
  //   category: 1,
  //   extra: 1,
  //   volunteer: 1,
  //   status: 1,
  // );

  const RoomCheckListScreen({super.key, required this.room});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return RoomCheckListState();
  }
}

class RoomCheckListState extends ConsumerState<RoomCheckListScreen> {
  Widget checkListItem({
    String name = "",
    void Function()? onClick,
    void Function(String, bool)? onCheckChange,
    bool isCheck = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 15.r),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onClick,
                child: Text(
                  name.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  onCheckChange!(name, !isCheck);
                },
                child: SvgPicture.asset(
                  isCheck ? "assets/svg/check.svg" : "assets/svg/minus.svg",
                  width: 24.r,
                  height: 24.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showAddCommentPicDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return const AddCommentAndPicDialog();
      },
    );
  }

  void onCheckChange(String name, bool value) {
    ref.read(roomChecklistProvider.notifier).checkItem(name, value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomChecklistProvider);
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (Platform.isIOS) {
          if (details.delta.dx > 5) {
            // Adjust sensitivity as needed
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: MColors().whiteSmoke2,
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
            widget.room.name ?? "room",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ),
        body: Column(
          children: [
            30.verticalSpace,
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(color: MColors().veryLightGray),
                ),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    children: [
                      checkListItem(
                        name: "general_cleanliness",
                        onClick: showAddCommentPicDialog,
                        onCheckChange: (name,value){
                          onCheckChange(name, value);
                        },
                        isCheck:
                            state.checkList?["general_cleanliness"] ?? true,
                      ),
                      Divider(color: MColors().veryLightGray2, thickness: 1.r),

                      checkListItem(
                        name: "sheet_fold",
                        onClick: showAddCommentPicDialog,
                        onCheckChange: (name,value){
                          onCheckChange(name, value);
                        },
                        isCheck: state.checkList?["sheet_fold"] ?? true,
                      ),
                      Divider(color: MColors().veryLightGray2, thickness: 1.r),
                      checkListItem(
                        name: "towels",
                        onClick: showAddCommentPicDialog,
                        onCheckChange: (name,value){
                          onCheckChange(name, value);
                        },
                        isCheck: state.checkList?["towels"] ?? true,
                      ),
                      Divider(color: MColors().veryLightGray2, thickness: 1.r),
                      checkListItem(
                        name: "WC",
                        onClick: showAddCommentPicDialog,
                        onCheckChange: (name,value){
                          onCheckChange(name, value);
                        },
                        isCheck: state.checkList?["WC"] ?? true,
                      ),
                      Divider(color: MColors().veryLightGray2, thickness: 1.r),
                      checkListItem(
                        name: "missing_item",
                        onClick: showAddCommentPicDialog,
                        onCheckChange: (name,value){
                          onCheckChange(name, value);
                        },
                        isCheck: state.checkList?["missing_item"] ?? true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            30.verticalSpace,

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.r),

              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () {},

                  borderRadius: BorderRadius.circular(15.r),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.r),

                      child: Center(
                        child: Text(
                          "submit_button".tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
