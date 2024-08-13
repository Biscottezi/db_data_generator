import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';

Future runProgram() async {
  var rand = Random();

  const int maxUser = 1000;
  const int maxProduct = 1000;
  const int maxOrder = 1000;

  //const String filepath = 'excelfile/data.xlsx';

  var userList = createUsers(maxUser);
  var productList = createProducts(maxProduct, rand);
  var orderList = createOrders(maxOrder, rand);
  var orderDetailList = createOrderDetails(productList, orderList, rand);

  await writeToFile(generateUserScript(userList), 'users.sql');
  await writeToFile(generateProductScript(productList), 'products.sql');
  await writeToFile(generateOrderScript(orderList), 'orders.sql');
  await writeToFile(
      generateOrderDetailScript(orderDetailList), 'order_details.sql');

  var excel = Excel.createExcel();
  writeUserToExcel(excel, userList);
  writeProductToExcel(excel, productList);
  writeOrderToExcel(excel, orderList);
  writeOrderDetailToExcel(excel, orderDetailList);

  File('exced-data.xlsx')
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);
}

Future writeToFile(String content, String filename) async {
  var file = File(filename);
  await file.writeAsString(content, flush: true);
}

String generateOrderDetailScript(List<OrderDetail> orderDetailList) {
  var script =
      'INSERT INTO order_details (id, order_id, price, product_id, quantity)\nVALUES\n';
  for (int i = 0; i < orderDetailList.length; ++i) {
    var od = orderDetailList[i];
    script +=
        '\t(${od.id}, ${od.orderId}, ${od.price}, ${od.productId}, ${od.quantity})${i == orderDetailList.length - 1 ? ';' : ','}\n';
  }
  //script += ');';
  return script;
}

void writeOrderDetailToExcel(Excel excel, List<OrderDetail> orderDetailList) {
  for (var od in orderDetailList) {
    excel.appendRow(
      'order_details',
      [
        od.id,
        od.orderId,
        od.price,
        od.productId,
        od.quantity,
      ],
    );
  }
}

List<OrderDetail> createOrderDetails(
    List<Product> productList, List<Order> orderList, Random rand) {
  var orderDetailList = <OrderDetail>[];
  int i = 1;
  for (var order in orderList) {
    var product1 = productList[rand.nextInt(productList.length)];
    var product2 = productList[rand.nextInt(productList.length)];

    var od1 = OrderDetail(
      id: i,
      orderId: order.id,
      price: rand.nextInt(order.totalPrice - 1) + 1,
      productId: product1.id,
      quantity: rand.nextInt(10) + 1,
    );
    orderDetailList.add(od1);
    ++i;

    var od2 = OrderDetail(
      id: i,
      orderId: order.id,
      price: order.totalPrice - od1.price,
      productId: product2.id,
      quantity: rand.nextInt(10) + 1,
    );
    orderDetailList.add(od2);
    ++i;
  }
  return orderDetailList;
}

String generateOrderScript(List<Order> orderList) {
  var script =
      'INSERT INTO orders (id, user_id, date, note, total_price)\nVALUES\n';
  for (int i = 0; i < orderList.length; ++i) {
    var order = orderList[i];
    script +=
        '\t(${order.id}, ${order.userId}, ${order.date}, ${order.note}, ${order.totalPrice})${i == orderList.length - 1 ? ';' : ','}\n';
  }
  //script += ');';
  return script;
}

void writeOrderToExcel(Excel excel, List<Order> orderList) {
  for (var order in orderList) {
    excel.appendRow(
      'orders',
      [
        order.id,
        order.userId,
        order.date,
        order.note,
        order.totalPrice,
      ],
    );
  }
}

List<Order> createOrders(int count, Random rand) {
  var orderList = <Order>[];
  for (int i = 1; i <= count; ++i) {
    var now = DateTime.now();
    var order = Order(
      id: i,
      userId: i,
      date: '${now.year}-${now.month}-${now.day}',
      note: 'Note for Order $i',
      totalPrice: rand.nextInt(500000) + 1,
    );
    orderList.add(order);
  }
  return orderList;
}

String generateProductScript(List<Product> productList) {
  var script =
      'INSERT INTO products (id, name, description, quantity)\nVALUES\n';
  for (int i = 0; i < productList.length; ++i) {
    var product = productList[i];
    script +=
        '\t(${product.id}, ${product.name}, ${product.description}, ${product.quantity})${i == productList.length - 1 ? ';' : ','}\n';
  }
  //script += ');';
  return script;
}

void writeProductToExcel(Excel excel, List<Product> productList) {
  for (var product in productList) {
    excel.appendRow(
      'products',
      [
        product.id,
        product.name,
        product.description,
        product.quantity,
      ],
    );
  }
}

List<Product> createProducts(int count, Random rand) {
  var productList = <Product>[];
  for (int i = 1; i <= count; ++i) {
    var product = Product(
      id: i,
      name: 'Product $i',
      description: 'Description $i',
      quantity: rand.nextInt(500) + 1,
    );
    productList.add(product);
  }
  return productList;
}

String generateUserScript(List<User> userList) {
  var script =
      'INSERT INTO users (id, name, address, username, password, phone_number)\nVALUES\n';
  for (int i = 0; i < userList.length; ++i) {
    var user = userList[i];
    script +=
        '\t(${user.id}, ${user.name}, ${user.address}, ${user.username}, ${user.password}, ${user.phoneNumber})${i == userList.length - 1 ? ';' : ','}';
  }
  //script += ');';
  return script;
}

void writeUserToExcel(Excel excel, List<User> userList) {
  for (var user in userList) {
    excel.appendRow(
      'users',
      [
        user.id,
        user.name,
        user.address,
        user.username,
        user.password,
        user.phoneNumber,
      ],
    );
  }
}

List<User> createUsers(int count) {
  var userList = <User>[];
  for (int i = 1; i <= count; ++i) {
    var user = User(
      id: i,
      name: 'User $i',
      address: 'Address $i',
      username: 'Username $i',
      password: '111111',
      phoneNumber: '0123456789',
    );
    userList.add(user);
  }
  return userList;
}

class User {
  int id;
  String name;
  String address;
  String username;
  String password;
  String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.address,
    required this.username,
    required this.password,
    required this.phoneNumber,
  });
}

class Product {
  int id;
  String name;
  int quantity;
  String description;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
  });
}

class Order {
  int id;
  int userId;
  int totalPrice;
  String date;
  String note;

  Order({
    required this.id,
    required this.userId,
    required this.date,
    required this.note,
    required this.totalPrice,
  });
}

class OrderDetail {
  int id;
  int orderId;
  int productId;
  int quantity;
  int price;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.price,
    required this.productId,
    required this.quantity,
  });
}
