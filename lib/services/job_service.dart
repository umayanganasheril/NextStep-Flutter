import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/internship_model.dart';

class JobService {
  // ─── Remotive API (FREE, no key needed) ───
  static const String _remotiveUrl =
      'https://remotive.com/api/remote-jobs';

  // ─── JSearch API (optional, needs RapidAPI subscription) ───
  static const String _jsearchUrl =
      'https://jsearch.p.rapidapi.com/search';
  static const String _apiKey =
      '4c4c4bb69emshc7f3155e2e8b088p1ef342jsnb350dde61953';
  static const String _apiHost = 'jsearch.p.rapidapi.com';

  // Cache
  static const String _cacheKey = 'cached_internships_v2';
  static const String _cacheTimestampKey = 'cache_timestamp_v2';
  static const Duration _cacheDuration = Duration(hours: 24);
  static const Duration _timeout = Duration(seconds: 15);

  /// Fetch internships — tries Remotive first (always free), then JSearch
  Future<JobServiceResult> fetchInternships(
      {bool forceRefresh = false, List<InternshipModel>? aiMockInternships}) async {
    // 1. Check cache first
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) {
        dev.log('JobService: Loaded ${cached.length} from cache');
        return JobServiceResult(
          internships: cached,
          source: DataSource.cache,
          message: 'Showing saved results (${cached.length} jobs)',
        );
      }
    } else {
      await clearCache();
    }

    // 2. Try Remotive API first (free, always works)
    try {
      dev.log('JobService: Fetching from Remotive API...');
      final allJobs = <InternshipModel>[];

      // Fetch software-dev jobs
      final softwareJobs = await _fetchFromRemotive('software-dev');
      allJobs.addAll(softwareJobs);
      dev.log('JobService: Remotive software-dev: ${softwareJobs.length} jobs');

      // Fetch QA jobs
      final qaJobs = await _fetchFromRemotive('qa');
      allJobs.addAll(qaJobs);
      dev.log('JobService: Remotive QA: ${qaJobs.length} jobs');

      // Fetch data jobs
      final dataJobs = await _fetchFromRemotive('data');
      allJobs.addAll(dataJobs);
      dev.log('JobService: Remotive data: ${dataJobs.length} jobs');

      if (allJobs.isNotEmpty) {
        // Deduplicate
        final uniqueMap = <String, InternshipModel>{};
        for (final job in allJobs) {
          uniqueMap[job.jobId] = job;
        }
        final uniqueList = uniqueMap.values.toList();

        // Sort by date
        uniqueList.sort((a, b) => b.postedDate.compareTo(a.postedDate));

        // Cache
        await _saveToCache(uniqueList);

        dev.log('JobService: Total unique jobs: ${uniqueList.length}');
        return JobServiceResult(
          internships: uniqueList,
          source: DataSource.api,
          message: '${uniqueList.length} real jobs loaded',
        );
      }
    } catch (e) {
      dev.log('JobService: Remotive failed: $e');
    }

    // 3. Try JSearch as backup
    try {
      dev.log('JobService: Trying JSearch API...');
      final jsearchJobs = <InternshipModel>[];

      for (final query in [
        'IT internship Sri Lanka',
        'remote software internship'
      ]) {
        try {
          final results = await _fetchFromJSearch(query);
          jsearchJobs.addAll(results);
        } catch (e) {
          dev.log('JobService: JSearch query "$query" failed: $e');
        }
      }

      if (jsearchJobs.isNotEmpty) {
        final uniqueMap = <String, InternshipModel>{};
        for (final job in jsearchJobs) {
          uniqueMap[job.jobId] = job;
        }
        final uniqueList = uniqueMap.values.toList();
        uniqueList.sort((a, b) => b.postedDate.compareTo(a.postedDate));
        await _saveToCache(uniqueList);

        return JobServiceResult(
          internships: uniqueList,
          source: DataSource.api,
          message: '${uniqueList.length} jobs loaded from JSearch',
        );
      }
    } catch (e) {
      dev.log('JobService: JSearch also failed: $e');
    }

    // 4. Last resort: try expired cache
    final expired = await _loadFromCache(ignoreExpiry: true);
    if (expired != null && expired.isNotEmpty) {
      return JobServiceResult(
        internships: expired,
        source: DataSource.cache,
        message: 'Showing saved results (offline)',
      );
    }

    // 5. Absolute fallback: curated mock data or AI generated
    dev.log('JobService: Using mock fallback');
    if (aiMockInternships != null && aiMockInternships.isNotEmpty) {
      return JobServiceResult(
        internships: aiMockInternships,
        source: DataSource.mock,
        message: 'Showing AI-recommended internships for you',
      );
    }
    return JobServiceResult(
      internships: InternshipModel.getMockInternships(),
      source: DataSource.mock,
      message: 'Showing sample internships',
    );
  }

  /// Fetch from Remotive API (completely free)
  Future<List<InternshipModel>> _fetchFromRemotive(String category) async {
    final uri = Uri.parse('$_remotiveUrl?category=$category&limit=20');

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jobs = data['jobs'] as List<dynamic>? ?? [];
      return jobs
          .map((job) => InternshipModel.fromRemotiveJson(
              job as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Remotive API returned ${response.statusCode}');
    }
  }

  /// Fetch from JSearch API (requires RapidAPI subscription)
  Future<List<InternshipModel>> _fetchFromJSearch(String query) async {
    final uri = Uri.parse(_jsearchUrl).replace(
      queryParameters: {
        'query': query,
        'num_pages': '2',
        'date_posted': 'month',
      },
    );

    final response = await http.get(uri, headers: {
      'X-RapidAPI-Key': _apiKey,
      'X-RapidAPI-Host': _apiHost,
    }).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jobs = data['data'] as List<dynamic>? ?? [];
      return jobs
          .map((job) => InternshipModel.fromJSearchJson(
              job as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 403) {
      throw Exception('JSearch: Not subscribed (subscribe at rapidapi.com)');
    } else if (response.statusCode == 429) {
      throw Exception('JSearch: Rate limit reached');
    } else {
      throw Exception('JSearch: Status ${response.statusCode}');
    }
  }

  /// Save to cache
  Future<void> _saveToCache(List<InternshipModel> internships) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = InternshipModel.encodeList(internships);
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setString(
          _cacheTimestampKey, DateTime.now().toIso8601String());
      dev.log('JobService: Cached ${internships.length} jobs');
    } catch (_) {}
  }

  /// Load from cache
  Future<List<InternshipModel>?> _loadFromCache(
      {bool ignoreExpiry = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      final timestampStr = prefs.getString(_cacheTimestampKey);
      if (jsonString == null || timestampStr == null) return null;

      if (!ignoreExpiry) {
        final timestamp = DateTime.parse(timestampStr);
        if (DateTime.now().difference(timestamp) > _cacheDuration) {
          return null;
        }
      }
      return InternshipModel.decodeList(jsonString);
    } catch (_) {
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }
}

class JobServiceResult {
  final List<InternshipModel> internships;
  final DataSource source;
  final String message;
  final String? error;

  JobServiceResult({
    required this.internships,
    required this.source,
    required this.message,
    this.error,
  });
}

enum DataSource { api, cache, mock }
