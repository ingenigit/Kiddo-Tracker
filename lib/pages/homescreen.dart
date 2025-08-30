import 'package:flutter/material.dart';
import 'package:kiddo_tracker/model/child.dart';
import 'package:kiddo_tracker/widget/sqflitehelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final SqfliteHelper _dbHelper = SqfliteHelper();
  List<Child> children = [];
  bool _isLoading = true;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _fetchChildren();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : children.isEmpty
                ? const Center(
                    child: Text(
                      'No children found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(child.name.isNotEmpty ? child.name[0] : '?'),
                          ),
                          title: Text(child.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${child.class_name} - ${child.school}'),
                              Text('Age: ${child.age} | Gender: ${child.gender}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _fetchChildren() async {
    try {
      // Hardcoded user ID for demonstration - in a real app, this would come from user session
      final int userId = 8456029772; 
      
      final List<Map<String, dynamic>> childrenData = await _dbHelper.getChildren(userId);
      
      setState(() {
        children = childrenData.map((childData) => Child.fromJson(childData)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching children: $e');
    }
  }
}
