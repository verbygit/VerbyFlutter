import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:verby_flutter/presentation/providers/volunteer_screen_state_provider.dart';
import '../theme/colors.dart';

class VolunteerSelectionScreen extends ConsumerStatefulWidget {

  const VolunteerSelectionScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _VolunteerSelectionScreenState();
  }
}

class _VolunteerSelectionScreenState
    extends ConsumerState<VolunteerSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(volunteerScreenStateProvider.notifier).getEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    ref.read(volunteerScreenStateProvider.notifier).filterItems(query);
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(volunteerScreenStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                20.verticalSpace,
                Container(
                  color: MColors().darkGrey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.r),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "enter_your_name".tr(),
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20.r,
                          color: Colors.white,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 20.r,
                                  color: Colors.white,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.r,
                          horizontal: 16.r,
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),

                Flexible(
                  child: ListView.builder(
                    itemCount: state.filterList?.length ?? 0,
                    itemBuilder: (context, index) {
                      final itemName = state.filterList?[index].fullname ?? "";
                      return Padding(
                        padding: EdgeInsets.all(10.r),
                        child: ListTile(
                          onTap: () {
                            print("select item");
                            ref
                                .read(volunteerScreenStateProvider.notifier)
                                .selectItem(index);
                          },
                          selected: state.selectedIndex == index,
                          selectedTileColor: MColors().selectedBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10.r),
                          ),
                          tileColor: MColors().whiteSmoke,
                          contentPadding: EdgeInsets.all(16.r),
                          title: Center(
                            child: Text(
                              itemName,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.sp,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {

                    Navigator.pop(
                      context,
                      state.filterList?[state.selectedIndex].id,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    color: MColors().freshGreen,
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Center(
                        child: Text(
                          "select".tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.isLoading)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black38,
                child: Center(
                  child: Lottie.asset(
                    'assets/animation/loading_animation.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
