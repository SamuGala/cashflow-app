import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'receipt_storage_service.dart';

Future<String?> showReceiptCapture({
  required BuildContext context,
  required ReceiptStorageService storage,
}) {
  return Navigator.of(context, rootNavigator: true).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ReceiptCapturePage(storage: storage),
    ),
  );
}

class ReceiptCapturePage extends StatefulWidget {
  const ReceiptCapturePage({super.key, required this.storage});

  final ReceiptStorageService storage;

  @override
  State<ReceiptCapturePage> createState() => _ReceiptCapturePageState();
}

class _ReceiptCapturePageState extends State<ReceiptCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _busy = false;
  bool _initializing = true;
  String? _cameraErrorCode;
  int _initializationId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeCamera());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _initializationId++;
      final controller = _controller;
      _controller = null;
      unawaited(controller?.dispose());
    } else if (state == AppLifecycleState.resumed && !_busy) {
      unawaited(_initializeCamera());
    }
  }

  Future<void> _initializeCamera() async {
    final initializationId = ++_initializationId;
    final previous = _controller;
    if (mounted) {
      setState(() {
        _controller = null;
        _initializing = true;
        _cameraErrorCode = null;
      });
    }
    await previous?.dispose();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('no-camera', '');
      final rearIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      final cameraIndex = rearIndex < 0 ? 0 : rearIndex;
      final controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted || initializationId != _initializationId) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted || initializationId != _initializationId) return;
      setState(() {
        _cameraErrorCode = error.code;
        _initializing = false;
      });
    } catch (_) {
      if (!mounted || initializationId != _initializationId) return;
      setState(() {
        _cameraErrorCode = 'camera-unavailable';
        _initializing = false;
      });
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_busy || controller == null || !controller.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      final shot = await controller.takePicture();
      final storedPath = await widget.storage.storeFile(shot.path);
      unawaited(File(shot.path).delete().catchError((_) => File(shot.path)));
      if (mounted) Navigator.of(context).pop(storedPath);
    } on CameraException catch (error) {
      if (!mounted) return;
      _showError(error.code.toLowerCase().contains('denied'));
      setState(() => _busy = false);
    } catch (_) {
      if (!mounted) return;
      _showError(false);
      setState(() => _busy = false);
    }
  }

  Future<void> _chooseLibrary() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await widget.storage.chooseFromLibrary();
      if (!mounted) return;
      if (path == null) {
        setState(() => _busy = false);
        if (_controller == null) {
          unawaited(_initializeCamera());
        }
        return;
      }
      Navigator.of(context).pop(path);
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.libraryUnavailable)));
      setState(() => _busy = false);
      if (_controller == null) {
        unawaited(_initializeCamera());
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (_busy || controller == null || !controller.value.isInitialized) return;
    try {
      final next = controller.value.flashMode == FlashMode.torch
          ? FlashMode.off
          : FlashMode.torch;
      await controller.setFlashMode(next);
      if (mounted) setState(() {});
    } on CameraException {
      if (mounted) _showError(false);
    }
  }

  void _showError(bool permissionDenied) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          permissionDenied ? t.receiptPermissionDenied : t.cameraUnavailable,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _initializationId++;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller = _controller;
    final permissionDenied = (_cameraErrorCode ?? '').toLowerCase().contains(
      'denied',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            _CameraCoverPreview(controller: controller)
          else
            ColoredBox(
              color: const Color(0xFF090A0E),
              child: Center(
                child: _initializing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          permissionDenied
                              ? t.receiptPermissionDenied
                              : t.cameraUnavailable,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
          IgnorePointer(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: .86,
                heightFactor: .55,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .72),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassIconButton(
                      key: const ValueKey('receipt-camera-close'),
                      icon: Icons.close_rounded,
                      label: t.cancel,
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                    if (controller != null && controller.value.isInitialized)
                      _GlassIconButton(
                        key: const ValueKey('receipt-camera-flash'),
                        icon: controller.value.flashMode == FlashMode.torch
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        label: t.cameraFlash,
                        onPressed: _toggleFlash,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .8),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(22, 54, 22, 18),
                child: ReceiptCaptureBottomControls(
                  busy: _busy,
                  canCapture:
                      controller != null && controller.value.isInitialized,
                  libraryLabel: t.chooseLibrary,
                  captureLabel: t.takePhoto,
                  onLibrary: _chooseLibrary,
                  onCapture: _capture,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraCoverPreview extends StatelessWidget {
  const _CameraCoverPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const ColoredBox(color: Colors.black);
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class ReceiptCaptureBottomControls extends StatelessWidget {
  const ReceiptCaptureBottomControls({
    super.key,
    required this.busy,
    required this.canCapture,
    required this.libraryLabel,
    required this.captureLabel,
    required this.onLibrary,
    required this.onCapture,
  });

  final bool busy;
  final bool canCapture;
  final String libraryLabel;
  final String captureLabel;
  final VoidCallback onLibrary;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _GlassIconButton(
              key: const ValueKey('receipt-camera-library'),
              icon: Icons.photo_library_outlined,
              label: libraryLabel,
              onPressed: busy ? null : onLibrary,
            ),
          ),
          Semantics(
            button: true,
            label: captureLabel,
            child: InkResponse(
              key: const ValueKey('receipt-camera-shutter'),
              radius: 48,
              onTap: busy || !canCapture ? null : onCapture,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: busy ? Colors.white54 : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton.filledTonal(
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black.withValues(alpha: .42),
          disabledForegroundColor: Colors.white38,
          disabledBackgroundColor: Colors.black26,
          minimumSize: const Size.square(52),
        ),
      ),
    );
  }
}
