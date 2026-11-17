import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../models/product_model.dart';
import '../main.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<String> _categories = [];
  String? _selected;
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final c = await Api.categories();
      if (mounted) setState(() => _categories = c);
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await Api.products(category: _selected);
      if (mounted) setState(() => _products = p);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat data.\nPeriksa koneksi internet kamu.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await DB.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: Row(children: [
          CircleAvatar(
            backgroundColor: AppColors.cream,
            child: Text(widget.username[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.brown, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Selamat datang,',
                  style: TextStyle(fontSize: 12, color: AppColors.cream)),
              Text(widget.username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => WishlistScreen(username: widget.username))),
          ),
          IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              onPressed: _logout),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          decoration: const BoxDecoration(
            color: AppColors.brown,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search, color: AppColors.brown),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        _chips(),
        Expanded(child: _body()),
      ]),
    );
  }

  Widget _chips() {
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: [
          _chip('Semua', null),
          ..._categories.map((c) => _chip(c, c)),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final on = _selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        selectedColor: AppColors.brown,
        backgroundColor: Colors.white,
        elevation: on ? 3 : 0,
        labelStyle: TextStyle(
            color: on ? Colors.white : AppColors.brown,
            fontWeight: FontWeight.w600),
        side: BorderSide(color: on ? AppColors.brown : AppColors.brownLight.withValues(alpha: .3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) {
          setState(() => _selected = value);
          _loadProducts();
        },
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.brown));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.brownLight),
          const SizedBox(height: 10),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
              onPressed: _loadProducts,
              child: const Text('Coba Lagi')),
        ]),
      );
    }
    final items =
        _products.where((p) => p.title.toLowerCase().contains(_query)).toList();
    if (items.isEmpty) {
      return const Center(
          child: Text('Produk tidak ditemukan',
              style: TextStyle(color: AppColors.brownLight)));
    }
    return RefreshIndicator(
      color: AppColors.brown,
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .68,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14),
        itemCount: items.length,
        itemBuilder: (_, i) => _card(items[i]),
      ),
    );
  }

  Widget _card(Product p) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  DetailScreen(productId: p.id, username: widget.username))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.brown.withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Container(
                width: double.infinity,
                color: AppColors.cream.withValues(alpha: .7),
                padding: const EdgeInsets.all(8),
                child: Image.network(p.thumbnail,
                    fit: BoxFit.contain,
                    loadingBuilder: (c, w, l) => l == null
                        ? w
                        : const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.brown)),
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        color: AppColors.brownLight)),
              ),
              if (p.discount > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.brown,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('-${p.discount.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: .3,
                      color: AppColors.brownLight)),
              const SizedBox(height: 2),
              Text(p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.brown)),
              const SizedBox(height: 6),
              Text('\$${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brown)),
            ]),
          ),
        ]),
      ),
    );
  }
}