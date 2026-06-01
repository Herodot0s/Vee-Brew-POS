// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalyticsState)
final analyticsStateProvider = AnalyticsStateProvider._();

final class AnalyticsStateProvider
    extends $NotifierProvider<AnalyticsState, TimeRange> {
  AnalyticsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsStateHash();

  @$internal
  @override
  AnalyticsState create() => AnalyticsState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeRange>(value),
    );
  }
}

String _$analyticsStateHash() => r'b93008357121ed437f0f9919b2f6fdb62e567dfc';

abstract class _$AnalyticsState extends $Notifier<TimeRange> {
  TimeRange build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TimeRange, TimeRange>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimeRange, TimeRange>,
              TimeRange,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
