import 'package:flutter/material.dart';

void main() {
  runApp(const RealDeliveryApp());
}

// نموذج الطلب الحقيقي
class OrderModel {
  final String id;
  final String clientName;
  final String address;
  final String itemName;
  final double price;
  String status; // 'pending' (قيد الانتظار), 'delivering' (جاري التوصيل), 'completed' (تم التسليم)

  OrderModel({
    required this.id,
    required this.clientName,
    required this.address,
    required this.itemName,
    required this.price,
    this.status = 'pending',
  });
}

class RealDeliveryApp extends StatefulWidget {
  const RealDeliveryApp({super.key});

  @override
  State<RealDeliveryApp> createState() => _RealDeliveryAppState();
}

class _RealDeliveryAppState extends State<RealDeliveryApp> {
  // قائمة الطلبات المشتركة (قاعدة بيانات محلية حية داخل الذاكرة للتطبيق)
  final List<OrderModel> _orders = [];

  // إضافة طلب جديد
  void _addOrder(String clientName, String address, String itemName, double price) {
    setState(() {
      _orders.add(OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
        clientName: clientName,
        address: address,
        itemName: itemName,
        price: price,
      ));
    });
  }

  // تحديث حالة الطلب
  void _updateOrderStatus(String orderId, String newStatus) {
    setState(() {
      final order = _orders.firstWhere((o) => o.id == orderId);
      order.status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق التوصيل السريع',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Cairo', // أو أي خط افتراضي
      ),
      home: HomeScreen(
        orders: _orders,
        onAddOrder: _addOrder,
        onUpdateStatus: _updateOrderStatus,
      ),
    );
  }
}

// الشاشة الرئيسية للاختيار بين واجهة العميل وواجهة المندوب
class HomeScreen extends StatelessWidget {
  final List<OrderModel> orders;
  final Function(String, String, String, double) onAddOrder;
  final Function(String, String) onUpdateStatus;

  const HomeScreen({
    super.key,
    required this.orders,
    required this.onAddOrder,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام توصيل الطلبات الحقيقي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.local_shipping, size: 100, color: Colors.orange),
            const SizedBox(height: 30),
            const Text(
              'اختر واجهة الاستخدام:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person),
              label: const Text('واجهة العميل (طلب منتج)', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientScreen(onAddOrder: onAddOrder, orders: orders),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delivery_dining),
              label: const Text('واجهة المندوب (توصيل الطلبات)', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryScreen(orders: orders, onUpdateStatus: onUpdateStatus),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 1. واجهة العميل ----------------
class ClientScreen extends StatefulWidget {
  final Function(String, String, String, double) onAddOrder;
  final List<OrderModel> orders;

  const ClientScreen({super.key, required this.onAddOrder, required this.orders});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();

  void _submitOrder() {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _itemController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع الحقول')),
      );
      return;
    }

    widget.onAddOrder(
      _nameController.text,
      _addressController.text,
      _itemController.text,
      double.parse(_priceController.text),
    );

    _nameController.clear();
    _addressController.clear();
    _itemController.clear();
    _priceController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال الطلب بنجاح وإرساله للمندوبين!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب ديلفري جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'عنوان التوصيل بالتفصيل', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(labelText: 'الطلب (مثال: وجبة برجر + كولا)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعر الإجمالي ($)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: _submitOrder,
              child: const Text('إرسال الطلب الآن', style: TextStyle(fontSize: 16)),
            ),
            const Divider(height: 40),
            const Text('طلباتي الحالية وحالتها:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...widget.orders.map((order) => Card(
                  child: ListTile(
                    title: Text(order.itemName),
                    subtitle: Text('العنوان: ${order.address}\nالحالة: ${_getStatusText(order.status)}'),
                    trailing: Text('\$${order.price}'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    if (status == 'pending') return 'قيد الانتظار (يبحث عن مندوب)';
    if (status == 'delivering') return 'جاري التوصيل بالطريق إليك';
    if (status == 'completed') return 'تم التوصيل بنجاح ✅';
    return status;
  }
}

// ---------------- 2. واجهة المندوب ----------------
class DeliveryScreen extends StatelessWidget {
  final List<OrderModel> orders;
  final Function(String, String) onUpdateStatus;

  const DeliveryScreen({super.key, required this.orders, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المندوب (الطلبات المتاحة)')),
      body: orders.isEmpty
          .toString() == 'true' && orders.isEmpty
          ? const Center(child: Text('لا توجد طلبات جديدة حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('رقم الطلب: #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Chip(
                              label: Text(order.status, style: const TextStyle(color: Colors.white)),
                              backgroundColor: _getStatusColor(order.status),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text('العميل: ${order.clientName}', style: const TextStyle(fontSize: 16)),
                        Text('العنوان: ${order.address}', style: const TextStyle(fontSize: 16)),
                        Text('الطلب: ${order.itemName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('السعر: \$${order.price}', style: const TextStyle(color: Colors.green, fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (order.status == 'pending')
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                icon: const Icon(Icons.delivery_dining),
                                label: const Text('قبول وبدء التوصيل'),
                                onPressed: () => onUpdateStatus(order.id, 'delivering'),
                              ),
                            if (order.status == 'delivering')
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                icon: const Icon(Icons.check),
                                label: const Text('تأكيد التسليم'),
                                onPressed: () => onUpdateStatus(order.id, 'completed'),
                              ),
                            if (order.status == 'completed')
                              const Text('تم إكمال الطلب بنجاح', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Colors.orange;
    if (status == 'delivering') return Colors.blue;
    if (status == 'completed') return Colors.green;
    return Colors.grey;
  }
}