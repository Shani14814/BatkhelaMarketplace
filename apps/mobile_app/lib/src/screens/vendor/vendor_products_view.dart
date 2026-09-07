import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/vendor_demo_data.dart';

class VendorProductsView extends StatefulWidget {
  const VendorProductsView({super.key});

  @override
  State<VendorProductsView> createState() => _VendorProductsViewState();
}

class _VendorProductsViewState extends State<VendorProductsView> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VendorDemoController.instance,
      builder: (context, _) {
        final allProducts = VendorDemoController.instance.products;

        final Set<String> categorySet = {};
        for (final p in allProducts) {
          final cat = p.effectiveCategory;
          if (cat != null && cat.isNotEmpty) {
            categorySet.add(cat);
          }
        }
        final categories = ['All', ...categorySet];

        final filteredProducts = allProducts.where((p) {
          final effectiveCat = p.effectiveCategory ?? 'General';
          final matchesCategory = _selectedCategory == 'All' || effectiveCat == _selectedCategory;
          final matchesSearch = _searchQuery.isEmpty ||
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (p.description != null && p.description!.toLowerCase().contains(_searchQuery.toLowerCase()));
          return matchesCategory && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Product Inventory',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                tooltip: 'Add Product',
                onPressed: () => _showAddEditProductModal(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items, ingredients...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Categories Chips Bar
              Container(
                color: Colors.white,
                height: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.backgroundLight,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        ),
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Products List
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                                  size: 34,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No items match "$_searchQuery"'
                                    : 'No items in this category',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try checking for typos or searching a different term.'
                                    : 'Tap the button below to add new dishes, grocery items, or products.',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.3),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchQuery.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => setState(() => _searchQuery = ''),
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text('Clear Search Filter'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductTile(context, product);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showAddEditProductModal(context),
          ),
        );
      },
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: product.isAvailable
              ? const Color(0xFFE2E8F0)
              : Colors.grey.shade300,
        ),
      ),
      color: product.isAvailable ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: MarketplaceProductImage(
                  imageUrl: product.imageUrl,
                  productName: product.name,
                  category: product.effectiveCategory,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: product.isAvailable ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.effectiveCategory ?? 'General',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.description != null && product.description!.isNotEmpty)
                    Text(
                      product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (product.discountPrice != null) ...[
                        Text(
                          'PKR ${product.discountPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PKR ${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'PKR ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.indigo),
                        tooltip: 'Edit Product',
                        onPressed: () => _showAddEditProductModal(context, product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete Product',
                        onPressed: () => _confirmDeleteProduct(context, product),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stock Availability Switch
            Column(
              children: [
                Switch(
                  value: product.isAvailable,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.softCyan,
                  onChanged: (_) {
                    VendorDemoController.instance.toggleProductAvailability(product.id);
                  },
                ),
                Text(
                  product.isAvailable ? 'In Stock' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: product.isAvailable ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to remove "${product.name}" from your store inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              VendorDemoController.instance.deleteProduct(product.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${product.name}" removed from inventory.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditProductModal(BuildContext context, {Product? product}) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final catCtrl = TextEditingController(text: product?.effectiveCategory ?? 'Karahi Special');
    final priceCtrl = TextEditingController(text: product != null ? product.price.toStringAsFixed(0) : '');
    final discPriceCtrl = TextEditingController(text: product?.discountPrice != null ? product!.discountPrice!.toStringAsFixed(0) : '');
    final stockCtrl = TextEditingController(text: product != null ? product.stockQuantity.toString() : '50');
    final descCtrl = TextEditingController(text: product?.description ?? '');

    String selectedImageUrl = product?.imageUrl ?? 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&auto=format&fit=crop&q=80';
    Uint8List? localImageBytes;
    String? localImageFileName;
    bool isUploading = false;
    bool isAvailable = product?.isAvailable ?? true;

    final List<Map<String, String>> photoPresets = [
      {'title': 'Mutton Karahi', 'url': 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Chapli Kabab', 'url': 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Namkeen Tikka', 'url': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Roghani Naan', 'url': 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Biryani Feast', 'url': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Zinger Burger', 'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Shawarma Wrap', 'url': 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Basmati Rice', 'url': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Cooking Oil', 'url': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Farm Eggs', 'url': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Panadol Care', 'url': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&auto=format&fit=crop&q=80'},
      {'title': 'First Aid Kit', 'url': 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Gulab Jamun', 'url': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Swat Apples', 'url': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&auto=format&fit=crop&q=80'},
      {'title': 'Farm Tomatoes', 'url': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&auto=format&fit=crop&q=80'},
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Product' : 'Add New Product',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Product Image Picker Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: localImageBytes != null
                                      ? Image.memory(localImageBytes!, fit: BoxFit.cover)
                                      : MarketplaceProductImage(
                                          imageUrl: selectedImageUrl,
                                          productName: nameCtrl.text.isEmpty ? 'Product Image' : nameCtrl.text,
                                          category: catCtrl.text,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Product Image',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(width: 6),
                                        if (localImageBytes != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Device Image',
                                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localImageFileName != null
                                          ? 'Ready: $localImageFileName'
                                          : 'Choose from Android gallery, camera, or catalog presets.',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 6),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      icon: const Icon(Icons.photo_camera_outlined, size: 14),
                                      label: const Text('Choose Image', style: TextStyle(fontSize: 11)),
                                      onPressed: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (pickerCtx) {
                                            return SafeArea(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Choose Image Source',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                    ),
                                                    const SizedBox(height: 12),

                                                    // Hardware/Device Pickers
                                                    ListTile(
                                                      leading: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                                                      ),
                                                      title: const Text('Choose from Device Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                      subtitle: const Text('Select a high-quality photo from phone storage', style: TextStyle(fontSize: 11)),
                                                      onTap: () async {
                                                        Navigator.pop(pickerCtx);
                                                        try {
                                                          final picker = ImagePicker();
                                                          final file = await picker.pickImage(
                                                            source: ImageSource.gallery,
                                                            maxWidth: 1200,
                                                            maxHeight: 1200,
                                                            imageQuality: 85,
                                                          );
                                                          if (file != null) {
                                                            final bytes = await file.readAsBytes();
                                                            final validation = StorageValidator.validate(
                                                              bytes: bytes,
                                                              fileName: file.name,
                                                              bucket: StorageBucket.productImages,
                                                            );
                                                            if (!validation.isValid) {
                                                              if (context.mounted) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text(validation.errorMessage ?? 'Invalid image file.')),
                                                                );
                                                              }
                                                              return;
                                                            }
                                                            setModalState(() {
                                                              localImageBytes = bytes;
                                                              localImageFileName = file.name;
                                                            });
                                                          }
                                                        } catch (e) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Could not open gallery: $e')),
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.indigo.withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(Icons.camera_alt_outlined, color: AppColors.indigo),
                                                      ),
                                                      title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                      subtitle: const Text('Take a live photo of your dish or product', style: TextStyle(fontSize: 11)),
                                                      onTap: () async {
                                                        Navigator.pop(pickerCtx);
                                                        try {
                                                          final picker = ImagePicker();
                                                          final file = await picker.pickImage(
                                                            source: ImageSource.camera,
                                                            maxWidth: 1200,
                                                            maxHeight: 1200,
                                                            imageQuality: 85,
                                                          );
                                                          if (file != null) {
                                                            final bytes = await file.readAsBytes();
                                                            final validation = StorageValidator.validate(
                                                              bytes: bytes,
                                                              fileName: file.name,
                                                              bucket: StorageBucket.productImages,
                                                            );
                                                            if (!validation.isValid) {
                                                              if (context.mounted) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text(validation.errorMessage ?? 'Invalid image file.')),
                                                                );
                                                              }
                                                              return;
                                                            }
                                                            setModalState(() {
                                                              localImageBytes = bytes;
                                                              localImageFileName = file.name;
                                                            });
                                                          }
                                                        } catch (e) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Could not open camera: $e')),
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),

                                                    const Divider(height: 24),
                                                    const Text(
                                                      'Or Select Demo Catalog Preset:',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                                                    ),
                                                    const SizedBox(height: 10),

                                                    SizedBox(
                                                      height: 110,
                                                      child: ListView.separated(
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: photoPresets.length,
                                                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                                                        itemBuilder: (context, index) {
                                                          final item = photoPresets[index];
                                                          final isSel = localImageBytes == null && selectedImageUrl == item['url'];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              setModalState(() {
                                                                selectedImageUrl = item['url']!;
                                                                localImageBytes = null;
                                                                localImageFileName = null;
                                                              });
                                                              Navigator.pop(pickerCtx);
                                                            },
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: 68,
                                                                  height: 68,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    border: Border.all(
                                                                      color: isSel ? AppColors.primary : Colors.grey.shade300,
                                                                      width: isSel ? 3 : 1,
                                                                    ),
                                                                  ),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    child: MarketplaceProductImage(
                                                                      imageUrl: item['url'],
                                                                      productName: item['title']!,
                                                                      category: item['title'],
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(
                                                                  item['title']!,
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                                                    color: isSel ? AppColors.primary : Colors.black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
                        hintText: 'e.g. Special Chicken Karahi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: catCtrl,
                      decoration: InputDecoration(
                        labelText: 'Category (e.g. Karahi Special, Kababs & BBQ, Tandoor, Grocery)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Regular Price (PKR) *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: discPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Discount Price (Optional)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Initial Stock Quantity',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isAvailable ? 'In Stock' : 'Unavailable',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isAvailable ? AppColors.primary : Colors.grey,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: isAvailable,
                                  activeThumbColor: AppColors.primary,
                                  activeTrackColor: AppColors.softCyan,
                                  onChanged: (v) => setModalState(() => isAvailable = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description / Ingredients',
                        hintText: 'e.g. Fresh tomatoes, ginger, green chillies & desi spices',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        if (isEditing) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Delete'),
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _confirmDeleteProduct(context, product);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isUploading
                                ? null
                                : () async {
                                    final name = nameCtrl.text.trim();
                                    final cat = catCtrl.text.trim();
                                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                                    final discPrice = double.tryParse(discPriceCtrl.text.trim());
                                    final stock = int.tryParse(stockCtrl.text.trim()) ?? 50;
                                    final desc = descCtrl.text.trim();

                                    if (name.isEmpty || price <= 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please provide valid product name and price.')),
                                      );
                                      return;
                                    }

                                    String finalImageUrl = selectedImageUrl;

                                    if (localImageBytes != null) {
                                      setModalState(() => isUploading = true);
                                      try {
                                        const vendorId = 'vendor_shinwari_01';
                                        final prodId = product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';
                                        final uploadedUrl = await MarketplaceDataService.instance.storageRepo.uploadProductImage(
                                          vendorId: vendorId,
                                          productId: prodId,
                                          bytes: localImageBytes!,
                                          fileName: localImageFileName ?? 'product.jpg',
                                        );
                                        finalImageUrl = uploadedUrl;
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Image upload failed: $e')),
                                          );
                                        }
                                        setModalState(() => isUploading = false);
                                        return;
                                      }
                                    }

                                    if (isEditing) {
                                      VendorDemoController.instance.editProduct(
                                        id: product.id,
                                        name: name,
                                        category: cat.isEmpty ? 'General' : cat,
                                        price: price,
                                        discountPrice: discPrice,
                                        description: desc,
                                        imageUrl: finalImageUrl,
                                        stockQuantity: stock,
                                        isAvailable: isAvailable,
                                      );
                                    } else {
                                      VendorDemoController.instance.addProduct(
                                        name: name,
                                        category: cat.isEmpty ? 'General' : cat,
                                        price: price,
                                        discountPrice: discPrice,
                                        description: desc,
                                        imageUrl: finalImageUrl,
                                        stockQuantity: stock,
                                      );
                                    }

                                    if (context.mounted) {
                                      Navigator.of(sheetContext).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isEditing ? 'Product updated successfully!' : 'Product added to store inventory!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                            child: isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    isEditing ? 'Save Changes' : 'Create Product',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
