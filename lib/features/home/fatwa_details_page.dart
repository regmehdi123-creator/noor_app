import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/colors.dart';
import '../../data/models/fatwa_model.dart';
import '../../services/fatwa_service.dart';
import '../../services/database_service.dart';
import '../../shared/widget/audio_player_widget.dart';

class FatwaDetailsPage extends StatefulWidget {
  final int fatwaId;

  const FatwaDetailsPage({super.key, required this.fatwaId});

  @override
  State<FatwaDetailsPage> createState() => _FatwaDetailsPageState();
}

class _FatwaDetailsPageState extends State<FatwaDetailsPage> {
  final FatwaService _fatwaService = FatwaService();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  Fatwa? _fatwa;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await _fatwaService.getFatwaDetail(widget.fatwaId);
      final isFav = await _dbService.isFavorite(widget.fatwaId);
      setState(() {
        _fatwa = detail;
        _isFavorite = isFav;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "تعذر تحميل تفاصيل الفتوى";
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_fatwa == null) return;
    if (_isFavorite) {
      await _dbService.removeFavorite(_fatwa!.id);
      Get.snackbar("المحفوظات", "تمت إزالة الفتوى من المحفوظات");
    } else {
      await _dbService.addFavorite(_fatwa!);
      Get.snackbar("المحفوظات", "تم حفظ الفتوى بنجاح");
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      Get.snackbar("خطأ", "تعذر فتح الرابط");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "تفاصيل الحكم",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: mainColor))
          : _error != null
              ? _buildErrorView()
              : _buildContentView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadDetail,
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            child: const Text("إعادة المحاولة", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title
          Text(
            _fatwa!.title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: mainColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Category & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_fatwa!.addDate != null)
                Text(
                  _fatwa!.addDate!.substring(0, 10),
                  style: const TextStyle(color: textSecondary, fontSize: 12),
                ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: secondColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _fatwa!.category ?? "عام",
                  style: const TextStyle(color: secondColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 40),

          // Question Section
          if (_fatwa!.question != null && _fatwa!.question!.isNotEmpty) ...[
            const Text(
              "السؤال:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: mainColor.withValues(alpha: 0.1)),
              ),
              child: HtmlWidget(
                _fatwa!.question!,
                textStyle: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 30),
          ],

          // Answer Section
          const Text(
            "الإجابة:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          HtmlWidget(
            _fatwa!.answer ?? "لم يتم توفير نص كامل للإجابة في هذا العرض. يرجى مراجعة المصدر الأصلي.",
            textStyle: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
          ),

          if (_fatwa!.attachments != null && _fatwa!.attachments!.isNotEmpty) ...[
            const SizedBox(height: 40),
            const Text(
              "المرفقات:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ..._fatwa!.attachments!.map((attachment) => _buildAttachmentTile(attachment)),
          ],

          const Divider(height: 60),

          // Source Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildInfoRow("المصدر", _fatwa!.source),
                if (_fatwa!.scholar != null) _buildInfoRow("العالم/المفتي", _fatwa!.scholar!),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl(_fatwa!.sourceUrl),
                        icon: const Icon(Icons.link),
                        label: const Text("المصدر الأصلي"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: mainColor,
                          side: const BorderSide(color: mainColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
          Text("$label :", style: const TextStyle(color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(FatwaAttachment attachment) {
    IconData icon;
    String label;
    Color color;

    switch (attachment.type) {
      case 'PDF':
        icon = Icons.picture_as_pdf;
        label = "تحميل ملف PDF";
        color = Colors.redAccent;
        break;
      case 'MP3':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AudioPlayerWidget(
            url: attachment.url,
            title: attachment.description ?? "فتوى صوتية",
          ),
        );
      default:
        icon = Icons.attach_file;
        label = "فتح المرفق";
        color = mainColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          attachment.description ?? label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => _launchUrl(attachment.url),
      ),
    );
  }
}
