import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:jupyter_health/data/data_source/api_data_source_impl.dart';
import 'package:jupyter_health/data/utils/api_helpers.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation_page.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

@LazySingleton(as: ApiRepository)
class ApiRepositoryImpl implements ApiRepository {
  static const _pageSize = 50;
  static const _observationsFrom = '2025-01-01';

  final ApiDataSource _apiDataSource;
  ApiRepositoryImpl(this._apiDataSource);

  @override
  Future<Either<Failure, User>> getUser() => safeApiCall(
    apiCall: () async {
      final response = await _apiDataSource.getUser();
      return response.data;
    },
  );

  @override
  Future<Either<Failure, ObservationPage>> getObservations({
    required ObservationType type,
    Map<String, String>? nextUrls,
  }) {
    return safeApiCall(
      apiCall: () async {
        final sources = nextUrls != null
            ? Map<String, String?>.of(nextUrls)
            : <String, String?>{
                for (final code in type.fhirSearchCodes) code: null,
              };
        if (sources.isEmpty) return const ObservationPage();

        return _fetchFeeds(sources);
      },
    );
  }

  Future<ObservationPage> _fetchFeeds(Map<String, String?> sources) async {
    ObservationPage? page;
    Object? lastError;
    var succeeded = false;

    for (final entry in sources.entries) {
      try {
        page = _mergePages(
          page,
          await _fetchUntilObservations(code: entry.key, nextUrl: entry.value),
        );
        succeeded = true;
      } catch (error) {
        lastError = error;
        final url = entry.value;
        if (url != null) {
          page = _mergePages(page, ObservationPage(nextUrls: {entry.key: url}));
        }
      }
    }

    if (!succeeded && lastError != null) throw lastError;
    return page ?? const ObservationPage();
  }

  Future<ObservationPage> _fetchUntilObservations({
    required String code,
    String? nextUrl,
  }) async {
    var url = nextUrl;
    var useSearch = nextUrl == null;

    while (true) {
      final response = useSearch
          ? await _apiDataSource.getObservations(
              code: code,
              date: _observationDateRange,
              count: _pageSize,
            )
          : await _apiDataSource.getObservationsByUrl(url!);
      useSearch = false;

      final page = response.data.toPage(code: code);
      url = page.nextUrls[code];
      if (page.observations.isNotEmpty || url == null) return page;
    }
  }

  ObservationPage _mergePages(
    ObservationPage? current,
    ObservationPage incoming,
  ) {
    if (current == null) return incoming;

    final existingIds = {for (final item in current.observations) item.id};
    return ObservationPage(
      observations: [
        ...current.observations,
        for (final item in incoming.observations)
          if (!existingIds.contains(item.id)) item,
      ],
      nextUrls: {...current.nextUrls, ...incoming.nextUrls},
    );
  }

  List<String> get _observationDateRange {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    return ['ge$_observationsFrom', 'le$today'];
  }
}
