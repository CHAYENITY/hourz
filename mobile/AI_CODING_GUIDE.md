# 🤖 AI Coding Guide - Hourz Flutter

## 📋 Quick Reference

**Tech Stack:** Flutter + Riverpod + Freezed + Go Router + Dio + Lucide Icons
**Architecture:** Feature-based with shared global services  
**Pattern:** Immutable models, Type-safe navigation, Centralized error handling

---

## ⚡ Quick Tips

1. **Always use `@freezed`** for models & form state (never `@immutable`)
2. **Use `.select()`** when watching providers to prevent unnecessary rebuilds
3. **Handle errors & loading** with `errorProvider` and `loadingProvider` (always try-catch)
4. **Separate widgets into files** - no `_PrivateWidget` in screens, use public widgets
5. **Use `ref.read()`** in callbacks/actions, `ref.watch()` only in build method
6. **Import shortcuts**: `shared/providers/index.dart`, `shared/constants/api_endpoints.dart`
7. **Immutable updates**: `[...state, item]` not `state.add(item)`
8. **Use GoRouter**: `context.go()`, `context.push()`, `context.pop()` (never Navigator)

---

## 🏗️ Project Structure

```
lib/
├── features/[feature_name]/
│   ├── screens/            # UI screens
│   ├── widgets/
│   │   ├── [feature].widget.dart    # Shared widgets (e.g., auth.widget.dart)
│   │   └── [widget_group]/          # Widget groups (e.g., login/, register/)
│   │       ├── index.dart           # Export all widgets in group
│   │       ├── [widget].widget.dart # Individual widgets
│   │       └── [nested_group]/      # Nested group (e.g., login_form_fields/)
│   │           ├── index.dart       # Export nested widgets
│   │           └── [widget].widget.dart
│   ├── providers/          # State management
│   ├── services/           # API services
│   ├── models/             # Freezed models
│   ├── feature_routes.dart # Routes
│   └── index.dart          # Exports
└── shared/                 # Global shared code
    ├── providers/          # Global state (theme, loading, error)
    ├── services/           # API service
    ├── constants/          # Routes, configs
    ├── theme/              # Color schemas
    ├── routing/            # Go Router setup
    └── widgets/            # Reusable widgets
```

---

## 🎯 Core Templates

### 1. Freezed Model

```dart
@freezed
class ModelName with _$ModelName {
  const factory ModelName({
    required String id,
    required String title,
    @Default(false) bool isActive,
    required DateTime createdAt,
  }) = _ModelName;

  const ModelName._();

  // ✅ ALWAYS use code generation for fromJson
  factory ModelName.fromJson(Map<String, dynamic> json) => _$ModelNameFromJson(json);

  // ✅ ALWAYS provide toCreateJson (exclude id, timestamps, computed fields)
  Map<String, dynamic> toCreateJson() => {
    'title': title,
    'is_active': isActive,
  };

  // ✅ ALWAYS provide toUpdateJson (same as toCreateJson in most cases)
  Map<String, dynamic> toUpdateJson() => {
    'title': title,
    'is_active': isActive,
  };

  // 💡 Optional: Add computed getters for derived values
  // String get displayStatus => isActive ? 'Active' : 'Inactive';
}

// 🚨 RULES:
// 1. Always use @freezed annotation
// 2. Always use code generation: _$ModelNameFromJson(json)
// 3. Never manually parse JSON in fromJson (let Freezed generate it)
// 4. Always provide toCreateJson/toUpdateJson for API requests
// 5. Use camelCase for Dart fields, handle snake_case in toCreateJson/toUpdateJson
```

**❌ Common Mistakes:**

```dart
// ❌ DON'T: Manual fromJson (slow, error-prone)
factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    firstName: json['first_name'] as String?,
    // ... manual mapping
  );
}

// ❌ DON'T: Missing toCreateJson/toUpdateJson
@freezed
class Gig with _$Gig {
  const factory Gig({...}) = _Gig;
  factory Gig.fromJson(Map<String, dynamic> json) => _$GigFromJson(json);
  // Missing: toCreateJson(), toUpdateJson()
}

// ❌ DON'T: Include id/timestamps in create JSON
Map<String, dynamic> toCreateJson() => {
  'id': id,  // ❌ Server generates this
  'created_at': createdAt,  // ❌ Server generates this
  'title': title,
};
```

**✅ DO: Proper Freezed Model**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';  // ✅ Required for JSON serialization

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? bio,
    @Default(false) bool isVerified,
    @Default(5.0) double reputationScore,
    DateTime? createdAt,
  }) = _User;

  const User._();

  // ✅ Code generation handles all parsing
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // ✅ For POST requests (exclude id, timestamps)
  Map<String, dynamic> toCreateJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'bio': bio,
  };

  // ✅ For PUT/PATCH requests
  Map<String, dynamic> toUpdateJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'bio': bio,
  };

  // ✅ Computed properties
  String get displayName =>
    firstName != null || lastName != null
      ? '${firstName ?? ''} ${lastName ?? ''}'.trim()
      : email.split('@').first;
}
```

### 2. Provider Pattern

```dart
import 'package:hourz/shared/providers/index.dart'; // Always import

// ============================================================================
// Service Provider (Singleton)
// ============================================================================
final modelServiceProvider = Provider<ModelService>((ref) {
  return ModelService(ref.read(apiProvider));
});

// ============================================================================
// State Provider - Use Freezed for Form State
// ============================================================================

// ✅ BEST: Use Freezed for form state (immutable, type-safe)
@freezed
class ModelFormState with _$ModelFormState {
  const factory ModelFormState({
    @Default('') String title,
    @Default(false) bool isActive,
    @Default(false) bool isValid,
  }) = _ModelFormState;
}

final modelFormProvider = StateNotifierProvider<ModelFormNotifier, ModelFormState>((ref) {
  return ModelFormNotifier(ref);
});

class ModelFormNotifier extends StateNotifier<ModelFormState> {
  ModelFormNotifier(this._ref) : super(const ModelFormState());
  final Ref _ref;

  void setTitle(String title) {
    state = state.copyWith(
      title: title,
      isValid: _validateForm(title, state.isActive),
    );
  }

  void setIsActive(bool isActive) {
    state = state.copyWith(
      isActive: isActive,
      isValid: _validateForm(state.title, isActive),
    );
  }

  bool _validateForm(String title, bool isActive) {
    return title.isNotEmpty && title.length >= 3;
  }

  void reset() {
    state = const ModelFormState();
  }
}

// ============================================================================
// List Provider - For Data Collections
// ============================================================================
final modelListProvider = StateNotifierProvider<ModelListNotifier, List<ModelName>>((ref) {
  return ModelListNotifier(ref);
});

class ModelListNotifier extends StateNotifier<List<ModelName>> {
  ModelListNotifier(this._ref) : super([]);
  final Ref _ref;

  Future<void> loadData() async {
    try {
      _ref.read(loadingProvider.notifier).startLoading('load-data');
      final service = _ref.read(modelServiceProvider);
      state = await service.getItems();
    } catch (e) {
      _ref.read(errorProvider.notifier).handleError('Failed: $e', context: 'loadData');
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('load-data');
    }
  }

  Future<void> createItem(ModelName item) async {
    try {
      _ref.read(loadingProvider.notifier).startLoading('create-item');
      final service = _ref.read(modelServiceProvider);
      final created = await service.createItem(item);
      state = [...state, created];  // ✅ Immutable update
    } catch (e) {
      _ref.read(errorProvider.notifier).handleError('Failed: $e', context: 'createItem');
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('create-item');
    }
  }

  Future<void> updateItem(ModelName item) async {
    try {
      _ref.read(loadingProvider.notifier).startLoading('update-item');
      final service = _ref.read(modelServiceProvider);
      final updated = await service.updateItem(item);
      state = state.map((i) => i.id == item.id ? updated : i).toList();  // ✅ Immutable update
    } catch (e) {
      _ref.read(errorProvider.notifier).handleError('Failed: $e', context: 'updateItem');
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('update-item');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      _ref.read(loadingProvider.notifier).startLoading('delete-item');
      final service = _ref.read(modelServiceProvider);
      await service.deleteItem(id);
      state = state.where((i) => i.id != id).toList();  // ✅ Immutable update
    } catch (e) {
      _ref.read(errorProvider.notifier).handleError('Failed: $e', context: 'deleteItem');
    } finally {
      _ref.read(loadingProvider.notifier).stopLoading('delete-item');
    }
  }
}

// ============================================================================
// Computed Providers - Use .select() for Performance
// ============================================================================

// ⚡ Only rebuilds when count changes (not when list items change)
final activeCountProvider = Provider<int>((ref) {
  return ref.watch(modelListProvider.select((models) =>
    models.where((m) => m.isActive).length
  ));
});

final totalCountProvider = Provider<int>((ref) {
  return ref.watch(modelListProvider.select((models) => models.length));
});

// ⚡ Complex computed state
final modelStatsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(modelListProvider.select((models) => {
    'total': models.length,
    'active': models.where((m) => m.isActive).length,
    'inactive': models.where((m) => !m.isActive).length,
  }));
});
```

**🚨 Common Mistakes:**

```dart
// ❌ DON'T: Use @immutable class for form state (verbose, error-prone)
@immutable
class LoginFormState {
  final String email;
  final String password;

  const LoginFormState({this.email = '', this.password = ''});

  LoginFormState copyWith({String? email, String? password}) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

// ❌ DON'T: Watch entire provider when you need one field
final user = ref.watch(userProvider);  // Rebuilds on ANY user change
final name = user.name;

// ❌ DON'T: Use ref.watch() in callbacks
onPressed: () {
  final user = ref.watch(userProvider);  // ❌ Wrong!
  doSomething(user);
}

// ❌ DON'T: Mutate state directly
state.add(newItem);  // ❌ Wrong! Mutates list

// ❌ DON'T: Miss error handling
Future<void> loadData() async {
  final service = _ref.read(modelServiceProvider);
  state = await service.getItems();  // ❌ No try-catch!
}
```

**✅ DO: Best Practices**

```dart
// ✅ Use Freezed for form state
@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default(true) bool obscurePassword,
  }) = _LoginFormState;

  const LoginFormState._();

  bool get isValid => email.isNotEmpty &&
                      email.contains('@') &&
                      password.length >= 8;
}

// ✅ Use .select() for specific fields
final email = ref.watch(loginFormProvider.select((s) => s.email));
final isValid = ref.watch(loginFormProvider.select((s) => s.isValid));

// ✅ Use ref.read() in callbacks
onPressed: () {
  final notifier = ref.read(loginFormProvider.notifier);
  notifier.submit();
}

// ✅ Immutable state updates
state = [...state, newItem];  // ✅ Creates new list
state = state.map((i) => i.id == id ? updated : i).toList();  // ✅ Immutable map

// ✅ Always handle errors
Future<void> loadData() async {
  try {
    _ref.read(loadingProvider.notifier).startLoading('load');
    final service = _ref.read(serviceProvider);
    state = await service.getData();
  } catch (e) {
    _ref.read(errorProvider.notifier).handleError('Failed: $e');
  } finally {
    _ref.read(loadingProvider.notifier).stopLoading('load');
  }
}
```

### 3. Service Pattern

```dart
import 'package:hourz/shared/constants/api_endpoints.dart'; // Always import

class ModelService {
  final ApiService _apiService;

  ModelService(this._apiService);

  // ============================================================================
  // Basic CRUD Operations
  // ============================================================================

  /// GET list - Fetch all items
  Future<List<ModelName>> getItems() async {
    return await _apiService.getList(ApiEndpoints.models, ModelName.fromJson);
  }

  /// GET by ID - Fetch single item
  Future<ModelName> getItemById(String id) async {
    return await _apiService.getById(ApiEndpoints.models, id, ModelName.fromJson);
  }

  /// POST - Create new item
  Future<ModelName> createItem(ModelName item) async {
    return await _apiService.create(
      ApiEndpoints.models,
      item.toCreateJson(),  // ✅ Use toCreateJson (excludes id, timestamps)
      ModelName.fromJson,
    );
  }

  /// PUT - Update existing item
  Future<ModelName> updateItem(ModelName item) async {
    return await _apiService.update(
      ApiEndpoints.models,
      item.id,
      item.toUpdateJson(),  // ✅ Use toUpdateJson
      ModelName.fromJson,
    );
  }

  /// DELETE - Remove item
  Future<void> deleteItem(String id) async {
    await _apiService.delete(ApiEndpoints.models, id);
  }

  // ============================================================================
  // Advanced Operations (Optional)
  // ============================================================================

  /// GET with query parameters - Filtering
  Future<List<ModelName>> getFilteredItems({
    bool? isActive,
    String? search,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) queryParams['is_active'] = isActive;
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit;

    final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final endpoint = queryParams.isEmpty
      ? ApiEndpoints.models
      : '${ApiEndpoints.models}?$query';

    return await _apiService.getList(endpoint, ModelName.fromJson);
  }

  /// GET paginated - For infinite scroll
  Future<List<ModelName>> getPaginatedItems({
    required int page,
    int pageSize = 20,
  }) async {
    final endpoint = '${ApiEndpoints.models}?page=$page&page_size=$pageSize';
    return await _apiService.getList(endpoint, ModelName.fromJson);
  }

  /// PATCH - Partial update (if backend supports)
  Future<ModelName> patchItem(String id, Map<String, dynamic> updates) async {
    return await _apiService.update(
      ApiEndpoints.models,
      id,
      updates,
      ModelName.fromJson,
    );
  }

  /// Custom endpoint - Toggle status example
  Future<ModelName> toggleStatus(String id) async {
    return await _apiService.update(
      '${ApiEndpoints.models}/$id/toggle',
      id,
      {},  // Empty body for toggle action
      ModelName.fromJson,
    );
  }
}
```

**🚨 Common Mistakes:**

```dart
// ❌ DON'T: Pass entire model to create (includes id, timestamps)
Future<ModelName> createItem(ModelName item) async {
  return await _apiService.create(
    ApiEndpoints.models,
    item.toJson(),  // ❌ Includes id, createdAt, etc.
    ModelName.fromJson,
  );
}

// ❌ DON'T: Hardcode query strings
Future<List<Task>> getCompletedTasks() async {
  return await _apiService.getList(
    'http://api.example.com/tasks?completed=true',  // ❌ Hardcoded URL
    Task.fromJson,
  );
}

// ❌ DON'T: Mix business logic in service
Future<Task> createTask(Task task) async {
  // ❌ Validation should be in provider/form
  if (task.title.isEmpty) throw Exception('Title required');

  return await _apiService.create(...);
}

// ❌ DON'T: Handle errors in service (let provider handle)
Future<List<Task>> getTasks() async {
  try {
    return await _apiService.getList(...);
  } catch (e) {
    print('Error: $e');  // ❌ Don't handle here
    return [];
  }
}
```

**✅ DO: Best Practices**

```dart
class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  // ✅ Use toCreateJson for POST
  Future<Task> createTask(Task task) async {
    return await _apiService.create(
      ApiEndpoints.tasks,
      task.toCreateJson(),  // ✅ Excludes id, timestamps
      Task.fromJson,
    );
  }

  // ✅ Use ApiEndpoints constant
  Future<List<Task>> getTasks() async {
    return await _apiService.getList(ApiEndpoints.tasks, Task.fromJson);
  }

  // ✅ Build query strings properly
  Future<List<Task>> getFilteredTasks({
    bool? isCompleted,
    String? category,
  }) async {
    final params = <String, dynamic>{};
    if (isCompleted != null) params['completed'] = isCompleted;
    if (category != null) params['category'] = category;

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final endpoint = params.isEmpty
      ? ApiEndpoints.tasks
      : '${ApiEndpoints.tasks}?$query';

    return await _apiService.getList(endpoint, Task.fromJson);
  }

  // ✅ Keep service layer simple - let errors propagate
  Future<void> deleteTask(String id) async {
    await _apiService.delete(ApiEndpoints.tasks, id);
    // No try-catch - let provider handle errors
  }

  // ✅ For custom endpoints, use clear naming
  Future<Task> toggleCompletion(String id) async {
    return await _apiService.update(
      '${ApiEndpoints.tasks}/$id/toggle',
      id,
      {},
      Task.fromJson,
    );
  }
}
```

### 4. Screen Pattern

```dart
import '../widgets/login/index.dart'; // Import specific widget group

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginFormProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Form fields from login group
            LoginFormFields(),
            SizedBox(height: 24),
            // Login button from login group
            LoginButton(),
            SizedBox(height: 16),
            // Google login from login group
            GoogleLoginButton(),
            SizedBox(height: 16),
            // Navigation to register from login group
            NavigationToRegister(),
          ],
        ),
      ),
    );
  }
}
```

### 5. Widget Pattern & Structure

#### 📁 Widget Organization Rules

```
features/auth/widgets/
├── auth.widget.dart                    # Shared widgets (AuthHeader, AuthTextField)
├── login/                              # Login widget group
│   ├── index.dart                      # Export all login widgets
│   ├── login_button.widget.dart
│   ├── google_login_button.widget.dart
│   ├── navigation_to_register.widget.dart
│   └── login_form_fields/              # Nested group
│       ├── index.dart                  # Export form field widgets
│       ├── login_form_fields.dart      # Main form fields widget
│       └── password_field.widget.dart  # Sub widget
└── register/                           # Register widget group
    ├── index.dart
    ├── register_button.widget.dart
    ├── google_register_button.widget.dart
    └── register_form_fields/
        ├── index.dart
        ├── register_form_fields.widget.dart
        ├── email_field.widget.dart
        ├── password_field.dart
        ├── confirm_password_field.widget.dart
        └── term_checkbox.widget.dart
```

**🎯 Organization Rules:**

1. **Shared Widgets**: `[feature].widget.dart` ที่ระดับ root (e.g., `auth.widget.dart`)
   - Widgets ที่ใช้ร่วมกันใน feature (AuthHeader, AuthTextField)
2. **Widget Groups**: `[group]/` folders (e.g., `login/`, `register/`)
   - จัดกลุ่มตาม logical context
   - แต่ละ group มี `index.dart` export widgets ทั้งหมด
3. **Nested Groups**: `[group]/[nested_group]/` (e.g., `login_form_fields/`)
   - เมื่อมี widgets ที่เกี่ยวข้องกันแบบย่อย
   - ใช้สำหรับ complex forms, cards, lists
4. **No Private Widgets**: ทุก widget เป็น public และอยู่ในไฟล์แยก

**📋 Naming Conventions:**

- Shared widgets: `[feature].widget.dart` (auth.widget.dart)
- Individual widgets: `[name].widget.dart` (login_button.widget.dart)
- Main group widgets: `[group_name].dart` or `[group_name].widget.dart`
- Index files: `index.dart` (export เฉพาะ public widgets)

#### 🎯 Widget Implementation Pattern

**Real Example from Auth Feature:**

```dart
// ============================================================
// 📄 widgets/auth.widget.dart (Shared widgets for auth feature)
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';

/// Auth Header Widget - used in both login and register
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
        ],
      ],
    );
  }
}

/// Auth Text Field Widget - reusable input field
class AuthTextField extends ConsumerWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String) onChanged;
  final String? value;
  final Widget? suffixIcon;
  final bool isDisabled;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.value,
    this.suffixIcon,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
          enabled: !isDisabled,
        ),
      ],
    );
  }
}

// ============================================================
// 📄 widgets/login/login_button.widget.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth.provider.dart';
import '../../../../shared/index.dart';
import '../auth.widget.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValid = ref.watch(loginFormProvider.select((state) => state.isValid));
    final isLoading = ref.watch(isLoadingProvider('auth-login'));

    return PrimaryButton(
      text: 'เข้าสู่ระบบ',
      onPressed: isValid
          ? () async {
              final isProfileSetup = await ref.read(loginFormProvider.notifier).submit();
              if (context.mounted) {
                context.go(isProfileSetup ? AppRoutePath.dashboard : AppRoutePath.profileSetup);
              }
            }
          : null,
      isLoading: isLoading,
      isDisabled: !isValid,
    );
  }
}

// ============================================================
// 📄 widgets/login/login_form_fields/login_form_fields.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';
import '../../../providers/auth.provider.dart';
import '../../auth.widget.dart';
import 'password_field.widget.dart';

class LoginFormFields extends ConsumerWidget {
  const LoginFormFields({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(loginFormProvider.select((state) => state.email));
    final isLoading = ref.watch(isLoadingProvider('auth-login'));
    final isGoogleLoading = ref.watch(isLoadingProvider('auth-google'));
    final isDisabled = isLoading || isGoogleLoading;

    return Column(
      children: [
        // Email Field - uses shared AuthTextField
        AuthTextField(
          label: 'อีเมล',
          hintText: 'user@chavenity.com',
          keyboardType: TextInputType.emailAddress,
          value: email,
          onChanged: (value) => ref.read(loginFormProvider.notifier).setEmail(value),
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 24),
        // Password Field - separate widget in same group
        PasswordField(isDisabled: isDisabled),
      ],
    );
  }
}

// ============================================================
// 📄 widgets/login/login_form_fields/password_field.widget.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth.provider.dart';
import '../../../../../shared/index.dart';
import '../../auth.widget.dart';

class PasswordField extends ConsumerWidget {
  final bool isDisabled;
  const PasswordField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final password = ref.watch(loginFormProvider.select((state) => state.password));
    final obscurePassword = ref.watch(loginFormProvider.select((state) => state.obscurePassword));

    return AuthTextField(
      label: 'รหัสผ่าน',
      hintText: '••••••••••••••',
      obscureText: obscurePassword,
      value: password,
      onChanged: (value) => ref.read(loginFormProvider.notifier).setPassword(value),
      isDisabled: isDisabled,
      suffixIcon: IconButton(
        icon: Icon(
          obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primary,
        ),
        onPressed: isDisabled
            ? null
            : () => ref.read(loginFormProvider.notifier).togglePasswordVisibility(),
      ),
    );
  }
}

// ============================================================
// 📄 widgets/login/login_form_fields/index.dart
// ============================================================
export 'login_form_fields.dart';
// Note: password_field.widget.dart is not exported - it's internal to form fields

// ============================================================
// 📄 widgets/login/index.dart
// ============================================================
export 'login_form_fields/login_form_fields.dart';
export 'login_button.widget.dart';
export 'google_login_button.widget.dart';
export 'navigation_to_register.widget.dart';
```

**Key Patterns:**

1. ✅ **Shared widgets at feature level** (`auth.widget.dart`)
2. ✅ **Group widgets in folders** (`login/`, `register/`)
3. ✅ **Nested groups for complex widgets** (`login_form_fields/`)
4. ✅ **Every widget in separate file** (no `_Widget`)
5. ✅ **Export only what's needed** in `index.dart`
6. ✅ **Import from group level** (`import '../widgets/login/index.dart'`)

### 6. Routes Pattern

```dart
import 'package:hourz/shared/constants/app_routes.dart'; // Always import

final featureRoutes = [
  GoRoute(
    path: AppRoutePath.models,
    name: AppRouteName.models,
    builder: (context, state) => const ModelListScreen(),
  ),
  GoRoute(
    path: AppRoutePath.modelDetail,
    builder: (context, state) => DetailScreen(id: state.pathParameters['id']!),
  ),
];
```

---

## 🚨 Essential Rules

### ✅ Always Do

- Use `@freezed` for all models
- Import `shared/providers/index.dart` in providers
- Handle loading/error with `loadingProvider` & `errorProvider`
- Use `.select()` when watching specific values
- Use `ref.read()` for actions (onClick, onSubmit)
- Use GoRouter: `context.go()`, `context.push()`, `context.pop()`

### ❌ Never Do

- Use `Navigator.push()` (use GoRouter)
- Mutate Freezed objects directly
- Use `ref.watch()` inside callbacks
- Skip error/loading handling
- Watch entire providers when you need only one field

---

## ⚡ Performance Rules

### 1. Use `.select()` for Partial State

```dart
// ❌ Rebuilds on ANY change
final user = ref.watch(userProvider);

// ✅ Rebuilds only when name changes
final name = ref.watch(userProvider.select((u) => u.name));

// ✅ Watch multiple specific fields
final isValid = ref.watch(loginFormProvider.select((s) => s.isValid));
final isLoading = ref.watch(isLoadingProvider('auth-login'));
```

### 2. Separate Widgets by State

```dart
// ❌ Don't use private widgets in screens
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column([
      _DataText(),  // ❌ Private widget in screen
      _LoadingIndicator(),  // ❌ Private widget in screen
    ]);
  }
}

// ✅ Create separate widget files instead
// widgets/my_feature/data_text.widget.dart
class DataText extends ConsumerWidget { ... }

// widgets/my_feature/loading_indicator.widget.dart
class LoadingIndicator extends ConsumerWidget { ... }

// screens/my_screen.dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column([
      DataText(),  // ✅ From separate file
      LoadingIndicator(),  // ✅ From separate file
    ]);
  }
}
```

### 3. Cache Computed Values

```dart
// ✅ Create derived provider for expensive computations
final activeCountProvider = Provider<int>((ref) =>
  ref.watch(itemsProvider.select((items) =>
    items.where((i) => i.isActive).length
  ))
);

// ✅ Complex computed state
final taskStatsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(taskListProvider.select((tasks) => {
    'total': tasks.length,
    'completed': tasks.where((t) => t.isCompleted).length,
    'pending': tasks.where((t) => !t.isCompleted).length,
  }));
});

// ❌ DON'T compute in build method
Widget build(BuildContext context, WidgetRef ref) {
  final tasks = ref.watch(taskListProvider);
  final completed = tasks.where((t) => t.isCompleted).length;  // ❌ Computed every build
  return Text('Completed: $completed');
}

// ✅ DO use derived provider
Widget build(BuildContext context, WidgetRef ref) {
  final stats = ref.watch(taskStatsProvider);
  return Text('Completed: ${stats['completed']}');  // ✅ Cached computation
}
```

### 4. Widget Organization

- **Shared widgets** → `widgets/[feature].widget.dart` (e.g., `auth.widget.dart`)
- **Widget groups** → `widgets/[group]/` (e.g., `login/`, `register/`)
- **Nested groups** → `widgets/[group]/[nested]/` (e.g., `login_form_fields/`)
- **Every widget in separate file** → No `_Widget` private widgets
- **Export via index.dart** → Each group has `index.dart`
- **Import from group** → `import '../widgets/login/index.dart'`
- **Use `const`** wherever possible
- **Separate `ConsumerWidget`** for frequently changing parts

### 5. List Performance

```dart
// ✅ Use const where possible
const SizedBox(height: 16)
const Divider()

// ✅ Extract list items as separate widgets
class TaskListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskItem(task: tasks[index]),  // ✅ Separate widget
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(task.title));
  }
}

// ❌ DON'T build widgets inline
ListView.builder(
  itemBuilder: (context, index) => ListTile(  // ❌ Inline widget
    title: Text(tasks[index].title),
  ),
);
```

### 6. Provider Optimization

```dart
// ✅ Use Provider for stateless services (created once)
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.read(apiProvider));
});

// ✅ Use StateNotifierProvider for mutable state
final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier(ref);
});

// ✅ Use FutureProvider for async data (auto-cache)
final userProfileProvider = FutureProvider<User>((ref) async {
  final service = ref.read(userServiceProvider);
  return await service.getProfile();
});

// ❌ DON'T create new instances in build
Widget build(BuildContext context, WidgetRef ref) {
  final service = TaskService(ref.read(apiProvider));  // ❌ New instance every build!
  return ...;
}
```

---

## 📝 Summary Checklist

### Models ✅

- [ ] Use `@freezed` annotation
- [ ] Include `part` directives for `.freezed.dart` and `.g.dart`
- [ ] Use code generation for `fromJson`: `_$ModelFromJson(json)`
- [ ] Provide `toCreateJson()` without id/timestamps
- [ ] Provide `toUpdateJson()` with only updatable fields
- [ ] Add computed getters in private constructor

### Providers ✅

- [ ] Import `package:hourz/shared/providers/index.dart`
- [ ] Use `@freezed` for form state (not `@immutable`)
- [ ] Use `.select()` when watching specific fields
- [ ] Use `ref.read()` for actions/callbacks
- [ ] Always handle errors with `errorProvider`
- [ ] Always show loading with `loadingProvider`
- [ ] Create derived providers for computed values
- [ ] Immutable state updates: `[...state, item]`

### Services ✅

- [ ] Import `package:hourz/shared/constants/api_endpoints.dart`
- [ ] Use `toCreateJson()` for POST requests
- [ ] Use `toUpdateJson()` for PUT/PATCH requests
- [ ] Don't handle errors (let provider handle)
- [ ] Don't include business logic (validation in provider)
- [ ] Use ApiEndpoints constants
- [ ] Build query strings properly
- [ ] Keep methods simple and focused

### Performance ✅

- [ ] Use `.select()` instead of watching full state
- [ ] Create derived providers for expensive computations
- [ ] Separate widgets into files (no private `_Widget`)
- [ ] Use `const` constructors wherever possible
- [ ] Extract list items as separate widgets
- [ ] Use appropriate provider types (Provider/StateNotifier/Future)

---

> 💡 **Pro Tip:** ดูตัวอย่างเพิ่มเติมที่โฟลเดอร์ `_example`
