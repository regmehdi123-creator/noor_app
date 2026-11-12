import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/data/models/fatwa_model.dart';
import 'package:noor/features/home/fatwa_details_page.dart';
import 'package:noor/services/database_service.dart';
import 'package:noor/services/fatwa_service.dart';
import 'package:noor/shared/background.dart';
import 'package:noor/shared/widget/fatwa_card.dart';

class HokmPage extends StatefulWidget {
  const HokmPage({super.key});

  @override
  State<HokmPage> createState() => _HokmPageState();
}

class _HokmPageState extends State<HokmPage> {
  final FatwaService _fatwaService = FatwaService();
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  List<Fatwa> _fatwas = [];
  String? _error;
  String? _currentCategory;

  final List<Map<String, String>> _categories = [
    {"name": "الكل", "icon": "🏠", "query": ""},
    {"name": "الصلاة", "icon": "🕌", "query": "صلاة"},
    {"name": "الصيام", "icon": "🌙", "query": "صيام"},
    {"name": "الزكاة", "icon": "💰", "query": "زكاة"},
    {"name": "الحج", "icon": "🕋", "query": "حج"},
    {"name": "القرآن", "icon": "📖", "query": "قرآن"},
    {"name": "الذكر", "icon": "🤲", "query": "ذكر"},
    {"name": "هام", "icon": "⭐", "query": "favorites"},
    {"name": "الشرك", "icon": "⚠️", "query": "الشرك"},
  ];

  @override
  void initState() {
    super.initState();
    _loadFatwas();
  }

  Future<void> _loadFatwas({String? query, bool clearCache = false, bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMore = true;
        if (!isLoadMore) _fatwas = [];
      });
    }

    try {
      if (clearCache) {
        await _dbService.clearFatwaCache();
      }

      List<Fatwa> newFatwas;
      if (query != null && query.trim().isNotEmpty) {
        newFatwas = await _fatwaService.searchFatwas(query.trim(), page: _currentPage);
      } else {
        newFatwas = await _fatwaService.getFatwas(page: _currentPage);
        // Cache initial page only if not a search and page 1
        if (newFatwas.isNotEmpty && _currentPage == 1) {
          await _dbService.cacheFatwas(newFatwas);
        }
      }

      setState(() {
        if (isLoadMore) {
          _fatwas.addAll(newFatwas);
          _isLoadingMore = false;
        } else {
          _fatwas = newFatwas;
          _isLoading = false;
        }
        
        if (newFatwas.isEmpty || newFatwas.length < 15) {
          _hasMore = false;
        } else {
          _currentPage++;
        }
      });
    } catch (e) {
      debugPrint("HokmPage Error: $e");
      if (isLoadMore) {
        setState(() => _isLoadingMore = false);
        Get.snackbar("خطأ", "تعذر تحميل المزيد من الأحكام");
        return;
      }
      
      // Try to load from cache if it's not a search and not a clearCache request
      if ((query == null || query.isEmpty) && !clearCache) {
        final cached = await _dbService.getCachedFatwas();
        if (cached.isNotEmpty) {
          setState(() {
            _fatwas = cached;
            _isLoading = false;
            _hasMore = false;
          });
          Get.snackbar(
            "تنبيه",
            "أنت تتصفح المحتوى المخزن مؤقتاً (بدون إنترنت)",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: mainColor.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
          return;
        }
      }
      setState(() {
        _error = "تعذر تحميل الأحكام. يرجى التأكد من الاتصال بالإنترنت\nأو المحاولة لاحقاً";
        _isLoading = false;
      });
    }
  }

  void _onSearch(String value) {
    if (value.trim().isNotEmpty) {
      _loadFatwas(query: value.trim());
    } else {
      _loadFatwas();
    }
  }

  void _onCategoryTap(String query, String name) {
    setState(() {
      _currentCategory = name == "الكل" ? null : name;
      _searchController.clear();
    });
    if (query == "favorites") {
      _loadFavorites();
    } else {
      _loadFatwas(query: query);
    }
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final favorites = await _dbService.getFavorites();
      setState(() {
        _fatwas = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "تعذر تحميل المحفوظات";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const Text(
                    "الأحكام والفتاوى",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              "استكشف الأحكام والفتاوى من مصادر موثوقة",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                    _onSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: "🔍 ابحث عن حكم أو سؤال...",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: mainColor),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _onSearch(_searchController.text);
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --- Categories ---
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: true, // For RTL feel
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = (_currentCategory == null && cat["name"] == "الكل") ||
                      (_currentCategory == cat["name"]);
                  return GestureDetector(
                    onTap: () => _onCategoryTap(cat["query"]!, cat["name"]!),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? secondColor : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              cat["name"]!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(cat["icon"]!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- Main Content ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              decoration: const BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: CircularProgressIndicator(color: mainColor)),
                    )
                  : _error != null
                      ? _buildErrorView()
                      : _buildFatwaList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textPrimary, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _loadFatwas(query: _searchController.text),
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _loadFatwas(clearCache: true),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: mainColor)),
              child: const Text("تحديث البيانات", style: TextStyle(color: mainColor)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFatwaList() {
    if (_fatwas.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _currentCategory == "هام"
                ? "لا يوجد فتاوى محفوظة حالياً"
                : "لم نجد حكماً مناسباً\nجرّب البحث بكلمات أخرى",
            textAlign: TextAlign.center,
            style: const TextStyle(color: textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _onCategoryTap("", "الكل");
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("تحديث القائمة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fatwas.length + (_hasMore ? 2 : 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _currentCategory != null ? "نتائج: $_currentCategory" : "آخر الأحكام",
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        if (index == _fatwas.length + 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator(color: mainColor)
                  : ElevatedButton(
                      onPressed: () => _loadFatwas(query: _searchController.text, isLoadMore: true),
                      style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                      child: const Text("تحميل المزيد", style: TextStyle(color: Colors.white)),
                    ),
            ),
          );
        }

        final fatwa = _fatwas[index - 1];
        return FatwaCard(
          fatwa: fatwa,
          onTap: () async {
            await Get.to(() => FatwaDetailsPage(fatwaId: fatwa.id));
            if (_currentCategory == "هام") {
              _loadFavorites();
            }
          },
        );
      },
    );
  }
}
