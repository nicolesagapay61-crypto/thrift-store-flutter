// lib/pages/item_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';
import '../../models/item.dart';
import '../../widgets/info_chip.dart';
import 'full_screen_image_page.dart';

class ItemDetailPage extends StatelessWidget {
  final int itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<SupabaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF64C4B8), // Mint background
      body: SafeArea(
        child: FutureBuilder<Item?>(
          future: svc.fetchItemDetail(itemId),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Error: ${snap.error}',
                  style: GoogleFonts.poppins(color: Colors.redAccent),
                ),
              );
            }
            final item = snap.data;
            if (item == null) {
              return Center(
                child: Text(
                  'Item not found 🤷',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      // Back + Title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Details',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImagePage(
                                itemId: item.id, imageUrl: item.imageUrl),
                          ),
                        ),
                        child: Hero(
                          tag: 'item-image-${item.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              item.imageUrl,
                              height: 230,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Price
                      Text(
                        '₱ ${item.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Info chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InfoChip(icon: Icons.person, text: item.uploadedBy),
                          const SizedBox(width: 6),
                          InfoChip(icon: Icons.email, text: item.contactInfo),
                          const SizedBox(width: 6),
                          InfoChip(
                            icon: Icons.calendar_today,
                            text:
                            '${item.createdAt.month}/${item.createdAt.day}/${item.createdAt.year}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom gray contact section
                Container(
                  width: double.infinity,
                  color: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: TextButton(
                    onPressed: () async {
                      final email = snap.data!.contactInfo.trim();
                      final subject =
                      Uri.encodeComponent('Inquiry about "${item.title}"');
                      final uri = Uri.parse('mailto:$email?subject=$subject');
                      try {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (_) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Contact Owner',
                                style: GoogleFonts.poppins()),
                            content: SelectableText(email,
                                style: GoogleFonts.poppins()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close',
                                    style: GoogleFonts.poppins()),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Contact Owner',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
