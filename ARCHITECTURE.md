# Delivery Verification System - Architecture Documentation

## Overview
This document provides a detailed overview of the application architecture, following the MVC (Model-View-Controller) pattern with Riverpod for state management.

## Architecture Pattern: MVC + Riverpod

### Why MVC?
- **Separation of Concerns**: Clear boundaries between data, business logic, and UI
- **Maintainability**: Easy to locate and update specific functionality
- **Testability**: Components can be tested independently
- **Scalability**: New features can be added without affecting existing code

## Project Structure

```
lib/
├── main.dart                 # App entry point with ProviderScope
├── models/                   # Data Models (M in MVC)
│   ├── delivery_item.dart    # Delivery item entity
│   ├── ar_model.dart         # AR 3D model data
│   └── scan_result.dart      # Camera scan result
├── views/                    # User Interface (V in MVC)
│   ├── home_screen.dart      # Main dashboard
│   ├── camera_screen.dart    # Camera scanning interface
│   ├── ar_viewer_screen.dart # AR 3D viewer
│   └── delivery_list_screen.dart # List of all deliveries
├── controllers/              # Business Logic (C in MVC)
│   ├── camera_controller.dart     # Camera operations + Riverpod
│   ├── ar_controller.dart         # AR model management + Riverpod
│   └── delivery_controller.dart   # Delivery CRUD + Riverpod
└── utils/                    # Utilities and helpers
    ├── permissions_helper.dart    # Permission management
    └── constants.dart             # App-wide constants
```

## Components Breakdown

### 1. Models (Data Layer)

#### `DeliveryItem`
```dart
class DeliveryItem {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? modelUrl;
  final DateTime scannedAt;
  final bool isVerified;
  // ... methods: copyWith(), toJson(), fromJson()
}
```
- Represents a delivery package
- Immutable data class
- JSON serialization support

#### `ARModel`
```dart
class ARModel {
  final String id;
  final String name;
  final String modelPath;
  final ARModelType type;
  final double scale;
  // ... methods
}
```
- Represents 3D model data
- Supports multiple model formats (GLB, GLTF, OBJ, FBX)

#### `ScanResult`
```dart
class ScanResult {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final String? detectedObject;
  final double? confidence;
  // ... methods
}
```
- Camera scan output
- Can be extended with ML detection results

### 2. Controllers (Business Logic + State Management)

#### `CameraController`
**State:**
```dart
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isProcessing;
  final String? error;
  final ScanResult? lastScan;
}
```

**Actions:**
- `initializeCamera()` - Set up camera hardware
- `capturePhoto()` - Take picture and create ScanResult
- `dispose()` - Clean up resources

**Provider:**
```dart
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>
```

#### `ARController`
**State:**
```dart
class ARState {
  final ARModel? currentModel;
  final bool isLoading;
  final bool isARSupported;
  final Map<String, ARModel> availableModels;
}
```

**Actions:**
- `loadModelForItem(DeliveryItem)` - Load 3D model
- `checkARSupport()` - Verify device capabilities
- `selectModel(String)` - Switch models

**Provider:**
```dart
final arProvider = StateNotifierProvider<ARNotifier, ARState>
```

#### `DeliveryController`
**State:**
```dart
class DeliveryState {
  final List<DeliveryItem> items;
  final DeliveryItem? selectedItem;
  final bool isLoading;
  final int verifiedCount;
}
```

**Actions:**
- `addItemFromScan(ScanResult)` - Create item from scan
- `verifyItem(String)` - Mark item as verified
- `deleteItem(String)` - Remove item
- `selectItem(String)` - Set current item

**Providers:**
```dart
final deliveryProvider = StateNotifierProvider<DeliveryNotifier, DeliveryState>
final verifiedCountProvider = Provider<int>
final unverifiedCountProvider = Provider<int>
```

### 3. Views (User Interface)

#### `HomeScreen`
- **Type**: ConsumerWidget (Riverpod)
- **Purpose**: Main dashboard and navigation hub
- **State Dependencies**:
  - `deliveryProvider` - Item statistics
  - `verifiedCountProvider` - Verified count
  - `unverifiedCountProvider` - Pending count
- **Features**:
  - Statistics cards
  - Quick actions
  - Navigation buttons

#### `CameraScreen`
- **Type**: ConsumerStatefulWidget
- **Purpose**: Camera interface for scanning items
- **State Dependencies**:
  - `cameraProvider` - Camera state
  - `deliveryProvider` - Add scanned items
- **Features**:
  - Live camera preview
  - Scan frame overlay
  - Capture button
  - Auto-navigation to AR viewer

#### `ARViewerScreen`
- **Type**: ConsumerStatefulWidget
- **Purpose**: 3D AR model viewer
- **State Dependencies**:
  - `arProvider` - Model data
  - `deliveryProvider` - Item verification
- **Features**:
  - 3D model display (ModelViewer)
  - Interactive controls (rotate, zoom)
  - AR mode button
  - Item verification

#### `DeliveryListScreen`
- **Type**: ConsumerWidget
- **Purpose**: List and manage all deliveries
- **State Dependencies**:
  - `deliveryProvider` - Items list
- **Features**:
  - Filterable list
  - Item cards with thumbnails
  - Quick actions (verify, delete)
  - Empty state

## Data Flow

### Example: Scanning a New Item

```
1. User taps "Scan" button
   └─> Navigate to CameraScreen

2. CameraScreen.initState()
   └─> ref.read(cameraProvider.notifier).initializeCamera()
   └─> CameraController initializes hardware
   └─> Updates CameraState (isInitialized = true)
   └─> UI rebuilds with camera preview

3. User taps capture button
   └─> _captureAndProcess() called
   └─> cameraProvider.notifier.capturePhoto()
   └─> Creates ScanResult with image path
   └─> Returns ScanResult

4. deliveryProvider.notifier.addItemFromScan(scanResult)
   └─> Creates DeliveryItem from ScanResult
   └─> Adds to items list
   └─> Updates DeliveryState
   └─> UI shows success dialog

5. User taps "View in AR"
   └─> Navigate to ARViewerScreen(item)
   
6. ARViewerScreen.initState()
   └─> arProvider.notifier.loadModelForItem(item)
   └─> Loads 3D model
   └─> Updates ARState
   └─> ModelViewer renders 3D model
```

## State Management with Riverpod

### Why Riverpod?
1. **Compile-time safety** - No runtime errors from Provider
2. **Better testing** - Easy to override providers in tests
3. **No BuildContext** - Read providers from anywhere
4. **Better performance** - Fine-grained rebuilds

### Provider Types Used

#### StateNotifierProvider
Used for mutable state with business logic:
```dart
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>(
  (ref) => CameraNotifier(),
);
```

#### Provider
Used for computed values:
```dart
final verifiedCountProvider = Provider<int>((ref) {
  final state = ref.watch(deliveryProvider);
  return state.verifiedCount;
});
```

### Consuming Providers

#### In Widgets:
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryProvider);
    // Widget rebuilds when state changes
  }
}
```

#### Reading (no rebuild):
```dart
ref.read(cameraProvider.notifier).capturePhoto()
```

#### Watching (rebuilds on change):
```dart
final state = ref.watch(cameraProvider)
```

## Platform Integration

### Android
**Permissions** (AndroidManifest.xml):
- CAMERA
- WRITE_EXTERNAL_STORAGE
- READ_EXTERNAL_STORAGE
- INTERNET

**AR Support**:
- ARCore metadata
- OpenGL ES 2.0

### iOS
**Permissions** (Info.plist):
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription

**AR Support**:
- ARKit required device capability

## Key Dependencies

| Package | Purpose | Category |
|---------|---------|----------|
| flutter_riverpod | State management | Core |
| camera | Camera access | Feature |
| model_viewer_plus | 3D model rendering | Feature |
| arcore_flutter_plugin | Android AR | Feature |
| arkit_plugin | iOS AR | Feature |
| permission_handler | Runtime permissions | Utility |
| path_provider | File storage | Utility |
| uuid | Unique IDs | Utility |
| intl | Date formatting | Utility |

## Best Practices Implemented

### 1. Immutable State
All state classes use `const` constructors and `copyWith` methods:
```dart
state = state.copyWith(isLoading: true);
```

### 2. Separation of Concerns
- Models: Pure data, no logic
- Controllers: Business logic, no UI
- Views: UI only, delegates to controllers

### 3. Error Handling
Controllers include error states:
```dart
try {
  // operation
} catch (e) {
  state = state.copyWith(error: 'Error: $e');
}
```

### 4. Resource Cleanup
Proper disposal of resources:
```dart
@override
void dispose() {
  controller?.dispose();
  super.dispose();
}
```

### 5. Type Safety
Strong typing throughout:
- No dynamic types
- Proper null safety
- Enums for constants

## Testing Strategy

### Unit Tests
- Test models: serialization, equality
- Test controllers: business logic, state transitions
- Mock providers for isolation

### Widget Tests
- Test views: rendering, user interactions
- Override providers with test data
- Verify navigation

### Integration Tests
- Test complete flows
- Real camera and AR (on device)
- E2E scenarios

## Extending the App

### Adding a New Feature

1. **Create Model** (if needed)
   ```dart
   // lib/models/new_feature.dart
   class NewFeature { ... }
   ```

2. **Create Controller**
   ```dart
   // lib/controllers/new_feature_controller.dart
   class NewFeatureState { ... }
   class NewFeatureNotifier extends StateNotifier<NewFeatureState> { ... }
   final newFeatureProvider = StateNotifierProvider<...>(...);
   ```

3. **Create View**
   ```dart
   // lib/views/new_feature_screen.dart
   class NewFeatureScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final state = ref.watch(newFeatureProvider);
       // Build UI
     }
   }
   ```

4. **Add Navigation**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => NewFeatureScreen()),
   );
   ```

## Performance Considerations

1. **Provider Scope**: Watch only what you need
2. **Image Caching**: Reuse thumbnails
3. **Lazy Loading**: Load 3D models on demand
4. **Dispose Controllers**: Clean up resources
5. **Debouncing**: Prevent excessive rebuilds

## Security Considerations

1. **Permissions**: Request only when needed
2. **Storage**: Save images in app-private directory
3. **Validation**: Validate all user inputs
4. **Privacy**: Don't collect unnecessary data

## Conclusion

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Testable components
- ✅ Scalable structure
- ✅ Type-safe state management
- ✅ Reactive UI updates
- ✅ Easy maintenance

For questions or improvements, please refer to the main README.md or open an issue.














