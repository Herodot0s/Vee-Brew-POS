// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mockAnalytics)
final mockAnalyticsProvider = MockAnalyticsProvider._();

final class MockAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalyticsSummary>,
          AnalyticsSummary,
          FutureOr<AnalyticsSummary>
        >
    with $FutureModifier<AnalyticsSummary>, $FutureProvider<AnalyticsSummary> {
  MockAnalyticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockAnalyticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockAnalyticsHash();

  @$internal
  @override
  $FutureProviderElement<AnalyticsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AnalyticsSummary> create(Ref ref) {
    return mockAnalytics(ref);
  }
}

String _$mockAnalyticsHash() => r'3d2fab164358f84e6613e95b4170451884402e37';
