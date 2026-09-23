import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/location.dart';
import '../../core/theme.dart';
import 'stores_controller.dart';

/// Screen 07. The household's stores, and adding one.
///
/// The location is the store's own, pinned once by whoever adds it while
/// standing there (or near enough). Nobody's live position is stored — the
/// phone reads it once, the store keeps the coordinates, the reading is gone.
class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final _name = TextEditingController();
  Position2D? _pinned;
  bool _locating = false;
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pin() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _locating = true;
      _message = null;
    });
    final here = await LocationOnce.read();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _pinned = here;
      if (here == null) _message = l10n.storesLocationFailed;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _message = l10n.storesInvalid);
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref
          .read(storesControllerProvider)
          .add(name, lat: _pinned?.lat, lng: _pinned?.lng);
      if (!mounted) return;
      _name.clear();
      setState(() => _pinned = null);
      FocusScope.of(context).unfocus();
    } on OpenBasketException catch (e) {
      if (!mounted) return;
      setState(() => _message = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = l10n.commonSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _offerRemove(Store store) async {
    final l10n = AppLocalizations.of(context);
    final remove = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (final context) => CupertinoActionSheet(
        title: Text(l10n.storesRemoveConfirm(store.name)),
        message: Text(l10n.storesRemoveNote(store.name)),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.storesRemove),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.itemMarkCancel),
        ),
      ),
    );
    if (remove != true) return;
    try {
      await ref.read(storesControllerProvider).remove(store.id!);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonSomethingWentWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stores = ref.watch(storesProvider);
    final muted = theme.textTheme.bodySmall!.color!;

    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            Text(l10n.storesTitle, style: theme.textTheme.displayLarge),
            const SizedBox(height: 4),
            Text(l10n.storesBlurb, style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
            ...switch (stores) {
              AsyncData(:final value) when value.isEmpty => [
                Text(l10n.storesEmpty, style: theme.textTheme.bodySmall),
              ],
              AsyncData(:final value) => [
                for (final store in value)
                  _StoreRow(store: store, onTap: () => _offerRemove(store)),
              ],
              AsyncError() => [
                Text(l10n.commonOffline, style: theme.textTheme.bodySmall),
              ],
              _ => [const Center(child: CircularProgressIndicator())],
            },
            const SizedBox(height: 32),
            Text(l10n.storesAddTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Text(l10n.storesNameLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              decoration: InputDecoration(
                hintText: l10n.storesNameHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.storesLocationLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _locating ? null : _pin,
              icon: _locating
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(CupertinoIcons.location, size: 18),
              label: Text(l10n.storesUseLocation),
            ),
            const SizedBox(height: 8),
            Text(
              _pinned == null
                  ? l10n.storesLocationNote
                  : l10n.storesPinned(
                      _pinned!.lat.toStringAsFixed(4),
                      _pinned!.lng.toStringAsFixed(4),
                    ),
              style: OpenBasketText.meta(muted),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: OpenBasketText.meta(theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.storesSave),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.storesSkipNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.store, required this.onTap});

  final Store store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pinned = store.lat != null && store.lng != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    pinned ? l10n.storesHasLocation : l10n.storesNoLocation,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              pinned
                  ? CupertinoIcons.location_solid
                  : CupertinoIcons.location_slash,
              size: 18,
              color: theme.textTheme.bodySmall!.color,
            ),
          ],
        ),
      ),
    );
  }
}
