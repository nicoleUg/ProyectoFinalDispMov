import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurantesaas_design_system/restaurantesaas_design_system.dart';
import '../bloc/admin_menu_bloc.dart';
import '../bloc/admin_menu_event.dart';
import '../bloc/admin_menu_state.dart';
import '../../../menu/domain/entities/product_entity.dart';

class EditarProductoAppAdmin extends StatefulWidget {
  final ProductEntity product;

  const EditarProductoAppAdmin({super.key, required this.product});

  @override
  State<EditarProductoAppAdmin> createState() => _EditarProductoAppAdminState();
}

class _EditarProductoAppAdminState extends State<EditarProductoAppAdmin> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  
  String? _selectedCategoryId;
  String? _localImagePath;
  late bool _isAvailable;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _selectedCategoryId = widget.product.categoryId;
    _isAvailable = widget.product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _localImagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: \$e'),
          backgroundColor: RSColors.error,
        ),
      );
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: RSColors.primary,
          ),
        );
        return;
      }

      final price = double.tryParse(_priceController.text) ?? 0.0;

      context.read<AdminMenuBloc>().add(
            UpdateProductRequested(
              productId: widget.product.id,
              categoryId: _selectedCategoryId!,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: price,
              localImagePath: _localImagePath,
              isAvailable: _isAvailable,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RSColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Editar Producto',
          style: RSTypography.titleLarge.copyWith(color: Colors.black87),
        ),
      ),
      body: BlocConsumer<AdminMenuBloc, AdminMenuState>(
        listener: (context, state) {
          if (state is AdminMenuActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(); // Return to menu list
          }
          if (state is AdminMenuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: RSColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminMenuLoading;

          List<dynamic> categories = [];
          if (context.read<AdminMenuBloc>().state is AdminMenuLoaded) {
            categories = (context.read<AdminMenuBloc>().state as AdminMenuLoaded).categories;
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: RSSpacing.md,
                  right: RSSpacing.md,
                  top: RSSpacing.lg,
                  bottom: 100, // Padding for bottom action bar
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Picker Area
                          Text(
                            'Imagen del Producto',
                            style: RSTypography.labelLarge.copyWith(color: RSColors.textOnSurfaceVariant),
                          ),
                          RSSpacing.verticalSm,
                          GestureDetector(
                            onTap: isLoading ? null : _pickImage,
                            child: AspectRatio(
                              aspectRatio: 21 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: RSColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: RSColors.outlineVariant,
                                    width: 1,
                                  ),
                                  image: _localImagePath != null
                                      ? DecorationImage(
                                          image: kIsWeb
                                              ? NetworkImage(_localImagePath!)
                                              : FileImage(File(_localImagePath!)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(widget.product.imageUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                ),
                                child: _localImagePath == null && (widget.product.imageUrl == null || widget.product.imageUrl!.isEmpty)
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo,
                                              color: RSColors.primary,
                                              size: 28,
                                            ),
                                          ),
                                          RSSpacing.verticalSm,
                                          Text(
                                            'Subir o seleccionar imagen',
                                            style: RSTypography.titleMedium.copyWith(color: Colors.black87),
                                          ),
                                          Text(
                                            'Recomendado: 1200 x 800px (JPG, PNG)',
                                            style: RSTypography.labelSmall.copyWith(color: RSColors.textOnSurfaceVariant),
                                          ),
                                        ],
                                      )
                                    : Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.edit, color: Colors.white, size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                'Cambiar imagen',
                                                style: TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          RSSpacing.verticalLg,

                          // Product details card container
                          RSCard(
                            padding: const EdgeInsets.all(RSSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detalles del Plato',
                                  style: RSTypography.titleMedium.copyWith(color: Colors.black87),
                                ),
                                RSSpacing.verticalLg,

                                // Name Input
                                RSTextField(
                                  controller: _nameController,
                                  labelText: 'Nombre del plato *',
                                  enabled: !isLoading,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El nombre es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                RSSpacing.verticalMd,

                                // Description Input
                                RSTextField(
                                  controller: _descriptionController,
                                  labelText: 'Descripción',
                                  enabled: !isLoading,
                                  maxLines: 3,
                                ),
                                RSSpacing.verticalMd,

                                // Category Dropdown
                                Text(
                                  'Categoría *',
                                  style: RSTypography.bodyMedium.copyWith(color: RSColors.textOnSurfaceVariant),
                                ),
                                RSSpacing.verticalXs,
                                DropdownButtonFormField<String>(
                                  value: _selectedCategoryId,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F2),
                                    border: const UnderlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(8.0),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: RSSpacing.md,
                                      vertical: RSSpacing.sm,
                                    ),
                                  ),
                                  items: categories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    );
                                  }).toList(),
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _selectedCategoryId = value;
                                          });
                                        },
                                ),
                                RSSpacing.verticalLg,

                                // Price Input
                                RSTextField(
                                  controller: _priceController,
                                  labelText: 'Precio base *',
                                  keyboardType: TextInputType.number,
                                  enabled: !isLoading,
                                  prefixIcon: const Icon(Icons.attach_money),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El precio es obligatorio';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'El precio debe ser un número válido';
                                    }
                                    return null;
                                  },
                                ),
                                RSSpacing.verticalLg,

                                // Availability Toggle
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: RSSpacing.md,
                                    vertical: RSSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: RSColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Disponible para venta',
                                            style: RSTypography.titleSmall.copyWith(color: Colors.black87),
                                          ),
                                          Text(
                                            'El producto será visible en el menú inmediatamente.',
                                            style: RSTypography.labelSmall.copyWith(color: RSColors.textOnSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: _isAvailable,
                                        onChanged: isLoading
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _isAvailable = value;
                                                });
                                              },
                                        activeColor: RSColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Fixed Bottom Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: const EdgeInsets.all(RSSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(
                      top: BorderSide(color: RSColors.outlineVariant, width: 1.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RSButton.tonal(
                        label: 'Cancelar',
                        onPressed: isLoading ? null : () => context.pop(),
                      ),
                      RSSpacing.horizontalMd,
                      RSButton.filled(
                        label: 'Guardar Cambios',
                        isLoading: isLoading,
                        icon: const Icon(Icons.save, size: 18),
                        onPressed: isLoading ? null : _saveProduct,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
