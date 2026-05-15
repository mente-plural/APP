import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../core/api_client.dart';
import '../../models/learn/content_model.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  
  List<ContentModel> _allContent = [];
  List<ContentModel> _filteredContent = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'TEA',
    'TDAH',
    'Foco',
    'Rotina',
    'Bem-estar',
  ];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> data = await _apiClient.fetchLearnContent(
        category: _selectedCategory == 'Todos' ? null : _selectedCategory,
      );
      
      if (!mounted) return;

      final List<ContentModel> loaded = data.map((m) => ContentModel.fromMap(m)).toList();

      setState(() {
        _allContent = loaded;
        _filteredContent = loaded;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar conteúdos: $e");
      if (mounted) {
        setState(() => _isLoading = false);

        if (_allContent.isEmpty) {
          _loadMockData();
        }
      }
    }
  }

  void _loadMockData() {
    final mockData = [
      {
        'id': '1',
        'title': 'Entendendo o TDAH (Mock)',
        'description': 'Estratégias para lidar com a desatenção no dia a dia.',
        'category': 'TDAH',
        'tags': ['foco', 'adulto'],
      },
      {
        'id': '2',
        'title': 'Rotinas Visuais (Mock)',
        'description': 'Como criar um ambiente previsível e seguro.',
        'category': 'TEA',
        'tags': ['organização', 'visual'],
      },
    ];
    setState(() {
      _allContent = mockData.map((m) => ContentModel.fromMap(m)).toList();
      _filteredContent = _allContent;
    });
  }

  void _filterContent(String query) {
    setState(() {
      _filteredContent = _allContent.where((content) {
        final matchesQuery = content.title.toLowerCase().contains(query.toLowerCase()) ||
            content.description.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'Todos' || content.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgEscuro : AppColors.bgClaro,
      appBar: AppBar(
        title: const Text("Aprender", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContent,
              decoration: InputDecoration(
                hintText: "Buscar conteúdos...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppColors.surfaceEscuro : AppColors.surfaceClaro,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),


          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterContent(_searchController.text);
                      });
                    },
                    selectedColor: primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),


          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContent.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadContent,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredContent.length,
                          itemBuilder: (context, index) {
                            final content = _filteredContent[index];
                            return _buildContentCard(content, isDark, primaryColor);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(ContentModel content, bool isDark, Color primary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderEscuro : Colors.grey.shade200,
        ),
      ),
      color: isDark ? AppColors.surfaceEscuro : AppColors.surfaceClaro,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {

        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      content.category,
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content.description,
                style: TextStyle(
                  color: isDark ? AppColors.textSecundarioEscuro : AppColors.textMutedClaro,
                  fontSize: 14,
                ),
              ),
              if (content.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: content.tags.map((tag) => Text(
                    "#$tag",
                    style: TextStyle(
                      color: primary.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            "Nenhum conteúdo encontrado",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tente mudar os filtros ou o termo de busca.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
