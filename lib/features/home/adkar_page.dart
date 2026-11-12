import 'package:flutter/material.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/data/data.dart';
import 'package:noor/shared/background.dart';
import 'package:noor/shared/widget/gold_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdkarPage extends StatefulWidget {
  const AdkarPage({super.key});
  @override
  State<AdkarPage> createState() => _AdkarPageState();
}

class _AdkarPageState extends State<AdkarPage> {
  int? selectedCategoryIndex;
  int completedToday = 0;

  @override
  void initState() {
    super.initState();
    _checkDailyReset();
  }

  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString('last_adkar_reset') ?? "";
    final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

    if (lastReset != today) {
      // It's a new day! Reset all currentCounts to 0
      for (var category in adkarCategories) {
        for (var item in category.adkar) {
          item.currentCount = 0;
        }
      }
      await prefs.setString('last_adkar_reset', today);
      await prefs.setInt('completed_today', 0);
    } else {
      // Same day, load completed count
      setState(() {
        completedToday = prefs.getInt('completed_today') ?? 0;
      });
    }
  }

  void _toggleNavigate(int? index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  void _incrementAdkar(int categoryIndex, int adkarIndex) async {
    final item = adkarCategories[categoryIndex].adkar[adkarIndex];
    if (item.currentCount < item.targetCount) {
      setState(() {
        item.currentCount++;
        if (item.isCompleted) {
          completedToday++;
        }
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completed_today', completedToday);
      // Note: In a real app, you'd save individual counts too, 
      // but keeping it simple as requested.
    }
  }


  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 15),
          _buildStats(),
          const SizedBox(height: 20),
          if (selectedCategoryIndex == null) 
            _buildCategoryGrid() 
          else 
            _buildAdkarList(selectedCategoryIndex!),
          const SizedBox(height: 20),
          const GoldContainer(
            title: '🌿 فوائد الأذكار',
            dalile: '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
            source: 'سورة الرعد - الآية 28',
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              "الأدعية والأذكار",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              "حصن المسلم اليومي",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statItem("$completedToday", "مكتملة اليوم"),
        const SizedBox(width: 15),
        _statItem("${adkarCategories.length}", "الفئات"),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adkarCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final category = adkarCategories[index];
        return InkWell(
          onTap: () => _toggleNavigate(index),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: category.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Stack(
              children: [
                Positioned(top: 15, right: 15, child: Text(category.icon, style: const TextStyle(fontSize: 35))),
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(category.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${category.adkar.length} ذكر", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdkarList(int index) {
    final category = adkarCategories[index];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                category.title,
                style: TextStyle(color: category.color, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () => _toggleNavigate(null),
              child: Row(
                children: const [
                  Text("العودة للفئات", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...List.generate(category.adkar.length, (i) {
          final item = category.adkar[i];
          return AdkarCard(
            text: item.text,
            count: item.targetCount - item.currentCount,
            isCompleted: item.isCompleted,
            press: () => _incrementAdkar(index, i),
          );
        }),
      ],
    );
  }

}

class AdkarCard extends StatelessWidget {
  final String text;
  final int count;
  final bool isCompleted;
  final VoidCallback press;

  const AdkarCard({
    super.key,
    required this.text,
    required this.count,
    required this.isCompleted,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCompleted ? null : press,
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 20, height: 1.6, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: mainColor, size: 28)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.touch_app, color: mainColor, size: 18),
                              SizedBox(width: 5),
                              Text("اضغط للعد", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isCompleted ? mainColor : secondColorLight,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isCompleted ? "✓" : "$count",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}