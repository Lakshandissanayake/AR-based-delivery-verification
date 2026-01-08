    <!-- # Delivery Verification System

A Flutter application for scanning and verifying delivery items using camera and AR (Augmented Reality) technology.

## Features

- 📷 **Camera Scanning**: Scan delivery items using your device camera
- 🎯 **3D AR Viewer**: View scanned items in 3D with augmented reality
- ✅ **Item Verification**: Mark items as verified after inspection
- 📊 **Delivery Management**: Track all scanned deliveries in one place
- 🏗️ **MVC Architecture**: Clean separation of concerns
- 🔄 **State Management**: Powered by Riverpod for reactive state management

## Architecture

This project follows the **Model-View-Controller (MVC)** pattern:

```
lib/
├── models/           # Data models
│   ├── delivery_item.dart
│   ├── ar_model.dart
│   └── scan_result.dart
├── views/            # UI screens
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── ar_viewer_screen.dart
│   └── delivery_list_screen.dart
├── controllers/      # Business logic with Riverpod
│   ├── camera_controller.dart
│   ├── ar_controller.dart
│   └── delivery_controller.dart
└── utils/           # Utilities and helpers
    ├── permissions_helper.dart
    └── constants.dart
```

## Requirements

- Flutter SDK: ^3.8.1
- Dart SDK: ^3.8.1
- Android: API Level 24+ (Android 7.0+)
- iOS: 11.0+
- ARCore support (Android) or ARKit support (iOS) for AR features

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd delivery_verification_system
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Permissions

### Android
The following permissions are configured in `AndroidManifest.xml`:
- Camera access
- Storage access (for saving scanned images)
- Internet access (for loading 3D models)

### iOS
The following permissions are configured in `Info.plist`:
- Camera usage
- Photo library access
- ARKit capabilities

## Usage

### 1. Scan an Item
- Tap "Scan New Item" on the home screen
- Position the item within the camera frame
- Tap the capture button to scan

### 2. View in AR
- After scanning, tap "View in AR"
- Explore the 3D model with touch gestures:
  - Drag to rotate
  - Pinch to zoom
  - Tap AR button for augmented reality mode

### 3. Verify Items
- View item details in AR viewer
- Tap "Verify This Item" to mark as verified
- Track verification status on home screen

### 4. Manage Deliveries
- Tap "View All Deliveries" to see all scanned items
- Filter by verified/pending status
- Delete items as needed

## Key Dependencies

- **flutter_riverpod**: State management
- **camera**: Camera functionality
- **model_viewer_plus**: 3D model viewing and AR
- **arcore_flutter_plugin**: Android AR support
- **arkit_plugin**: iOS AR support
- **permission_handler**: Runtime permissions
- **path_provider**: File system access
- **uuid**: Unique ID generation

## State Management

The app uses **Riverpod** for state management with the following providers:

- `cameraProvider`: Manages camera state and operations
- `arProvider`: Manages AR models and viewer state
- `deliveryProvider`: Manages delivery items and verification

## 3D Models

Currently, the app uses demo 3D models from ModelViewer. To use custom models:

1. Add your `.glb` or `.gltf` files to `assets/models/`
2. Update `pubspec.yaml` to include the assets
3. Update the model paths in the AR controller

## Future Enhancements

- [ ] Barcode/QR code scanning
- [ ] Cloud storage integration
- [ ] Real-time item detection with ML
- [ ] Custom 3D model generation from photos
- [ ] Delivery route tracking
- [ ] Multi-user support
- [ ] Export delivery reports

## Troubleshooting

### Camera not working
- Ensure camera permissions are granted
- Check if another app is using the camera
- Restart the app

### AR not loading
- Verify device supports ARCore (Android) or ARKit (iOS)
- Check internet connection for loading models
- Update to latest OS version

### Build issues
```bash
flutter clean
flutter pub get
flutter run
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue on the repository.

---

Built with ❤️ using Flutter -->
