import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../constants/constants.dart';
import '../../../core/hive_helper/hive_helper.dart';
import '../../../datetime/date_time.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  static HomeCubit get(context) => BlocProvider.of(context);
  //===============================================================
  List todayHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};
  String startDate = '';
  TextEditingController textController = TextEditingController();
  //===============================================================
  changeCheckBox({required bool value, required int index}) {
    todayHabitList[index][1] = value;
    updateData();
    emit(ChangeCheckBoxState());
  }

  deleteFromHabitList({required int index}) {
    todayHabitList.removeAt(index);
    updateData();
    emit(ChangeCheckBoxState());
  }

  createNewHabit() {
    todayHabitList.add([textController.text, false]);
    updateData();
    emit(AddNewHabitState());
  }

  updateHabitTitle({required int index}) {
    todayHabitList[index][0] = textController.text.trim();
    updateData();
    emit(UpdateHabitTitleState());
  }

  //===============================================================

  void init() async {
    if (await HiveHelper.read(key: kCurrentHabitList) == null) {
      createDefaultData();
    } else {
      loadData();
    }
    startDate = await HiveHelper.read(key: kStartDate);
    updateData();
    emit(HomeInitialState());
  }

  void createDefaultData() {
    todayHabitList = [
      ['Run', false],
      ['Read', false],
    ];

    HiveHelper.write(key: kStartDate, value: todaysDateFormatted());
    emit(CreateDefaultDataState());
  }

  void loadData() async {
    if (await HiveHelper.read(key: todaysDateFormatted()) == null) {
      todayHabitList = await HiveHelper.read(key: kCurrentHabitList);
      for (int i = 0; i < todayHabitList.length; i++) {
        todayHabitList[i][1] = false;
      }
    } else {
      todayHabitList = await HiveHelper.read(key: todaysDateFormatted());
    }
    emit(LoadDataState());
  }

  void updateData() async {
    await HiveHelper.write(key: todaysDateFormatted(), value: todayHabitList);
    HiveHelper.write(key: kCurrentHabitList, value: todayHabitList);
    calculateHabitPercentages();
    loadHeatMap();

    emit(UpdateDataState());
  }

  void updateDatabase() {
    HiveHelper.write(key: todaysDateFormatted(), value: todayHabitList);
    HiveHelper.write(key: kCurrentHabitList, value: todayHabitList);
    calculateHabitPercentages();
    loadHeatMap();
  }

  void calculateHabitPercentages() async {
    int countCompleted = 0;
    for (int i = 0; i < todayHabitList.length; i++) {
      if (todayHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = todayHabitList.isEmpty ? '0.0' : (countCompleted / todayHabitList.length).toStringAsFixed(1);

    await HiveHelper.write(key: "PERCENTAGE_SUMMARY_${todaysDateFormatted()}", value: percent);
  }

  void loadHeatMap() async {
    DateTime startDate = createDateTimeObject(await HiveHelper.read(key: "START_DATE"));

    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        await HiveHelper.read(key: "PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );
      int year = startDate.add(Duration(days: i)).year;
      int month = startDate.add(Duration(days: i)).month;
      int day = startDate.add(Duration(days: i)).day;
      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }
}
