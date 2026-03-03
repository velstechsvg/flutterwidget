import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_controller.dart';

class CameraPreview extends StatelessWidget {
  const CameraPreview(this.controller, {Key? key, this.child})
      : super(key: key);

  final CameraController controller;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (BuildContext context, Object? value, Widget? child) {
        return AspectRatio(
          aspectRatio: _isLandscape()
              ? controller.value.aspectRatio
              : (1 / controller.value.aspectRatio),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _wrapInRotatedBox(child: controller.buildPreview()),
              child ?? const SizedBox.shrink(),
            ],
          ),
        );
      },
      child: child,
    )
        : const SizedBox.shrink();
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  bool _isLandscape() {
    return <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ].contains(_getApplicableOrientation());
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
        controller.value.lockedCaptureOrientation ??
        controller.value.deviceOrientation);
  }
}
