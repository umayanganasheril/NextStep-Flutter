import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = true; // Start true while checking auth state
  String? _error;
  bool _isAuthenticated = false;
  bool _isGuest = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      _isLoading = true;
      notifyListeners();

      if (firebaseUser == null) {
        _user = null;
        _isAuthenticated = false;
        _isGuest = false;
      } else {
        if (firebaseUser.isAnonymous) {
          _isGuest = true;
          _isAuthenticated = true;
          _user = UserModel(
            uid: firebaseUser.uid,
            displayName: 'Guest User',
            email: 'guest@nextstep.app',
            profileComplete: true,
            technicalSkills: ['Flutter', 'Python', 'JavaScript', 'React', 'SQL'],
            careerInterests: ['Software Engineering', 'Mobile Development'],
            university: 'University of Colombo',
            degreeProgram: 'Computer Science',
            yearOfStudy: '3rd Year',
          );
        } else {
          _isGuest = false;
          _isAuthenticated = true;
          // Fetch from Firestore
          final userProfile = await _userService.getUserProfile(firebaseUser.uid);
          if (userProfile != null) {
            _user = userProfile;
          } else {
            // Fallback if profile doesn't exist yet
            _user = UserModel(
              uid: firebaseUser.uid,
              displayName: firebaseUser.displayName ?? 'User',
              email: firebaseUser.email ?? '',
            );
          }
        }
      }
      
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Sign in as guest using Firebase Anonymous Auth
  Future<bool> signInAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInAnonymously();
      return true; // authStateChanges will handle the rest
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Failed to continue as guest';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to continue as guest';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        await cred.user!.updateDisplayName(name);
        
        final newUser = UserModel(
          uid: cred.user!.uid,
          displayName: name,
          email: email,
        );
        
        await _userService.saveUserProfile(newUser);
        
        // Sign out immediately so the user is forced to log in manually
        await _auth.signOut();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign up failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Sign up failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (cred.user != null) {
        final userProfile = await _userService.getUserProfile(cred.user!.uid);
        if (userProfile != null) {
          _user = userProfile;
        } else {
          _user = UserModel(
            uid: cred.user!.uid,
            displayName: cred.user!.displayName ?? 'User',
            email: cred.user!.email ?? '',
          );
        }
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        _error = 'Invalid email or password. If you are a new user, please create an account.';
      } else {
        _error = e.message ?? 'Sign in failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;
    notifyListeners();
    // Save the updated profile to Firestore
    if (!_isGuest) {
      await _userService.saveUserProfile(updatedUser);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _error = 'Failed to sign out';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
