import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/constants/constants.dart';
import 'package:habit_tracker/core/hive_helper/hive_helper.dart';
import 'package:habit_tracker/view/home/component/habit_tile.dart';
import 'package:habit_tracker/view/home/component/month_summary.dart';
import 'package:habit_tracker/view/home/component/my_alert_box.dart';
import 'package:habit_tracker/view/home/component/my_fab.dart';
import 'package:habit_tracker/view/home/controller/home_cubit.dart';

import '../../core/router/router.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..init(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = HomeCubit.get(context);
          return Scaffold(
            floatingActionButton: MyFloatingActionButton(onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return MyAlertBox(
                      controller: cubit.textController,
                      hintText: 'hintText',
                      onSave: () {
                        cubit.createNewHabit();
                        FocusScope.of(context).unfocus();
                        MagicRouter.pop();
                        cubit.textController.clear();
                      },
                      onCancel: () {
                        cubit.textController.clear();
                        MagicRouter.pop();
                      },
                    );
                  });
            }),
            body: ListView(
              children: [
                MonthlySummary(
                  datasets: cubit.heatMapDataSet,
                  startDate: cubit.startDate,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cubit.todayHabitList.length,
                  itemBuilder: (context, index) {
                    return HabitTile(
                      habitName: cubit.todayHabitList[index][0],
                      habitCompleted: cubit.todayHabitList[index][1],
                      onChanged: (value) {
                        cubit.changeCheckBox(value: value!, index: index);
                      },
                      settingsTapped: (context) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              cubit.textController.text = cubit.todayHabitList[index][0];
                              return MyAlertBox(
                                controller: cubit.textController,
                                hintText: 'Edit title',
                                onSave: () {
                                  cubit.updateHabitTitle(index: index);
                                  FocusScope.of(context).unfocus();
                                  MagicRouter.pop();
                                  cubit.textController.clear();
                                },
                                onCancel: () {
                                  cubit.textController.clear();
                                  MagicRouter.pop();
                                },
                              );
                            });
                        cubit.textController.clear();
                      },
                      deleteTapped: (context) {
                        cubit.deleteFromHabitList(index: index);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
