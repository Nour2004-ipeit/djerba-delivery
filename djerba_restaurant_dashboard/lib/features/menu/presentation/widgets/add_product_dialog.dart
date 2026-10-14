import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../data/menu_api.dart';
import '../../../../core/theme.dart';
import 'package:file_picker/file_picker.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final String restaurantId;

  const AddProductDialog({super.key, required this.restaurantId});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isLoading = false;
  bool _isGeneratingImage = false;
  final List<Map<String, TextEditingController>> _variants = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    for (var v in _variants) {
      v['name']?.dispose();
      v['price']?.dispose();
    }
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a product name first')));
      return;
    }

    setState(() => _isGeneratingImage = true);
    
    // Combine name, category and description to give the AI better context for niche foods like Panuzzo
    final aiPrompt = "${_nameController.text.trim()} ${_categoryController.text.trim()} ${_descController.text.trim()}";
    final imageUrl = await MenuApi().generateProductImage(aiPrompt.trim());
    setState(() => _isGeneratingImage = false);
    
    if (imageUrl != null) {
      setState(() {
        _imageController.text = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Image generated!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate image'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.bytes != null) {
      setState(() => _isGeneratingImage = true);
      final bytes = result.files.single.bytes!;
      final filename = result.files.single.name;
      final imageUrl = await MenuApi().uploadImage(bytes, filename);
      setState(() => _isGeneratingImage = false);
      if (imageUrl != null) {
        _imageController.text = imageUrl;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final List<Map<String, dynamic>> variantsData = [];
    for (var v in _variants) {
      if (v['name']!.text.isNotEmpty && v['price']!.text.isNotEmpty) {
        variantsData.add({
          'name': v['name']!.text,
          'price': double.tryParse(v['price']!.text) ?? 0.0,
        });
      }
    }

    double basePrice = double.tryParse(_priceController.text) ?? 0.0;
    if (basePrice == 0.0 && variantsData.isNotEmpty) {
      basePrice = variantsData.first['price'] as double;
    }

    final data = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': basePrice,
      'category': _categoryController.text.trim().isEmpty ? 'Général' : _categoryController.text.trim(),
      if (variantsData.isNotEmpty) 'variants': variantsData,
      'imageUrl': _imageController.text,
    };

    final product = await MenuApi().addProduct(widget.restaurantId, data);
    
    setState(() => _isLoading = false);

    if (product != null && mounted) {
      ref.invalidate(menuProductsProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category (e.g. Panuzzo, Pizzas)', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Base Price (TND)', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (_variants.isNotEmpty) return null;
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sizes / Variants (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _variants.add({'name': TextEditingController(), 'price': TextEditingController()});
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Size'),
                    ),
                  ],
                ),
                if (_variants.isNotEmpty) ..._variants.asMap().entries.map((entry) {
                  final i = entry.key;
                  final v = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: v['name'],
                            decoration: InputDecoration(labelText: 'Size Name (e.g. Large)', border: const OutlineInputBorder(), isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: v['price'],
                            decoration: InputDecoration(labelText: 'Price', border: const OutlineInputBorder(), isDense: true),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              v['name']?.dispose();
                              v['price']?.dispose();
                              _variants.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        SizedBox(
                          height: 56,
                          width: 130,
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingImage ? null : _generateImage,
                            icon: _isGeneratingImage 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                            label: const Text('AI Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 56,
                          width: 130,
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingImage ? null : _uploadImage,
                            icon: const Icon(Icons.upload_file, color: Colors.blue, size: 20),
                            label: const Text('Upload'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: DjerbaTheme.primaryColor, foregroundColor: Colors.white),
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Product'),
        ),
      ],
    );
  }
}
