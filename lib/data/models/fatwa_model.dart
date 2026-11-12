class Fatwa {
  final int id;
  final String title;
  final String? question;
  final String? answer;
  final String source;
  final String sourceUrl;
  final String? category;
  final String? scholar;
  final String? reference;
  final String? addDate;
  final List<FatwaAttachment>? attachments;

  Fatwa({
    required this.id,
    required this.title,
    this.question,
    this.answer,
    required this.source,
    required this.sourceUrl,
    this.category,
    this.scholar,
    this.reference,
    this.addDate,
    this.attachments,
  });

  factory Fatwa.fromJson(Map<String, dynamic> json) {
    String? scholarName;

    // Helper to extract name/title from a potential map
    String? extractName(dynamic item) {
      if (item is Map) {
        return (item['name'] ?? item['title'])?.toString();
      }
      return item?.toString();
    }

    // Try 'author' list first
    if (json['author'] != null && json['author'] is List && (json['author'] as List).isNotEmpty) {
      scholarName = extractName((json['author'] as List)[0]);
    }
    // Try 'prepared_by' if it's a list
    else if (json['prepared_by'] != null && json['prepared_by'] is List && (json['prepared_by'] as List).isNotEmpty) {
      scholarName = extractName((json['prepared_by'] as List)[0]);
    }
    // Fallback to 'prepared_by' string
    else if (json['prepared_by'] != null) {
      scholarName = json['prepared_by'].toString();
    }

    // Category handling - in search/list it's often a string or list
    String? catTitle;
    if (json['parent_category_title'] != null) {
      catTitle = json['parent_category_title']?.toString();
    } else if (json['category'] != null) {
      if (json['category'] is List && (json['category'] as List).isNotEmpty) {
        catTitle = extractName((json['category'] as List)[0]);
      } else if (json['category'] is String) {
        catTitle = json['category'];
      }
    }

    // Date handling: Convert timestamp to readable string
    String? formattedDate;
    if (json['add_date'] != null) {
      if (json['add_date'] is int) {
        final date = DateTime.fromMillisecondsSinceEpoch(json['add_date'] * 1000);
        formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } else {
        formattedDate = json['add_date'].toString();
      }
    }

    return Fatwa(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      question: (json['description'] ?? '').toString().trim().isNotEmpty ? json['description'].toString() : null,
      answer: (json['full_description'] ?? '').toString().trim().isNotEmpty ? json['full_description'].toString() : null,
      source: (json['source'] ?? 'IslamHouse').toString(),
      sourceUrl: (json['source_url'] ??
          (json['url'] ?? 'https://islamhouse.com/ar/fatwa/${json['id']}')).toString(),
      scholar: scholarName,
      addDate: formattedDate,
      category: catTitle,
      reference: json['reference']?.toString(),
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => FatwaAttachment.fromJson(a))
              .toList()
          : null,
    );
  }
}

class FatwaAttachment {
  final String type; // e.g. "PDF", "MP3"
  final String url;
  final String? description;

  FatwaAttachment({required this.type, required this.url, this.description});

  factory FatwaAttachment.fromJson(Map<String, dynamic> json) {
    return FatwaAttachment(
      type: (json['extension_type'] ?? 'file').toString().toUpperCase(),
      url: (json['url'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}
