// lib/pages/items_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../models/item.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});
  @override
  ItemsPageState createState() => ItemsPageState();
}

class ItemsPageState extends State<ItemsPage> {
  late Future<List<Item>> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    final svc = Provider.of<SupabaseService>(context, listen: false);
    _fetchFuture = svc.fetchItems().then((_) => svc.items);
  }

  Future<void> _refresh() async {
    _loadItems();
    await _fetchFuture;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SupabaseService>(context, listen: false);
    final currentEmail = Supabase.instance.client.auth.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFF64C4B8), // Mint background
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '🛍️ Thrift Store',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await svc.signOut();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/signin', (_) => false);
                    },
                  ),
                ],
              ),
            ),

            // GRID OF ITEMS
            Expanded(
              child: RefreshIndicator(
                color: Colors.white,
                onRefresh: _refresh,
                child: FutureBuilder<List<Item>>(
                  future: _fetchFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'Oops! ${snap.error}',
                          style: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      );
                    }

                    final items = snap.data!;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No items found 🧐',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final isOwner = item.uploaderEmail == currentEmail;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (isOwner)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black38,
                                            borderRadius:
                                            BorderRadius.circular(20),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20),
                                            color: Colors.white,
                                            onPressed: () async {
                                              await svc.deleteItem(item.id);
                                              await _refresh();
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // DETAILS
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₱ ${item.price.toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'By ${item.uploadedBy}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Details button (flat gray)
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/detail',
                                            arguments: item.id,
                                          );
                                        },
                                        child: Text(
                                          'Details',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // ADD NEW BUTTON (Mint tone)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                icon: const Icon(Icons.add),
                label: Text(
                  'Add New',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/add');
                  await _refresh();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
