import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../models/product_model.dart';
import '../main.dart';

class DetailScreen extends StatefulWidget {
  final int productId;
  final String username;
  const DetailScreen({super.key, required this.productId, required this.username});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Product> _future;
  bool _wish = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = Api.detail(widget.productId);
    DB.isWishlisted(widget.productId, widget.username).then((v) {
      if (mounted) setState(() => _wish = v);
    });
  }

  Future<void> _toggle(Product p) async {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    if (_wish) {
      await DB.removeWishlist(p.id, widget.username);
      m.showSnackBar(SnackBar(
          content: Text('${p.title} dihapus dari wishlist'),
          backgroundColor: Colors.red));
    } else {
      await DB.addWishlist(p, widget.username);
      m.showSnackBar(SnackBar(
          content: Text('${p.title} ditambahkan ke wishlist'),
          backgroundColor: Colors.green));
    }
    if (mounted) setState(() => _wish = !_wish);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // FIX 1: sisa layar ikut putih
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.brown,
        elevation: 0,
      ),
      body: FutureBuilder<Product>(
        future: _future,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brown));
          }
          if (s.hasError || !s.hasData) {
            return const Center(child: Text('Gagal memuat detail produk'));
          }
          final p = s.data!;
          final imgs = p.images.isNotEmpty ? p.images : [p.thumbnail];
          final after = p.price * (1 - p.discount / 100);
          return Column(children: [
            Expanded(
              // FIX 2: LayoutBuilder buat tahu tinggi area yang tersedia
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Stack(children: [
                      Container(
                        height: 360,
                        color: AppColors.cream,
                        padding: const EdgeInsets.only(top: 70, bottom: 40),
                        child: PageView.builder(
                          itemCount: imgs.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (_, i) => Image.network(imgs[i],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported, size: 60)),
                        ),
                      ),
                      if (imgs.length > 1)
                        Positioned(
                          bottom: 44,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              imgs.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _page == i ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    color: _page == i
                                        ? AppColors.brown
                                        : AppColors.brownLight.withValues(alpha: .4),
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 330),
                        child: Container(
                          width: double.infinity,
                          // minimal setinggi sisa layar, jadi putihnya sampai bawah
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 330,
                          ),
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(spacing: 8, children: [
                                  _tag(p.category, Icons.category_outlined),
                                  if (p.brand.isNotEmpty)
                                    _tag(p.brand, Icons.sell_outlined),
                                ]),
                                const SizedBox(height: 12),
                                Text(p.title,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.brown)),
                                const SizedBox(height: 14),
                                Row(children: [
                                  _info(Icons.star_rounded,
                                      p.rating.toStringAsFixed(1), 'Rating', Colors.amber),
                                  const SizedBox(width: 10),
                                  _info(Icons.inventory_2_rounded, '${p.stock}', 'Stok',
                                      p.stock > 0 ? AppColors.brown : Colors.red),
                                  const SizedBox(width: 10),
                                  _info(Icons.local_offer_rounded,
                                      '${p.discount.toStringAsFixed(0)}%', 'Diskon',
                                      AppColors.brownLight),
                                ]),
                                const SizedBox(height: 22),
                                const Text('Deskripsi',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brown)),
                                const SizedBox(height: 8),
                                Text(p.description,
                                    style: const TextStyle(
                                        height: 1.6, color: Color(0xFF5D4D48))),
                              ]),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: AppColors.brown.withValues(alpha: .12),
                    blurRadius: 16,
                    offset: const Offset(0, -4))
              ]),
              child: SafeArea(
                top: false,
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (p.discount > 0)
                      Text('\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.brownLight)),
                    Text('\$${after.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brown)),
                  ]),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _toggle(p),
                      icon: Icon(_wish ? Icons.favorite : Icons.favorite_border,
                          color: _wish ? Colors.redAccent : AppColors.cream),
                      label: Text(_wish ? 'Hapus Wishlist' : 'Wishlist'),
                    ),
                  ),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _tag(String t, IconData i) => Chip(
        avatar: Icon(i, size: 15, color: AppColors.brown),
        label: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.brown)),
        backgroundColor: AppColors.cream,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      );

  Widget _info(IconData i, String v, String label, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Icon(i, color: c),
            const SizedBox(height: 4),
            Text(v,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.brown)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.brownLight)),
          ]),
        ),
      );
}