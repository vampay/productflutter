import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:product/Page/EditProductPage.dart';
import 'dart:math';
import 'package:product/controllers/auth_controller.dart';
import 'package:product/models/user_model.dart';
import 'package:product/providers/user_provider.dart';
import 'package:product/models/product_model.dart';
import 'package:product/controllers/product_controller.dart';
import 'package:provider/provider.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<ProductModel> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
              },
            ),
            TextButton(
              child: const Text('ออกจากระบบ'),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false)
                    .onLogout(); // เรียกฟังก์ชัน logout จาก controller

                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchProducts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final productList = await ProductController().getProducts(context);
      setState(() {
        products = productList;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching products: $error';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching products: $error')));
    }
  }

  void updateProduct(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: product),
      ),
    );
  }

  Future<void> deleteProduct(ProductModel product) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบสินค้า'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบสินค้านี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false); // ปิดกล่องและส่งค่ากลับ false
              },
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () {
                Navigator.of(context).pop(true); // ปิดกล่องและส่งค่ากลับ true
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final response =
            await ProductController().deleteProduct(context, product.id);

        if (response.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/admin');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('ลบสินค้าสำเร็จ')));
          await _fetchProducts();
        } else if (response.statusCode == 401) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Refresh token expired. Please login again.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'จัดการสินค้า',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        backgroundColor: Color(0xff2196F3), // Blue background for AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white), // Change icon color to white
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // White background for the body
              Colors.white,
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * .1),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'จัดการ',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff0D47A1), // Darker blue
                    ),
                    children: [
                      TextSpan(
                        text: 'สินค้า',
                        style: TextStyle(
                            color: Color(0xff64B5F6), // Light blue
                            fontSize: 35),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Column(
                      children: [
                        Text(
                          'Access Token : ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${userProvider.accessToken}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff0D47A1), // Darker blue
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Refresh Token : ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${userProvider.refreshToken}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff64B5F6), // Light blue
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            AuthController().refreshToken(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0D47A1), // Darker blue
                          ),
                          child: Text(
                            'Update Token',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                // Button to add new product
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_product');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0D47A1), // Darker blue
                  ),
                  child: Text(
                    'เพิ่มสินค้าใหม่',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                // Products List
                if (isLoading)
                  CircularProgressIndicator()
                else if (errorMessage != null)
                  Text(errorMessage!)
                else
                  _buildProductList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: List.generate(products.length, (index) {
        final product = products[index];
        return Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 225, 215, 183),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0D47A1)), // Darker blue
                    ),
                    Text(
                      'ประเภท: ${product.productType}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'ราคา: \$${product.price}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'หน่วย: ${product.unit}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Edit and Delete buttons
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Color(0xff64B5F6), // Light blue
                ),
                onPressed: () {
                  updateProduct(product); // เรียกฟังก์ชันแก้ไข
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Color(0xff0D47A1), // Darker blue
                ),
                onPressed: () {
                  deleteProduct(product); // เรียกฟังก์ชันลบ
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
