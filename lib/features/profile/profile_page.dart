import '../../app/scrolling_page.dart';
import 'package:flutter/material.dart';
import '../../app/app_bootstrap.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import 'profile_editors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.services});
  final AppBootstrap services;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _restoring = false;
  void _report(bool saved, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? message
              : 'A mudança ficou nesta sessão, mas não foi salva no navegador.',
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    final result = await showDialog<UserProfile>(
      context: context,
      builder: (_) => ProfileEditor(
        initial: widget.services.userStore.state.profile,
        genres: widget.services.catalog.tracks.expand((t) => t.tags).toSet(),
      ),
    );
    if (result != null && mounted) {
      _report(
        await widget.services.userStore.updateProfile(result),
        'Perfil salvo.',
      );
    }
  }

  Future<void> _editPeriods() async {
    final result = await showDialog<PeriodSettings>(
      context: context,
      builder: (_) =>
          PeriodEditor(initial: widget.services.userStore.state.periods),
    );
    if (result != null && mounted) {
      _report(
        await widget.services.userStore.updatePeriods(result),
        'Períodos salvos.',
      );
    }
  }

  Future<void> _editPresentation() async {
    final result = await showDialog<DemoClockSettings>(
      context: context,
      builder: (_) => PresentationEditor(
        initial: widget.services.userStore.state.demoClock,
      ),
    );
    if (result != null && mounted) {
      _report(
        await widget.services.userStore.updateDemoClock(result),
        'Horário atualizado.',
      );
    }
  }

  Future<void> _restore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Restaurar demonstração?'),
        content: const Text(
          'A música será interrompida. Perfil, curtidas, coleções salvas, pesquisas, histórico, escolhas e horários do SoundWave voltarão ao início neste navegador. O catálogo permanece.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar restauração'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _restoring = true);
    final saved = await widget.services.playback.restoreDemo();
    if (!mounted) return;
    setState(() => _restoring = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Demonstração restaurada.'
              : 'Não foi possível concluir a restauração. Confira o aviso e tente novamente.',
        ),
      ),
    );
  }

  void _help() => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      scrollable: true,
      title: const Text('Sobre o SoundWave'),
      content: const Text(
        'Demonstração acadêmica em Flutter, com catálogo e dados locais.\n\n'
        'As recomendações ordenam suas escolhas por período do dia. Pausar e avançar a mesma seleção não somam novas escolhas.\n\n'
        'Os gêneros favoritos filtram Sugeridas na fila. Não há login, streaming comercial ou sincronização entre aparelhos.\n\n'
        'Áudios: 12 instrumentais originais sintetizados para o projeto, autoria SoundWave Demo, sem samples externos. Arte: ícones e gradientes locais.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar ajuda'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = widget.services.userStore.state;
    final periods = state.periods;
    final choices = state.contextCounts.values.fold(
      0,
      (sum, value) => sum + value,
    );
    return ScrollingPage(
      key: const PageStorageKey('profile-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text('Perfil', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        SoundWaveRadii.artwork,
                      ),
                      border: Border.all(color: SoundWaveColors.purple),
                      color: SoundWaveColors.elevated,
                    ),
                    child: Text(
                      state.profile.initials,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Editar perfil',
                    onPressed: _restoring ? null : _editProfile,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                state.profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (state.profile.handle.isNotEmpty)
                Text(
                  '@${state.profile.handle}',
                  style: const TextStyle(color: SoundWaveColors.secondary),
                ),
              const SizedBox(height: 16),
              Text(
                '${state.favoriteTrackIds.length} músicas curtidas · ${state.savedCollectionIds.length} coleções salvas',
                style: const TextStyle(color: SoundWaveColors.secondary),
              ),
              Text(
                '${state.history.length} execuções no histórico · $choices escolhas de contexto',
                style: const TextStyle(color: SoundWaveColors.secondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeading(title: 'PREFERÊNCIAS E APRESENTAÇÃO'),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Setting(
                title: 'Gêneros favoritos',
                subtitle: state.profile.favoriteGenres.isEmpty
                    ? 'Todos os estilos disponíveis'
                    : state.profile.favoriteGenres.join(', '),
                icon: Icons.explore_outlined,
                onTap: _restoring ? null : _editProfile,
              ),
              const Divider(),
              _Setting(
                title: 'Horários e contextos',
                subtitle:
                    'Manhã ${periods.morningStartHour}:00 · Tarde ${periods.afternoonStartHour}:00 · Noite ${periods.nightStartHour}:00',
                icon: Icons.schedule_rounded,
                onTap: _restoring ? null : _editPeriods,
              ),
              const Divider(),
              _Setting(
                title: 'Modo de apresentação',
                subtitle: state.demoClock.enabled
                    ? 'Ativo · horário fixo'
                    : 'Desativado · horário do computador',
                icon: Icons.slideshow_rounded,
                onTap: _restoring ? null : _editPresentation,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: _restoring ? null : _help,
          icon: const Icon(Icons.help_outline_rounded),
          label: const Text('Ajuda e créditos'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _restoring ? null : _restore,
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(_restoring ? 'Restaurando…' : 'Restaurar demonstração'),
        ),
      ],
    );
  }
}

class _Setting extends StatelessWidget {
  const _Setting({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
