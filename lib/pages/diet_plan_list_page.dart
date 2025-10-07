import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import 'diet_plan_detail_page.dart';

class DietPlanListPage extends StatefulWidget {
  const DietPlanListPage({super.key});

  @override
  State<DietPlanListPage> createState() => _DietPlanListPageState();
}

class _DietPlanListPageState extends State<DietPlanListPage> {
  List<Map<String, dynamic>> dietPlans = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadDietPlans();
  }

  Future<void> loadDietPlans() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // Try to load from API first
      List<Map<String, dynamic>> plans = await ApiService.getDietPlans();

      // If API fails, load from local JSON
      if (plans.isEmpty) {
        final String jsonString = await rootBundle.loadString(
          'assets/data/diet_plans.json',
        );
        final List<dynamic> jsonData = json.decode(jsonString);
        plans = jsonData.cast<Map<String, dynamic>>();
      }

      if (mounted) {
        setState(() {
          dietPlans = plans;
          isLoading = false;
        });

        // Update app state
        appState.setDietPlans(plans);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load diet plans: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPlans() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }
    await loadDietPlans();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plans', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(7, 58, 74, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshPlans),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading diet plans...'),
                ],
              ),
            );
          }

          if (errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshPlans,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (dietPlans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No diet plans available'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPlans,
            child: Column(
              children: [
                // Connection status indicator
                if (!appState.isConnected)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange[100],
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Text(
                          'Offline mode - Showing cached data',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ],
                    ),
                  ),

                // Diet plans list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dietPlans.length,
                    itemBuilder: (context, index) {
                      final plan = dietPlans[index];
                      return DietPlanCard(
                        plan: plan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DietPlanDetailPage(plan: plan),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DietPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onTap;

  const DietPlanCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                plan['image'] ?? 'asset/diet-planner.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plan['title'] ?? 'Unknown Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (plan['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4A019).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan['category'],
                            style: const TextStyle(
                              color: Color(0xFFF4A019),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    plan['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Details row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Duration and Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                plan['duration'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan['price'] ?? 'Contact for price',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0993A3),
                            ),
                          ),
                        ],
                      ),

                      // Rating and Arrow
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (plan['rating'] != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  plan['rating'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (plan['reviews'] != null)
                                  Text(
                                    ' (${plan['reviews']})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFFF4A019),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
