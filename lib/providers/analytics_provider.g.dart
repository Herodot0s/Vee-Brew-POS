// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsSummary)
final analyticsSummaryProvider = AnalyticsSummaryProvider._();

final class AnalyticsSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalyticsSummary>,
          AnalyticsSummary,
          Stream<AnalyticsSummary>
        >
    with $FutureModifier<AnalyticsSummary>, $StreamProvider<AnalyticsSummary> {
  AnalyticsSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsSummaryHash();

  @$internal
  @override
  $StreamProviderElement<AnalyticsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AnalyticsSummary> create(Ref ref) {
    return analyticsSummary(ref);
  }
}

String _$analyticsSummaryHash() => r'e4c1d80011369c821446d6a9081e6beb38f0ad9f';
