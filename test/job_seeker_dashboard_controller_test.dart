import 'package:flutter_test/flutter_test.dart';

// ─── Fake job model for testing ───

class FakeJob {
  final String id;
  final String title;
  final String companyName;
  final String mainFieldId;
  final String mainFieldName;
  final String jobType;
  final String workMode;
  final String location;
  final String description;

  FakeJob({
    required this.id,
    required this.title,
    required this.companyName,
    required this.mainFieldId,
    required this.mainFieldName,
    required this.jobType,
    required this.workMode,
    required this.location,
    required this.description,
  });
}

// ─── Pure logic mirroring JobSeekerDashboardController.applyFilters ───

List<FakeJob> applyFilters({
  required List<FakeJob> allJobs,
  required String selectedMainFieldId,
  required String selectedJobType,
  required String selectedWorkMode,
  required String searchQuery,
}) {
  Iterable<FakeJob> results = allJobs;

  if (selectedMainFieldId != 'all') {
    results = results.where((job) => job.mainFieldId == selectedMainFieldId);
  }

  if (selectedJobType != 'all') {
    results = results.where((job) => job.jobType == selectedJobType);
  }

  if (selectedWorkMode != 'all') {
    results = results.where((job) => job.workMode == selectedWorkMode);
  }

  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    results = results.where((job) {
      return job.title.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query) ||
          job.mainFieldName.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query);
    });
  }

  return results.toList();
}

// ─── Fixtures ───

final jobs = [
  FakeJob(
    id: '1',
    title: 'Flutter Developer',
    companyName: 'Tech Corp',
    mainFieldId: 'field_1',
    mainFieldName: 'Mobile Development',
    jobType: 'FullTime',
    workMode: 'Remote',
    location: 'Cairo',
    description: 'Build mobile apps with Flutter',
  ),
  FakeJob(
    id: '2',
    title: 'Backend Engineer',
    companyName: 'Data Systems',
    mainFieldId: 'field_2',
    mainFieldName: 'Backend',
    jobType: 'FullTime',
    workMode: 'Onsite',
    location: 'Alexandria',
    description: 'Design and build APIs',
  ),
  FakeJob(
    id: '3',
    title: 'UI/UX Designer',
    companyName: 'Creative Studio',
    mainFieldId: 'field_3',
    mainFieldName: 'Design',
    jobType: 'PartTime',
    workMode: 'Remote',
    location: 'Remote',
    description: 'Create user interfaces',
  ),
  FakeJob(
    id: '4',
    title: 'Data Analyst',
    companyName: 'Tech Corp',
    mainFieldId: 'field_1',
    mainFieldName: 'Mobile Development',
    jobType: 'Freelance',
    workMode: 'Hybrid',
    location: 'Cairo',
    description: 'Analyze business data',
  ),
];

void main() {
  group('Dashboard Filters', () {
    test('returns all jobs when no filters applied', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: '',
      );

      expect(result.length, 4);
    });

    test('filters by main field', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'field_1',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: '',
      );

      expect(result.length, 2);
      expect(result.every((j) => j.mainFieldId == 'field_1'), true);
    });

    test('filters by job type', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'FullTime',
        selectedWorkMode: 'all',
        searchQuery: '',
      );

      expect(result.length, 2);
      expect(result.every((j) => j.jobType == 'FullTime'), true);
    });

    test('filters by work mode', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'Remote',
        searchQuery: '',
      );

      expect(result.length, 2);
      expect(result.every((j) => j.workMode == 'Remote'), true);
    });

    test('filters by all three dimensions combined', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'field_1',
        selectedJobType: 'Freelance',
        selectedWorkMode: 'Hybrid',
        searchQuery: '',
      );

      expect(result.length, 1);
      expect(result.first.id, '4');
    });

    test('returns empty when no jobs match filters', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'nonexistent',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: '',
      );

      expect(result, isEmpty);
    });
  });

  group('Dashboard Search', () {
    test('finds jobs by title keyword', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'flutter',
      );

      expect(result.length, 1);
      expect(result.first.title, 'Flutter Developer');
    });

    test('finds jobs by company name', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'tech corp',
      );

      expect(result.length, 2);
      expect(result.every((j) => j.companyName == 'Tech Corp'), true);
    });

    test('finds jobs by main field name', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'Development',
      );

      expect(result.length, 2);
      expect(
        result.every((j) => j.mainFieldName.contains('Development')),
        true,
      );
    });

    test('finds jobs by location', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'cairo',
      );

      expect(result.length, 2);
      expect(result.every((j) => j.location.toLowerCase() == 'cairo'), true);
    });

    test('finds jobs by description', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'APIs',
      );

      expect(result.length, 1);
      expect(result.first.id, '2');
    });

    test('search is case-insensitive', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'all',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'FLUTTER DEVELOPER',
      );

      expect(result.length, 1);
    });

    test('search combined with filters', () {
      final result = applyFilters(
        allJobs: jobs,
        selectedMainFieldId: 'field_1',
        selectedJobType: 'all',
        selectedWorkMode: 'all',
        searchQuery: 'data',
      );

      expect(result.length, 1);
      expect(result.first.id, '4');
    });
  });
}
