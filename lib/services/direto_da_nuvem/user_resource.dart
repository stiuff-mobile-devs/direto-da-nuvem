import 'package:ddnuvem/services/connection_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddnuvem/models/user.dart';
import 'package:hive/hive.dart';

class UserResource {
  static String collection = "users";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<User> _hiveBox = Hive.box<User>(collection);

  Future<List<User>> getAll() async {
    List<User> users = [];
    try {
      if (kIsWeb || await ConnectionService.isConnected()) {
        final list = await _firestore.collection(collection).get();

        for (var doc in list.docs) {
          User user = User.fromMap(doc.data(), doc.id);
          users.add(user);
          _saveToLocalDB(user);
        }
      } else {
        users = _getAllFromLocalDB();
      }
      return users;
    } catch (e) {
      debugPrint("Error on list all users: $e");
      return [];
    }
  }

  Stream<List<User>> getAllStream() {
    return _firestore.collection(collection).snapshots().map((e) {
      try {
        for (var change in e.docChanges) {
          switch (change.type) {
            case (DocumentChangeType.added || DocumentChangeType.modified) :
              final user = User.fromMap(change.doc.data()!, change.doc.id);
              _saveToLocalDB(user);
              break;
            case DocumentChangeType.removed:
              _deleteFromLocalDB(change.doc.id);
              break;
          }
        }

        return e.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        debugPrint("Error on list all users stream: $e");
        return [];
      }
    });
  }

  create(User user) async {
    try {
      if (await get(user.email) != null) {
        throw Exception("Usuário já existe.");
      }
      await _firestore.collection(collection).add(user.toMap());
    } on Exception catch (e) {
      if (e.toString().contains("Usuário já existe.")) {
        rethrow;
      } else {
        debugPrint("Error on create user: $e");
        throw Exception("Erro ao criar usuário.");
      }
    }
  }

  createAuthenticatedUser(User user) async {
    try {
      await _firestore.doc("$collection/${user.id}").set(user.toMap());
    } catch (e) {
      debugPrint("Error on create authenticated user: $e");
    }
  }

  delete(User user) async {
    try {
      await _firestore.doc("$collection/${user.id}").delete();
    } catch (e) {
      debugPrint("Error on delete user: $e");
      throw Exception("Erro ao excluir usuário.");
    }
  }

  Future<User?> get(String email) async {
    User? user;
    try {
      if (kIsWeb || await ConnectionService.isConnected()) {
        final query = await _firestore
            .collection(collection)
            .where('email', isEqualTo: email)
            .get();

        if (query.docs.isEmpty) return null;
        final doc = query.docs.first;
        user = User.fromMap(doc.data(), doc.id);
      } else {
        user = _getFromLocalDB(email);
      }
      return user;
    } catch (e) {
      debugPrint("Error on get user: $e");
      return null;
    }
  }

  update(User user) async {
    try {
      var doc = await _firestore.doc("$collection/${user.id}").get();
      if (!doc.exists) return;
      await _firestore.doc("$collection/${user.id}").update(user.toMap());
    } catch (e) {
      debugPrint("Error on update user: $e");
      throw Exception("Erro ao atualizar usuário.");
    }
  }

  // Hive
  _saveToLocalDB(User user) {
    if (kIsWeb) return;
    try {
      _hiveBox.put(user.id, user);
    } catch (e) {
      debugPrint("Error on save user ${user.id} to Hive: $e.");
    }
  }

  _deleteFromLocalDB(String id) {
    if (kIsWeb) return;
    try {
      _hiveBox.delete(id);
    } catch (e) {
      debugPrint("Error on delete user $id from Hive: $e.");
    }
  }

  User? _getFromLocalDB(String email) {
    try {
      return _hiveBox.values.firstWhere((u) => u.email == email);
    } catch (e) {
      debugPrint("Error on get user $email from Hive: $e.");
      return null;
    }
  }

  List<User> _getAllFromLocalDB() {
    try {
      return _hiveBox.values.toList();
    } catch (e) {
      debugPrint("Error on list all users from Hive: $e.");
      return [];
    }
  }
}
