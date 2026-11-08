import '../models/user_state.dart';
import 'local_state_storage.dart';
import 'user_state_codec.dart';

class LoadedUserState {
  const LoadedUserState(this.state, {this.warning});
  final UserState state;
  final String? warning;
}

class UserStateRepository {
  UserStateRepository({required this.storage, required this.codec});

  final LocalStateStorage storage;
  final UserStateCodec codec;
  Future<void> _pending = Future.value();

  Future<LoadedUserState> load() async {
    String? source;
    try {
      source = await storage.read();
    } catch (_) {
      return LoadedUserState(
        UserState(),
        warning:
            'Armazenamento indisponível. As mudanças podem não ser salvas.',
      );
    }
    if (source == null) return LoadedUserState(UserState());
    try {
      final decoded = codec.decode(source);
      return LoadedUserState(
        decoded.state,
        warning: decoded.repaired
            ? 'Alguns dados locais inválidos foram recuperados com valores seguros.'
            : null,
      );
    } on FormatException {
      return LoadedUserState(
        UserState(),
        warning:
            'Dados locais incompatíveis. A sessão usará os valores iniciais.',
      );
    }
  }

  Future<void> save(UserState state) {
    final serialized = codec.encode(state);
    return _enqueue(() => storage.write(serialized));
  }

  Future<void> clear() => _enqueue(storage.remove);

  Future<void> _enqueue(Future<void> Function() operation) {
    // Uma falha anterior não bloqueia tentativas posteriores nem permite ultrapassagem.
    final next = _pending.then(
      (_) => operation(),
      onError: (Object error, StackTrace stack) => operation(),
    );
    _pending = next;
    return next;
  }
}
