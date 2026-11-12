import 'package:flutter/material.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/core/core.dart';
import 'package:noor/shared/background.dart';
import 'package:noor/shared/widget/gold_container.dart';

class MisbahaPage extends StatefulWidget {
  const MisbahaPage({super.key});

  @override
  State<StatefulWidget> createState() => _StateMisbahaPage();
}

class _StateMisbahaPage extends State<MisbahaPage> {
  int _counter = 0;
  int _selectedAdkarIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        "المسبحة الإلكترونية",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "سبّح واذكر الله في كل وقت",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- Adkar Grid ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adkar.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 2.2,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final isSelected = _selectedAdkarIndex == index;
                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected ? mainColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAdkarIndex = index;
                            _counter = 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: Text(
                            adkar[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontFamily: 'ScheherazadeNew',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // --- Counter Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      adkar[_selectedAdkarIndex],
                      style: const TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontWeight: FontWeight.w600,
                        color: mainColor,
                        fontSize: 35,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Count Display with Reset
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: mainColor.withValues(alpha: 0.1), width: 8),
                          ),
                          child: Center(
                            child: Text(
                              "$_counter",
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _resetCounter,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Tap Area
                    GestureDetector(
                      onTap: _incrementCounter,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mainColor,
                          boxShadow: [
                            BoxShadow(
                              color: mainColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              mainColor,
                              mainColor.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.touch_app, color: Colors.white, size: 40),
                            SizedBox(height: 8),
                            Text(
                              "اضغط",
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              GoldContainer(title: 'فضل التسبيح', dalile: '"مَنْ قَالَ سُبْحَانَ اللَّهِ وَبِحَمۡدِهِ فِي يَوۡمٍ مِائَةَ مَرَّةٍ حُطَّتۡ خَطَايَاهُ وَإِنۡ كَانَتۡ مِثۡلَ زَبَدِ ٱلۡبَحۡرِ"', source: 'رواه البخاري ومسلم')
            ],
          ),
        ),
      ),
    );
  }
}
