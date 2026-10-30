import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';

class HomeController extends ChangeNotifier {
  final AuthRepository authRepository;
  final LocalStorage storage;
  HomeController({required this.authRepository, required this.storage});

  final pageController = PageController();
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  Future<void> logout({required Function() onSuccess}) async {
    await authRepository.logout();

    storage.remove(LocalStorageKeys.auth.name());
    onSuccess();
  }
}
