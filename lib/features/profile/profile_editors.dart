import 'package:flutter/material.dart' hide DayPeriod;
import '../../core/models/listening_context.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/soundwave_theme.dart';

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key, required this.initial, required this.genres});
  final UserProfile initial;
  final Iterable<String> genres;
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial.name);
  late final _handle = TextEditingController(text: widget.initial.handle);
  late final _genres = {...widget.initial.favoriteGenres};
  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Editar perfil'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const ValueKey('profile-name'),
              controller: _name,
              maxLength: 50,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe seu nome.'
                  : value.trim().length > 50
                  ? 'Use até 50 caracteres.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('profile-handle'),
              controller: _handle,
              maxLength: 30,
              validator: (value) => (value?.trim().length ?? 0) > 30
                  ? 'Use até 30 caracteres.'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Identificação',
                prefixText: '@',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Gêneros favoritos'),
            const SizedBox(height: 8),
            const Text(
              'Filtram Sugeridas na fila. Sem seleção, todos os estilos ficam disponíveis.',
              style: TextStyle(color: SoundWaveColors.secondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final genre in {
                  ...widget.genres,
                  ...widget.initial.favoriteGenres,
                })
                  FilterChip(
                    label: Text(genre),
                    selected: _genres.contains(genre),
                    onSelected: (selected) => setState(() {
                      selected ? _genres.add(genre) : _genres.remove(genre);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(
              context,
              UserProfile(
                name: _name.text,
                handle: _handle.text,
                favoriteGenres: _genres,
              ),
            );
          }
        },
        child: const Text('Salvar perfil'),
      ),
    ],
  );
}

class PeriodEditor extends StatefulWidget {
  const PeriodEditor({super.key, required this.initial});
  final PeriodSettings initial;
  @override
  State<PeriodEditor> createState() => _PeriodEditorState();
}

class _PeriodEditorState extends State<PeriodEditor> {
  final _form = GlobalKey<FormState>();
  late final _hours = [
    for (final value in [
      widget.initial.morningStartHour,
      widget.initial.afternoonStartHour,
      widget.initial.nightStartHour,
    ])
      TextEditingController(text: '$value'),
  ];
  late final _pairs = {
    for (final entry in widget.initial.initialContexts.entries)
      entry.key: [...entry.value],
  };
  String? _error;
  @override
  void dispose() {
    for (final c in _hours) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    try {
      Navigator.pop(
        context,
        PeriodSettings(
          morningStartHour: int.parse(_hours[0].text.trim()),
          afternoonStartHour: int.parse(_hours[1].text.trim()),
          nightStartHour: int.parse(_hours[2].text.trim()),
          initialContexts: _pairs,
        ),
      );
    } on ArgumentError {
      setState(
        () => _error =
            'Use horários em ordem crescente e dois contextos diferentes em cada período.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Horários e contextos'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Defina a hora inicial de cada período (0 a 23). A madrugada pertence à noite.',
              style: TextStyle(color: SoundWaveColors.secondary),
            ),
            for (final (index, period) in DayPeriod.values.indexed) ...[
              const SizedBox(height: 20),
              TextFormField(
                key: ValueKey('period-${period.id}'),
                controller: _hours[index],
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Início da ${period.label}',
                  suffixText: ':00',
                  counterText: '',
                ),
                validator: (value) {
                  final n = int.tryParse(value?.trim() ?? '');
                  return n == null || n < 0 || n > 23
                      ? 'Use uma hora entre 0 e 23.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              for (var slot = 0; slot < 2; slot++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<ListeningContext>(
                    key: ValueKey('pair-${period.id}-$slot'),
                    initialValue: _pairs[period]![slot],
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '${slot + 1}º contexto — ${period.label}',
                    ),
                    items: [
                      for (final value in ListeningContext.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _pairs[period]![slot] = value);
                      }
                    },
                  ),
                ),
            ],
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: SoundWaveColors.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _save, child: const Text('Salvar períodos')),
    ],
  );
}

class PresentationEditor extends StatefulWidget {
  const PresentationEditor({super.key, required this.initial});
  final DemoClockSettings initial;
  @override
  State<PresentationEditor> createState() => _PresentationEditorState();
}

class _PresentationEditorState extends State<PresentationEditor> {
  final _form = GlobalKey<FormState>();
  late bool _enabled = widget.initial.enabled;
  late final _hour = TextEditingController(
    text: '${widget.initial.minuteOfDay ~/ 60}',
  );
  late final _minute = TextEditingController(
    text: '${widget.initial.minuteOfDay % 60}',
  );
  @override
  void dispose() {
    _hour.dispose();
    _minute.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Modo de apresentação'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Usar horário simulado'),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
            const Text(
              'O horário fica fixo até você alterá-lo. A data continua sendo a do computador.',
              style: TextStyle(color: SoundWaveColors.secondary),
            ),
            const SizedBox(height: 16),
            for (final (controller, key, label, max) in [
              (_hour, 'demo-hour', 'Hora (0–23)', 23),
              (_minute, 'demo-minute', 'Minuto (0–59)', 59),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  key: ValueKey(key),
                  controller: controller,
                  enabled: _enabled,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  decoration: InputDecoration(
                    labelText: label,
                    counterText: '',
                  ),
                  validator: (value) {
                    final number = int.tryParse(value?.trim() ?? '');
                    return _enabled &&
                            (number == null || number < 0 || number > max)
                        ? 'Valor entre 0 e $max.'
                        : null;
                  },
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            DemoClockSettings(
              enabled: _enabled,
              minuteOfDay: _enabled
                  ? int.parse(_hour.text.trim()) * 60 +
                        int.parse(_minute.text.trim())
                  : widget.initial.minuteOfDay,
            ),
          );
        },
        child: const Text('Salvar apresentação'),
      ),
    ],
  );
}
