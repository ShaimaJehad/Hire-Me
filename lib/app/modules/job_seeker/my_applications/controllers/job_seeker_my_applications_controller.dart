import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobSeekerMyApplicationsController extends GetxController {
  final applications = <String, Map<String, dynamic>>{}.obs;
  final isLoading = false.obs;
  final selectedTab = 'All'.obs;
  final tabs = ['All', 'Pending', 'Accepted', 'Rejected'];

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appSub;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  void loadApplications() {
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _appSub = _firestore
        .collection('applications')
        .where('seekerId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          final map = <String, Map<String, dynamic>>{};
          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            map[doc.id] = data;
          }
          applications.value = map;
          isLoading.value = false;
        }, onError: (_) {
          isLoading.value = false;
        });
  }

  List<Map<String, dynamic>> get filteredApplications {
    final list = applications.values.toList();
    if (selectedTab.value == 'All') return list;
    final filter = selectedTab.value.toLowerCase();
    return list.where((a) {
      final status = (a['status'] as String? ?? '').toLowerCase();
      return status == filter;
    }).toList();
  }

  void selectTab(String tab) => selectedTab.value = tab;

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8A8A9A);
    }
  }

  @override
  void onClose() {
    _appSub?.cancel();
    super.onClose();
  }
}
