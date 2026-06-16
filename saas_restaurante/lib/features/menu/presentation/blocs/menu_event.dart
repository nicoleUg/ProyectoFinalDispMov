import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class LoadMenuRequested extends MenuEvent {}

class CategorySelected extends MenuEvent {
  final String categoryId;
  const CategorySelected(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}