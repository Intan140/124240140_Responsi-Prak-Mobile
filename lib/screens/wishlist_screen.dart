import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/product_model.dart';
import '../main.dart';
import 'detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final String username;
  const WishlistScreen({super.key, required this.username});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = DB.wishlist(widget.username);
  }

  Future<void> _remove(Product p) async {
    await DB.removeWishlist(p.id, widget.username);
    if (!mounted) return;
    setState(() {
      _reload();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${p.title} dihapus dari wishlist'),
        backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist Saya')),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brown));
          }
          final items = s.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border_rounded,
                      size: 56, color: AppColors.brownLight),
                ),
                const SizedBox(height: 16),
                const Text('Wishlist masih kosong',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown)),
                const SizedBox(height: 4),
                const Text('Tambahkan produk favoritmu dari halaman detail',
                    style: TextStyle(color: AppColors.brownLight)),
              ]),
            );
          }
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${items.length} produk tersimpan',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.brownLight)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final p = items[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.brown.withValues(alpha: .1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                    productId: p.id, username: widget.username)));
                        if (mounted) {
                          setState(() {
                            _reload();
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.all(6),
                            child: Image.network(p.thumbnail,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.category,
                                      style: const TextStyle(
                                          fontSize: 11, color: AppColors.brownLight)),
                                  const SizedBox(height: 2),
                                  Text(p.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.brown)),
                                  const SizedBox(height: 6),
                                  Text('\$${p.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brown)),
                                ]),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withValues(alpha: .1)),
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                            onPressed: () => _remove(p),
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}