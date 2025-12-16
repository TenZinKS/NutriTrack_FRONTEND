part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, ready, failure }
enum SettingsAction { none, logout, deleteAccount }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final AuthUser user;
  final bool loggingOut;
  final bool deletingAccount;
  final String? message;
  final SettingsAction lastAction;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.user = AuthUser.empty,
    this.loggingOut = false,
    this.deletingAccount = false,
    this.message,
    this.lastAction = SettingsAction.none,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    AuthUser? user,
    bool? loggingOut,
    bool? deletingAccount,
    String? message,
    SettingsAction? lastAction,
  }) {
    return SettingsState(
      status: status ?? this.status,
      user: user ?? this.user,
      loggingOut: loggingOut ?? this.loggingOut,
      deletingAccount: deletingAccount ?? this.deletingAccount,
      message: message,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        loggingOut,
        deletingAccount,
        message,
        lastAction,
      ];
}
