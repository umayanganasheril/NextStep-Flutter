import 'package:flutter/material.dart';
import '../models/internship_model.dart';
import '../services/job_service.dart';

class FilterModel {
  final String location; // 'Sri Lanka', 'Remote', 'Both'
  final String type; // 'Paid', 'Any'
  final String level; // 'Entry-Level', 'Any'
  final String sort; // 'Top Rated', 'Most Recent', 'Best Match'

  const FilterModel({
    this.location = 'Both',
    this.type = 'Any',
    this.level = 'Any',
    this.sort = 'Most Recent',
  });

  FilterModel copyWith({
    String? location,
    String? type,
    String? level,
    String? sort,
  }) {
    return FilterModel(
      location: location ?? this.location,
      type: type ?? this.type,
      level: level ?? this.level,
      sort: sort ?? this.sort,
    );
  }
}

class InternshipProvider with ChangeNotifier {
  final JobService _jobService = JobService();

  bool _isLoading = false;
  List<InternshipModel> _internships = [];
  List<InternshipModel> _filteredInternships = [];
  FilterModel _selectedFilters = const FilterModel();
  String _searchQuery = '';
  String? _errorMessage;
  String? _infoMessage;
  DataSource? _dataSource;
  DateTime? _lastFetched;
  final bool _hasMore = false;

  // Getters
  bool get isLoading => _isLoading;
  List<InternshipModel> get internships => _filteredInternships;
  FilterModel get selectedFilters => _selectedFilters;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  DataSource? get dataSource => _dataSource;
  DateTime? get lastFetched => _lastFetched;
  bool get hasMore => _hasMore;

  /// Get recommended internships (sorted by skill match)
  List<InternshipModel> getRecommended(List<String> userSkills) {
    if (userSkills.isEmpty) return _filteredInternships.take(5).toList();
    final sorted = List<InternshipModel>.from(_filteredInternships)
      ..sort((a, b) => b
          .getMatchPercentage(userSkills)
          .compareTo(a.getMatchPercentage(userSkills)));
    return sorted.where((i) => i.getMatchPercentage(userSkills) > 0).take(5).toList();
  }

  /// Fetch internships from API/cache
  Future<void> fetchInternships({bool forceRefresh = false, List<InternshipModel>? aiMockInternships}) async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final result = await _jobService.fetchInternships(
        forceRefresh: forceRefresh,
        aiMockInternships: aiMockInternships,
      );
      _internships = result.internships;
      _dataSource = result.source;
      _lastFetched = DateTime.now();

      if (result.source == DataSource.cache) {
        _infoMessage = result.message;
      } else if (result.source == DataSource.mock) {
        _infoMessage = result.message;
        if (result.error != null) {
          _errorMessage = result.error;
        }
      }

      _applyFiltersInternal();
    } catch (e) {
      _errorMessage = e.toString();
      // Fallback to mock if everything fails
      if (_internships.isEmpty) {
        if (aiMockInternships != null && aiMockInternships.isNotEmpty) {
          _internships = aiMockInternships;
          _dataSource = DataSource.mock;
          _infoMessage = 'Showing AI-recommended internships for you';
        } else {
          _internships = InternshipModel.getMockInternships();
          _dataSource = DataSource.mock;
          _infoMessage = 'Showing sample internships';
        }
        _applyFiltersInternal();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update filters
  void updateFilters(FilterModel filters) {
    _selectedFilters = filters;
    _applyFiltersInternal();
    notifyListeners();
  }

  /// Update search query
  void searchInternships(String query) {
    _searchQuery = query;
    _applyFiltersInternal();
    notifyListeners();
  }

  /// Apply all filters, search, and sort internally
  void _applyFiltersInternal() {
    var results = List<InternshipModel>.from(_internships);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((i) {
        return i.jobTitle.toLowerCase().contains(q) ||
            i.companyName.toLowerCase().contains(q) ||
            i.location.toLowerCase().contains(q) ||
            i.requiredSkills.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    // Location filter
    switch (_selectedFilters.location) {
      case 'Sri Lanka':
        results = results
            .where((i) =>
                i.location.toLowerCase().contains('sri lanka') ||
                i.location.toLowerCase().contains('colombo'))
            .toList();
        break;
      case 'Remote':
        results = results.where((i) => i.isRemote).toList();
        break;
      // 'Both' — no filter
    }

    // Type filter
    if (_selectedFilters.type == 'Paid') {
      results = results.where((i) => i.isPaid).toList();
    }

    // Level filter
    if (_selectedFilters.level == 'Entry-Level') {
      results = results.where((i) {
        final titleLower = i.jobTitle.toLowerCase();
        final descLower = i.jobDescription.toLowerCase();
        return titleLower.contains('intern') ||
            titleLower.contains('junior') ||
            titleLower.contains('entry') ||
            descLower.contains('entry level') ||
            descLower.contains('entry-level') ||
            i.employmentType == 'INTERN';
      }).toList();
    }

    // Sort
    switch (_selectedFilters.sort) {
      case 'Most Recent':
        results.sort((a, b) => b.postedDate.compareTo(a.postedDate));
        break;
      case 'Top Rated':
        // Sort by company presence + skill count
        results.sort((a, b) {
          final aScore = a.requiredSkills.length + (a.isPaid ? 5 : 0);
          final bScore = b.requiredSkills.length + (b.isPaid ? 5 : 0);
          return bScore.compareTo(aScore);
        });
        break;
      case 'Best Match':
        // Will be re-sorted when displayed with user skills
        break;
    }

    _filteredInternships = results;
  }

  /// Sort by best match with provided user skills
  List<InternshipModel> getSortedByMatch(List<String> userSkills) {
    if (_selectedFilters.sort != 'Best Match' || userSkills.isEmpty) {
      return _filteredInternships;
    }
    final sorted = List<InternshipModel>.from(_filteredInternships)
      ..sort((a, b) => b
          .getMatchPercentage(userSkills)
          .compareTo(a.getMatchPercentage(userSkills)));
    return sorted;
  }

  /// Calculate match score between user skills and job skills
  static double getMatchScore(
      List<String> userSkills, List<String> jobSkills) {
    if (jobSkills.isEmpty || userSkills.isEmpty) return 0;
    final userLower = userSkills.map((s) => s.toLowerCase()).toSet();
    final matched =
        jobSkills.where((s) => userLower.contains(s.toLowerCase())).length;
    return (matched / jobSkills.length) * 100;
  }

  /// Clear all filters
  void clearFilters() {
    _selectedFilters = const FilterModel();
    _searchQuery = '';
    _applyFiltersInternal();
    notifyListeners();
  }
}
