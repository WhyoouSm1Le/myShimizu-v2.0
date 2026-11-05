import 'package:myshimizu/providers/storage_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:myshimizu/data/app_storage.dart';
import 'package:myshimizu/models/app_user.dart';

class AuthNotifier extends Notifier<AppUser?> {
  AppStorage get _storage => ref.read(appStorageProvider);

  @override
  AppUser? build() => ref.watch(appStorageProvider).readUser();

  AppUser? findAccount(String email) {
    for (final account in _storage.readAccounts()) {
      if (account.email.toLowerCase() == email.toLowerCase()) return account;
    }
    return null;
  }

  void login(AppUser user) {
    state = user;
    _storage.saveUser(user);
  }

  void register(AppUser account) {
    final next = [
      account,
      ..._storage
          .readAccounts()
          .where((a) => a.email.toLowerCase() != account.email.toLowerCase()),
    ];
    _storage.saveAccounts(next);
    login(account);
  }

  void logout() {
    state = null;
    _storage.saveUser(null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new); 