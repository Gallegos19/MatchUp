import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

enum NavigationTab { discovery, events, matches, chat, profile }

class NavigationState extends Equatable {
  final NavigationTab currentTab;
  final int currentIndex;

  const NavigationState({
    required this.currentTab,
    required this.currentIndex,
  });

  NavigationState copyWith({
    NavigationTab? currentTab,
    int? currentIndex,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [currentTab, currentIndex];
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(
    currentTab: NavigationTab.discovery,
    currentIndex: 0,
  ));

  void changeTab(NavigationTab tab) {
    final index = _getIndexFromTab(tab);
    emit(NavigationState(
      currentTab: tab,
      currentIndex: index,
    ));
  }

  void changeIndex(int index) {
    final tab = _getTabFromIndex(index);
    emit(NavigationState(
      currentTab: tab,
      currentIndex: index,
    ));
  }

  int _getIndexFromTab(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.discovery:
        return 0;
      case NavigationTab.events:
        return 1;
      case NavigationTab.matches:
        return 2;
      case NavigationTab.chat:
        return 3;
      case NavigationTab.profile:
        return 4;
    }
  }

  NavigationTab _getTabFromIndex(int index) {
    switch (index) {
      case 0:
        return NavigationTab.discovery;
      case 1:
        return NavigationTab.events;
      case 2:
        return NavigationTab.matches;
      case 3:
        return NavigationTab.chat;
      case 4:
        return NavigationTab.profile;
      default:
        return NavigationTab.discovery;
    }
  }
}