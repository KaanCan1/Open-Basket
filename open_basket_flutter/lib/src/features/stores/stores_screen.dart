import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_basket_client/open_basket_client.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/location.dart';
import '../../core/theme.dart';
import '../../shared/widgets/design.dart';
import 'stores_controller.dart';
import '../../core/failure_message.dart';

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
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _message = failureMessage(l10n, e));
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
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage(l10n, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ob = Ob.of(context);
    final stores = ref.watch(storesProvider);

    return ObScaffold(
      back: true,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: l10n.storesSave,
            busy: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.storesSkipNote,
            textAlign: TextAlign.center,
            style: OpenBasketText.meta(ob.meta).copyWith(fontSize: 12),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
          children: [
            ScreenTitle(l10n.storesAddTitle, subtitle: l10n.storesBlurb),
            const SizedBox(height: 22),
            SectionLabel(l10n.storesNameLabel),
            const SizedBox(height: 4),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              style: OpenBasketText.body(ob.onGround).copyWith(fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.storesNameHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: 22),
            SectionLabel(l10n.storesLocationLabel),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _locating
                  ? null
                  : () => _pinned == null
                        ? _pin()
                        : setState(() => _pinned = null),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: _pinned == null ? ob.faint : ob.onGround,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: _pinned == null ? null : ob.onGround,
                        borderRadius: BorderRadius.circular(8),
                        border: _pinned == null
                            ? Border.all(color: ob.faint, width: 1.5)
                            : null,
                      ),
                      child: _locating
                          ? Padding(
                              padding: const EdgeInsets.all(5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ob.onGround,
                              ),
                            )
                          : _pinned == null
                          ? null
                          : Icon(
                              CupertinoIcons.checkmark_alt,
                              size: 16,
                              color: ob.ground,
                            ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.storesUseLocation,
                            style: OpenBasketText.body(
                              ob.onGround,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _locating
                                ? l10n.storesLocating
                                : l10n.storesLocationNote,
                            style: OpenBasketText.meta(ob.meta),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_pinned != null) ...[
              const SizedBox(height: 12),
              _MapPlaceholder(lat: _pinned!.lat, lng: _pinned!.lng),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: OpenBasketText.meta(Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 28),
            ...switch (stores) {
              AsyncData(:final value) when value.isEmpty => [
                Text(l10n.storesEmpty, style: OpenBasketText.meta(ob.meta)),
              ],
              AsyncData(:final value) => [
                SectionLabel(l10n.storesSaved),
                const SizedBox(height: 6),
                for (final store in value)
                  _StoreRow(store: store, onTap: () => _offerRemove(store)),
              ],
              AsyncError() => [
                Text(l10n.commonOffline, style: OpenBasketText.meta(ob.meta)),
              ],
              _ => [const SkeletonList(rows: 2)],
            },
          ],
        ),
      ),
    );
  }
}

/// The pinned spot: a hatched tile with the pin and its coordinates. There
/// is no map tile behind it on purpose — the location is a number the
/// estimate uses, not a place anyone needs to look at.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final ob = Ob.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        height: 136,
        child: CustomPaint(
          painter: _HatchPainter(
            a: ob.tonal,
            b: ob.chip,
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: ob.onGround,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ob.ground, width: 3),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ob.glass,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                    style: OpenBasketText.mono(
                      color: ob.meta,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.a, required this.b});

  final Color a;
  final Color b;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = a);
    final stripe = Paint()
      ..color = b
      ..strokeWidth = 9;
    for (var x = -size.height; x < size.width + size.height; x += 18) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.a != a || old.b != b;
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.store, required this.onTap});

  final Store store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pinned = store.lat != null && store.lng != null;
    final ob = Ob.of(context);
    return ListRow(
      title: store.name,
      subtitle: pinned ? l10n.storesHasLocation : l10n.storesNoLocation,
      onTap: onTap,
      trailing: Icon(
        pinned ? CupertinoIcons.location_solid : CupertinoIcons.location_slash,
        size: 18,
        color: ob.meta,
      ),
    );
  }
}
