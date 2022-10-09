part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeInitialState extends HomeState {}

class CreateDefaultDataState extends HomeState {}

class LoadDataState extends HomeState {}

class UpdateDataState extends HomeState {}

class ChangeCheckBoxState extends HomeState {}

class DeleteHabitState extends HomeState {}

class AddNewHabitState extends HomeState {}

class UpdateHabitTitleState extends HomeState {}
