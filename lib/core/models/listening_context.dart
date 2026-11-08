enum ListeningContext {
  study('estudo', 'Estudar'),
  workout('treino', 'Treinar'),
  work('trabalho', 'Trabalhar'),
  travel('viagem', 'Viajar'),
  reading('leitura', 'Leitura'),
  sleep('dormir', 'Dormir');

  const ListeningContext(this.id, this.label);
  final String id;
  final String label;

  static ListeningContext? fromId(Object? id) {
    for (final value in values) {
      if (value.id == id) return value;
    }
    return null;
  }
}

enum DayPeriod {
  morning('manha', 'manhã'),
  afternoon('tarde', 'tarde'),
  night('noite', 'noite');

  const DayPeriod(this.id, this.label);
  final String id;
  final String label;

  static DayPeriod? fromId(Object? id) {
    for (final value in values) {
      if (value.id == id) return value;
    }
    return null;
  }
}
