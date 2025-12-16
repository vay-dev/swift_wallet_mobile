// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_notifiers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationNotifier)
const notificationProvider = NotificationNotifierProvider._();

final class NotificationNotifierProvider
    extends $NotifierProvider<NotificationNotifier, NotificationState> {
  const NotificationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationNotifierHash();

  @$internal
  @override
  NotificationNotifier create() => NotificationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationState>(value),
    );
  }
}

String _$notificationNotifierHash() =>
    r'aadb02531a49addeb3b61943380d01967793f19b';

abstract class _$NotificationNotifier extends $Notifier<NotificationState> {
  NotificationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NotificationState, NotificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationState, NotificationState>,
              NotificationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
