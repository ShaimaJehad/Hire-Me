---
name: flutter-getx-controller
description: Scaffold a GetX Controller with binding and view structure for HireMe. ALWAYS use this skill before writing any controller or feature screen — including when building a full feature or adding a new module. Triggers on "create controller", "add controller", "new screen", "new feature", or any task that will produce a *_controller.dart file.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Scaffold a GetX Controller + Binding + View (HireMe)

Generate a Controller, Binding, and View for the given feature. Follow the exact pattern used in `lib/app/modules/`.

## Rules

- Controller extends `GetxController`.
- Use `.obs` for reactive state — no `setState`, no `update()` unless necessary.
- Firebase/Supabase calls go in the controller — never in the view.
- Binding registers the controller via `Get.lazyPut`.
- View extends `GetView<{Name}Controller>`.
- Route registered in `app_pages.dart` with the binding attached.
- Use `StorageService` for role/session data — not direct SharedPreferences.

## Controller File (`{name}_controller.dart`)

```dart
import 'package:get/get.dart';

class {Name}Controller extends GetxController {
  // Reactive state
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading(true);
      // Firebase / Supabase call here
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    // Dispose text controllers, focus nodes, streams here
    super.onClose();
  }
}
```

## Binding File (`{name}_binding.dart`)

```dart
import 'package:get/get.dart';

class {Name}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<{Name}Controller>(() => {Name}Controller());
  }
}
```

## View File (`{name}_view.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class {Name}View extends GetView<{Name}Controller> {
  const {Name}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{Name}')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        return const SizedBox(); // Replace with actual UI
      }),
    );
  }
}
```

## Route Registration (`app_pages.dart`)

```dart
GetPage(
  name: Routes.{NAME},
  page: () => const {Name}View(),
  binding: {Name}Binding(),
  middlewares: [RoleGuardMiddleware()], // add only for protected routes
),
```

## After scaffolding, verify

- [ ] Controller has no UI/Flutter widget imports.
- [ ] All Firebase/Supabase logic is in the controller, not the view.
- [ ] Binding uses `lazyPut`, not `put`.
- [ ] View wraps reactive variables in `Obx()`.
- [ ] `onClose()` disposes any TextEditingControllers or FocusNodes.
- [ ] Route added to both `app_routes.dart` (constant) and `app_pages.dart` (GetPage).