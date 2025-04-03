import 'package:ecomerce_app/models/cartitems_model.dart';
import 'package:ecomerce_app/models/product_model.dart';
import 'package:ecomerce_app/repository/cart_repository.dart';
import 'package:ecomerce_app/repository/product_repository.dart';
import 'package:ecomerce_app/repository/user_repository.dart';
import 'package:ecomerce_app/screens/product/variant/add_variant_screen.dart';
import 'package:ecomerce_app/utils/image_utils.dart';
import 'package:ecomerce_app/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool fromDashboard;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.fromDashboard = false,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _productRepo = ProductRepository();
  final uuid = Uuid();
  final UserRepository _userRepo = UserRepository();
  late List<ProductModel> variants = [];
  bool isLoading = true;
  int _currentImageIndex = 0;
  late PageController _pageController;
  String? selectedOption;
  int quantity = 1;
  bool isBuyNow = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
    selectedOption = widget.product.productName;
    _loadVariants();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadVariants() async {
    setState(() => isLoading = true);

    if (widget.product.id != null) {
      variants = await _productRepo.getVariants(widget.product.id!);
    }

    setState(() => isLoading = false);
  }

  void onChat() {
    print("Chuyển đến trang thanh toán!");
  }

  void _bottomSheet(bool isBuyNow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              child: Image.network(
                                widget.product.images.first,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 24,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 0),
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 34,
                            top: 8,
                            bottom: 48,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.product.price)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Còn lại: ${widget.product.stock}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 0.3,
                color: Colors.grey,
                margin: EdgeInsets.symmetric(vertical: 8),
              ),

              if (variants.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phân loại",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = widget.product.productName;
                            });
                          },
                          child: _buildVariantOption(
                            widget.product,
                            selectedOption == widget.product.productName,
                          ),
                        ),
                        ...variants.map((variant) {
                          bool isSelected =
                              selectedOption == variant.productName;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = variant.productName;
                              });
                            },
                            child: _buildVariantOption(variant, isSelected),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 0.3,
                  color: Colors.grey,
                  margin: EdgeInsets.symmetric(vertical: 8),
                ),
              ],

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Số lượng", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (quantity < widget.product.stock) {
                            setState(() {
                              quantity++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (!isBuyNow) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final cartRepo = CartRepository();
                      final cart = await cartRepo.getCart(
                        _userRepo.getCurrentUserId()!,
                      );
                      final cartItem = CartItem(
                        id: uuid.v4(), // Generate unique ID
                        productId: widget.product.id!, // Add null check with !
                        productName: widget.product.productName,
                        variantName: selectedOption,
                        imageUrl:
                            widget.product.images.isNotEmpty
                                ? widget.product.images[0]
                                : null,
                        price: widget.product.price,
                        quantity: quantity,
                        discountRate: widget.product.discount,
                      );
                      await cartRepo.addItem(cart, cartItem);
                      setState(() {
                        quantity = 1;
                      });
                      if (!mounted) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context).pop();
                          });
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 50,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Đã thêm vào giỏ hàng',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Thêm vào Giỏ hàng",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Mua ngay: ${selectedOption ?? ''} x$quantity");
                      print("Số lượng biến thể: ${variants.length}");
                      Navigator.pop(context);
                      // chuyển đến trang thanh toán
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Mua ngay",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.productName),
        backgroundColor:
            widget.fromDashboard ? const Color(0xFF7AE582) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImages(
              widget.product,
              _currentImageIndex,
              (index) => setState(() => _currentImageIndex = index),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 20),

                if (widget.product.discount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '- ${widget.product.discount}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (widget.product.discount > 0) ...[
                  Text(
                    Utils.formatCurrency(
                      widget.product.price *
                          (1 - widget.product.discount / 100),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Utils.formatCurrency(widget.product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ] else
                  Text(
                    Utils.formatCurrency(widget.product.price),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),
            Utils.buildStarRating(widget.product.rating),

            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle("Mô tả"),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        (widget.product.description ?? 'Không có mô tả')
                            .split('•')
                            .where((e) => e.trim().isNotEmpty)
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "• $e".trim(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (variants.isNotEmpty) ...[
              buildSectionTitle("Biến thể"),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  final variant = variants[index];
                  return Card(
                    child: ListTile(
                      leading: ImageUtils.buildImage(variant.images.first),
                      title: Text(variant.productName),
                      subtitle: Text(Utils.formatCurrency(variant.price)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  product: variant,
                                  fromDashboard: true,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle("Biến thể"),
                  const SizedBox(height: 8),
                  const Text(
                    "Sản phẩm này không có biến thể.",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            if (!widget.fromDashboard && widget.product.parentId == null)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newVariant = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddVariantScreen(
                                parentProduct: widget.product,
                              ),
                        ),
                      );

                      if (newVariant != null) {
                        _loadVariants();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7AE582),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Thêm biến thể",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 50, // Set fixed height
                color: Color(0xFF20A39E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                      ),
                      onPressed: onChat,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white,
                    ), // Đường kẻ dọc
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                      //Thêm vào giỏ hàng
                      onPressed: () {
                        _bottomSheet(isBuyNow);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isBuyNow = true;
                  });
                  _bottomSheet(isBuyNow);
                },
                child: Container(
                  height: 50, // Match height with other container
                  color: Color(0xFFE63946),
                  alignment: Alignment.center,
                  child: Text(
                    "Mua ngay",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 80,
        color: Colors.grey,
      );
    }

    if (kIsWeb) {
      return const Icon(
        Icons.image_not_supported,
        size: 80,
        color: Colors.grey,
      );
    }
    // File imageFile = File(imagePath);

    // if (!imageFile.existsSync()) {
    //   return const Icon(Icons.broken_image, size: 80, color: Colors.red);
    // }

    // return Image.file(imageFile, width: 80, height: 80, fit: BoxFit.cover);
    return Image.network(imagePath, width: 80, height: 80, fit: BoxFit.cover);
  }

  Widget _buildProductImages(
    ProductModel product,
    int currentIndex,
    Function(int) onImageChanged,
  ) {
    if (product.images.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.images.length,
            onPageChanged: onImageChanged,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImage(product.images[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        if (product.images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentImageIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            currentIndex == index
                                ? Colors.green
                                : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: _buildImage(product.images[index]),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          color: const Color(0xFF7AE582),
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVariantOption(ProductModel variant, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = variant.productName;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.red : Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.red.shade50 : Colors.grey.shade200,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (variant.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  variant.images[0],
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.image_not_supported,
                  size: 12,
                  color: Colors.grey[600],
                ),
              ),
            SizedBox(width: 8),
            Text(
              variant.productName,
              style: TextStyle(color: isSelected ? Colors.red : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
