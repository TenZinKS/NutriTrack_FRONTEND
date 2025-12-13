import '../../domain/entities/user_macros.dart';

abstract class MacrosEvent {}

class LoadMacrosEvent extends MacrosEvent {}

class MacrosChangedEvent extends MacrosEvent {
  final UserMacros macros;
  MacrosChangedEvent(this.macros);
}

class MacrosStreamErrorEvent extends MacrosEvent {
  final String message;
  MacrosStreamErrorEvent(this.message);
}

class SubmitMacrosUpdateEvent extends MacrosEvent {
  final UserMacros macros;
  SubmitMacrosUpdateEvent(this.macros);
}
