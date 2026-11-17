import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class Api {
  static const _base = 'https://dummyjson.com/products';

  static Future<List<Product>> products({String? category}) async {
    final url = category == null
        ? '$_base?limit=20'
        : '$_base/category/$category';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw Exception('Gagal memuat produk');
    final list = jsonDecode(r.body)['products'] as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product> detail(int id) async {
    final r = await http.get(Uri.parse('$_base/$id'));
    if (r.statusCode != 200) throw Exception('Gagal memuat detail');
    return Product.fromJson(jsonDecode(r.body));
  }

  static Future<List<String>> categories() async {
    final r = await http.get(Uri.parse('$_base/category-list'));
    if (r.statusCode != 200) throw Exception('Gagal memuat kategori');
    return List<String>.from(jsonDecode(r.body));
  }
}