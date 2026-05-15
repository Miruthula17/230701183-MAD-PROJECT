import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/jobs_provider.dart';
import '../config.dart';
import '../widgets/search_job_card.dart';
import 'job_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Load initial jobs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SearchProvider>();
      if (provider.searchResults.isEmpty) {
        provider.searchJobs(category: 'software-dev');
        setState(() => _hasSearched = true);
      } else {
        setState(() => _hasSearched = true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    final provider = context.read<SearchProvider>();
    provider.searchJobs(
      query: query.isNotEmpty ? query : null,
    );
    setState(() => _hasSearched = true);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();
    final jobs = context.watch<JobsProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            _buildSearchHeader(search),

            // Category chips
            _buildCategoryChips(search),

            // Results
            Expanded(
              child: _buildResults(search, jobs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(SearchProvider search) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Jobs',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF191919),
                    ),
                  ),
                  Text(
                    'Real jobs from top companies',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search role, company, skill...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF70B5F9)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              search.clearSearch();
                              setState(() => _hasSearched = false);
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(SearchProvider search) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: Config.jobCategories.length,
        itemBuilder: (context, index) {
          final cat = Config.jobCategories[index];
          final isSelected = search.selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                search.setCategory(cat['id']!);
                search.searchJobs(category: search.selectedCategory.isNotEmpty ? search.selectedCategory : null);
                setState(() => _hasSearched = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF0A66C2), Color(0xFF70B5F9)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFEBEBEB)),
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults(SearchProvider search, JobsProvider jobsProvider) {
    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (search.isLoading) {
      return _buildLoadingState();
    }

    if (search.error.isNotEmpty) {
      return _buildErrorState(search.error);
    }

    if (search.searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF0A66C2),
      onRefresh: () => search.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: search.searchResults.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${search.searchResults.length} jobs found',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          final job = search.searchResults[index - 1];
          return SearchJobCard(
            job: job,
            isSaved: jobsProvider.isJobSaved(job.id),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobDetailScreen(job: job),
              ),
            ),
            onSave: () => jobsProvider.toggleSaveJob(job),
            onApply: () {
              jobsProvider.addFromSearch(job);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF057642)),
                      const SizedBox(width: 8),
                      Text('${job.company} added to applications!'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore_rounded,
              size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Search for your dream job',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try "Flutter Developer" or "Product Manager"',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (_, i) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            width: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 64, color: Color(0xFFCC1016)),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<SearchProvider>().refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or category',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
