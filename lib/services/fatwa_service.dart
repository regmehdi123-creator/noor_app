import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../data/models/fatwa_model.dart';

class FatwaService {
  // Your hosted backend URL
  static const String _backendUrl = 'https://noor-database.onrender.com/api';

  Future<List<Fatwa>> getFatwas({int page = 1, int limit = 20}) async {
    // Using the dedicated /fatwa-titles endpoint for the main list as it supports pagination
    final url = Uri.parse('$_backendUrl/fatwa-titles?page=$page&limit=$limit');
    
    if (kDebugMode) print('Fetching Fatwa Titles (Paginated): $url');
    
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Your backend returns results in the 'results' field
        final List<dynamic> items = data['results'] ?? [];
        return items.map((json) => Fatwa.fromJson(json)).toList();
      } else {
        // Fallback to searchFatwa?title= if titles endpoint fails
        return await searchFatwas('');
      }
    } catch (e) {
      if (kDebugMode) print('Error in getFatwas: $e');
      return await searchFatwas('');
    }
  }

  Future<Fatwa> getFatwaDetail(int id) async {
    // Details endpoint: /api/FatwabyId?id=ID
    final url = Uri.parse('$_backendUrl/FatwabyId?id=$id');
    
    if (kDebugMode) print('Fetching Fatwa Details: $url');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Your backend wraps the full object in 'results'
        if (data['results'] != null) {
          return Fatwa.fromJson(data['results']);
        }
        throw Exception('Fatwa detail not found in results');
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('getFatwaDetail error: $e');
      throw Exception('Error loading fatwa details');
    }
  }

  Future<List<Fatwa>> searchFatwas(String query, {int page = 1, int limit = 20}) async {
    // Search endpoint: /api/searchFatwa?title=QUERY
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$_backendUrl/searchFatwa?title=$encodedQuery');
    
    if (kDebugMode) print('Searching Fatwas: $url');
    
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['results'] ?? [];
        return items.map((json) => Fatwa.fromJson(json)).toList();
      } else {
        if (kDebugMode) print('Search Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (kDebugMode) print('Search Network error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    // Keeping categories UI design as requested, but logic is client-side search for now
    return []; 
  }
}
