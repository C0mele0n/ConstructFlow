// lib/services/sync_service.dart
//
// SYNC SERVICE
// ============
// Handles syncing data between the local database (SQLite on the phone)
// and Firestore (cloud database). This is what makes the app work offline.
//
// HOW OFFLINE-FIRST SYNC WORKS:
// 1. User makes a change → saved to local DB immediately (always works)
// 2. If online → change is also sent to Firestore
// 3. If offline → change is queued locally
// 4. When connection returns → queued changes are pushed to Firestore
// 5. Other users' changes are pulled from Firestore to local DB
//
// KEY CONCEPTS:
// - Firestore = Google's cloud database (like a spreadsheet in the cloud)
// - Snapshots = real-time data streams (Firestore pushes updates automatically)
// - Connectivity detection = checking if the phone has internet

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  /// Check if the device currently has internet
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Stream of connectivity changes (true = online, false = offline)
  Stream<bool> get connectivityStream =>
      _connectivity.onConnectivityChanged.map(
        (result) => result != ConnectivityResult.none,
      );

  // ──────────────────────────────────────────────
  // FIRESTORE COLLECTION REFERENCES
  // ──────────────────────────────────────────────
  // Firestore is organized into "collections" (like tables)
  // Each collection contains "documents" (like rows)

  CollectionReference get _usersCollection =>
      _firestore.collection('users');

  CollectionReference get _projectsCollection =>
      _firestore.collection('projects');

  CollectionReference _measurementsCollection(String projectId) =>
      _projectsCollection.doc(projectId).collection('measurements');

  CollectionReference _cutsCollection(String projectId) =>
      _projectsCollection.doc(projectId).collection('cuts');

  CollectionReference _materialsCollection(String projectId) =>
      _projectsCollection.doc(projectId).collection('materials');

  CollectionReference _costsCollection(String projectId) =>
      _projectsCollection.doc(projectId).collection('costs');

  CollectionReference _installationsCollection(String projectId) =>
      _projectsCollection.doc(projectId).collection('installations');

  // ──────────────────────────────────────────────
  // GENERIC CRUD OPERATIONS
  // ──────────────────────────────────────────────

  /// Save a document to Firestore
  Future<void> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  /// Get a single document from Firestore
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  /// Delete a document from Firestore
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  /// Get real-time stream of a collection
  /// The UI will auto-update whenever data changes
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Get real-time stream of a subcollection
  Stream<QuerySnapshot> getSubcollectionStream(
    String collection,
    String docId,
    String subcollection,
  ) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .snapshots();
  }

  // ──────────────────────────────────────────────
  // PROJECT-SPECIFIC OPERATIONS
  // ──────────────────────────────────────────────

  /// Create a new project in Firestore
  Future<String> createProject(Map<String, dynamic> projectData) async {
    final docRef = await _projectsCollection.add(projectData);
    return docRef.id;
  }

  /// Update a project in Firestore
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    await _projectsCollection.doc(projectId).update(data);
  }

  /// Get real-time stream of a project's crew subcollection
  Stream<QuerySnapshot> getProjectMeasurements(String projectId) {
    return _measurementsCollection(projectId).snapshots();
  }

  Stream<QuerySnapshot> getProjectCuts(String projectId) {
    return _cutsCollection(projectId).snapshots();
  }

  Stream<QuerySnapshot> getProjectMaterials(String projectId) {
    return _materialsCollection(projectId).snapshots();
  }

  Stream<QuerySnapshot> getProjectCosts(String projectId) {
    return _costsCollection(projectId).snapshots();
  }

  Stream<QuerySnapshot> getProjectInstallations(String projectId) {
    return _installationsCollection(projectId).snapshots();
  }
}
