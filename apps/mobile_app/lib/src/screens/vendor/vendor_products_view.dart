import 'package:flutter/material.dart';
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No products found',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge Area
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: product.isAvailable
                    ? AppColors.softCyan.withAlpha(50)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: product.isAvailable
                    ? AppColors.primary
                    : Colors.grey.shade600,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: product.isAvailable ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        onPressed: () => _showAddEditProductModal(context, product: product),
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

  void _showAddEditProductModal(BuildContext context, {Product? product}) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final catCtrl = TextEditingController(text: product?.effectiveCategory ?? 'Karahi Special');
    final priceCtrl = TextEditingController(text: product != null ? product.price.toStringAsFixed(0) : '');
    final discPriceCtrl = TextEditingController(text: product?.discountPrice != null ? product!.discountPrice!.toStringAsFixed(0) : '');
    final descCtrl = TextEditingController(text: product?.description ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catCtrl,
                  decoration: InputDecoration(
                    labelText: 'Category (e.g. Karahi, BBQ, Tandoor)',
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
                          labelText: 'Regular Price (PKR)',
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
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description / Ingredients',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final cat = catCtrl.text.trim();
                      final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                      final discPrice = double.tryParse(discPriceCtrl.text.trim());
                      final desc = descCtrl.text.trim();

                      if (name.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please provide valid product name and price.')),
                        );
                        return;
                      }

                      if (isEditing) {
                        VendorDemoController.instance.editProduct(
                          id: product.id,
                          name: name,
                          category: cat.isEmpty ? 'General' : cat,
                          price: price,
                          discountPrice: discPrice,
                          description: desc,
                        );
                      } else {
                        VendorDemoController.instance.addProduct(
                          name: name,
                          category: cat.isEmpty ? 'General' : cat,
                          price: price,
                          discountPrice: discPrice,
                          description: desc,
                        );
                      }

                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Product updated successfully!' : 'Product added to inventory!')),
                      );
                    },
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Product',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
