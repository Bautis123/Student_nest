import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../widgets/property_card.dart';
import 'property_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final ApiService _api = ApiService();
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final properties = await _api.getProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load listings. Check your connection.';
        _isLoading = false;
      });
    }
  }

  List<Property> get _filteredProperties {
    if (_searchQuery.isEmpty) return _properties;
    return _properties
        .where(
          (p) =>
              p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.address.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Nest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Find boarding houses near UNZA',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name or area...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: AppTheme.gray),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppTheme.gray)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProperties,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 44),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredProperties.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 48,
                      color: AppTheme.gray,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No listings found',
                      style: TextStyle(color: AppTheme.gray),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final property = _filteredProperties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  PropertyDetailScreen(propertyId: property.id),
                        ),
                      );
                    },
                  );
                }, childCount: _filteredProperties.length),
              ),
            ),
        ],
      ),
    );
  }
}
