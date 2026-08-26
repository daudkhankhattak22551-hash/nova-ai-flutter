import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../services/ai/image_generation_service.dart';

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ImageGenerationService _imageService = ImageGenerationService();
  
  String _selectedStyle = "Realistic";
  String _selectedRatio = "1:1";
  int _selectedCount = 1;

  bool _isLoading = false;
  List<Uint8List> _generatedImages = [];

  final List<Map<String, dynamic>> _styles = [
    {"name": "Realistic", "icon": Icons.camera_rounded},
    {"name": "Cinematic", "icon": Icons.movie_filter_rounded},
    {"name": "Anime", "icon": Icons.face_retouching_natural_rounded},
    {"name": "3D Render", "icon": Icons.view_in_ar_rounded},
    {"name": "Digital Art", "icon": Icons.palette_rounded},
    {"name": "Cyberpunk", "icon": Icons.electric_bolt_rounded},
  ];

  final List<Map<String, dynamic>> _ratios = [
    {"label": "1:1", "width": 20, "height": 20},
    {"label": "4:5", "width": 16, "height": 20},
    {"label": "16:9", "width": 24, "height": 14},
    {"label": "9:16", "width": 14, "height": 24},
  ];

  final List<String> _suggestions = [
    "Cyberpunk Cityscape",
    "Ancient Temple in Jungle",
    "Futuristic Supercar",
    "Portrait of an Astronaut",
    "Floating Island in Sky",
  ];

  @override
  void initState() {
    super.initState();
    _promptController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _promptController.clear();
      _generatedImages = [];
      _isLoading = false;
    });
  }

  Future<void> _generateImages() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _generatedImages = [];
    });

    try {
      final images = await _imageService.generateImage(
        prompt: prompt,
        style: _selectedStyle,
        aspectRatio: _selectedRatio,
        samples: _selectedCount,
        quality: "HD", 
      );
      
      if (mounted) {
        setState(() {
          _generatedImages = images;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Generation Error", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
        content: Text(error.replaceAll("Exception: ", ""), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(Uint8List bytes) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/nova_ai_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Gal.putImage(file.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Saved to Gallery", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _shareImage(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Created with Nova AI');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: PremiumAppBar(
        title: "Vision AI",
        actions: [
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: "Reset All",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Visualize your imagination",
              style: TextStyle(
                fontSize: 14,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.6),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // Result Area
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: (_isLoading || _generatedImages.isNotEmpty)
                  ? Column(
                      key: const ValueKey("result_view"),
                      children: [
                        _buildResultArea(isDark),
                        const SizedBox(height: 32),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            _buildSectionHeader("PROMPT"),
            const SizedBox(height: 16),
            _buildPromptInput(isDark),
            const SizedBox(height: 16),
            _buildSuggestionsScroll(isDark),
            const SizedBox(height: 32),

            _buildSectionHeader("STYLE"),
            const SizedBox(height: 16),
            _buildStyleSelector(isDark),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("RATIO"),
                      const SizedBox(height: 16),
                      _buildRatioSelector(isDark),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("SAMPLES"),
                      const SizedBox(height: 16),
                      _buildCountSelector(isDark),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            PremiumButton(
              text: _isLoading ? "Dreaming..." : "Generate Images",
              icon: Icons.auto_fix_high_rounded,
              isLoading: _isLoading,
              onPressed: _promptController.text.trim().isEmpty ? null : _generateImages,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.primary.withOpacity(0.8),
        letterSpacing: 1.5,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildPromptInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          TextField(
            controller: _promptController,
            maxLines: 4,
            maxLength: 400,
            style: const TextStyle(fontSize: 15, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "What do you want to see?",
              hintStyle: TextStyle(
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
                fontFamily: 'Poppins'
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              counterText: "",
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "${_promptController.text.length}/400",
              style: TextStyle(
                fontSize: 10,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.4),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsScroll(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _suggestions.map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _promptController.text = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                s,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins'),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStyleSelector(bool isDark) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _styles.length,
        itemBuilder: (context, index) {
          final style = _styles[index];
          final isSelected = _selectedStyle == style["name"];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedStyle = style["name"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 90,
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(colors: AppColors.primaryGradient) : null,
                  color: isSelected ? null : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(style["icon"], color: isSelected ? Colors.white : AppColors.primary, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      style["name"],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                        color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatioSelector(bool isDark) {
    return Row(
      children: _ratios.map((r) {
        final isSelected = _selectedRatio == r["label"];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRatio = r["label"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: r["width"].toDouble(),
                      height: r["height"].toDouble(),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: isSelected ? Colors.white : AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r["label"],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCountSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
      ),
      child: Row(
        children: [1, 2, 4].map((c) {
          final isSelected = _selectedCount == c;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCount = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$c",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultArea(bool isDark) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            const SizedBox(height: 24),
            const Text(
              "Creating Masterpiece",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            Text(
              "Nova is processing your imagination...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.6), 
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _generatedImages.map((img) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Image.memory(img, fit: BoxFit.cover, width: double.infinity),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildImageAction(Icons.share_rounded, "Share", () => _shareImage(img), isDark),
                      const SizedBox(width: 12),
                      _buildImageAction(Icons.download_rounded, "Save", () => _saveImage(img), isDark),
                      const Spacer(),
                      IconButton(
                        onPressed: _generateImages,
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageAction(IconData icon, String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label, 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary, fontFamily: 'Poppins')
            ),
          ],
        ),
      ),
    );
  }
}
