import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';

class LinkedPhotoViewControllerGroup {
  LinkedPhotoViewControllerGroup({
    Offset initialPosition = Offset.zero,
    double initialRotation = 0.0,
    double? initialScale,
  }) : super() {
    final photoViewControllerValue = PhotoViewControllerValue(
      position: initialPosition,
      rotation: initialRotation,
      scale: initialScale,
      rotationFocusPoint: null,
    );
    _valueNotifier = _LinkedPhotoControllerGroupNotifier(
      photoViewControllerValue,
    )..addListener(_changeListener);

    initial = value;
    prevValue = initial;

    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);
  }

  final _allControllers = <_LinkedPhotoController>[];

  late final _LinkedPhotoControllerGroupNotifier _valueNotifier;

  late PhotoViewControllerValue initial;

  late StreamController<PhotoViewControllerValue> _outputCtrl;

  Stream<PhotoViewControllerValue> get outputStateStream => _outputCtrl.stream;

  late PhotoViewControllerValue prevValue;

  /// Creates a new controller that is linked to any existing ones.
  PhotoViewControllerBase addAndGet([double scale = 1]) {
    final initialValue =
        _attachedControllers.isEmpty ? value : _attachedControllers.first.value;
    final controller = _LinkedPhotoController(this, scale,
        initialPosition: initialValue.position,
        initialRotation: initialValue.rotation,
        initialScale: initialValue.scale)
      ..scaleExternal = scale;

    _allControllers.add(controller);
    controller.outputStateStream.listen((value) => this.value = value);
    return controller;
  }

  void updateExternalScale(PhotoViewControllerBase controller, double scale) {
    assert(_allControllers.contains(controller));
    (controller as _LinkedPhotoController).scaleExternal = scale;
  }

  Iterable<_LinkedPhotoController> get _attachedControllers => _allControllers;

  void reset() {
    value = initial;
  }

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }

  // @override
  void dispose() {
    _outputCtrl.close();
    _valueNotifier.dispose();
    for (var controller in _allControllers) {
      controller.dispose();
    }
  }

  // @override
  set position(Offset position) {
    if (value.position == position) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  // @override
  Offset get position => value.position;

  // @override
  set scale(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  // @override
  double? get scale => value.scale;

  // @override
  set rotation(double rotation) {
    if (value.rotation == rotation) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  // @override
  double get rotation => value.rotation;

  // @override
  set rotationFocusPoint(Offset? rotationFocusPoint) {
    if (value.rotationFocusPoint == rotationFocusPoint) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  // @override
  Offset? get rotationFocusPoint => value.rotationFocusPoint;

  // @override
  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position ?? value.position,
      scale: scale ?? value.scale,
      rotation: rotation ?? value.rotation,
      rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint,
    );
  }

  // @override
  PhotoViewControllerValue get value => _valueNotifier.value;

  // @override
  set value(PhotoViewControllerValue newValue) {
    if (_valueNotifier.value == newValue) {
      return;
    }
    _valueNotifier.value = newValue;
  }
}

class _LinkedPhotoControllerGroupNotifier extends ChangeNotifier {
  _LinkedPhotoControllerGroupNotifier(PhotoViewControllerValue initialValue)
      : _value = initialValue;

  PhotoViewControllerValue get value => _value;
  PhotoViewControllerValue _value;

  set value(PhotoViewControllerValue newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }
}

class _LinkedPhotoController extends PhotoViewController {
  _LinkedPhotoController(
    this._controllerGroup,
    this._scaleExternal, {
    super.initialPosition,
    super.initialRotation,
    double? initialScale,
  }) : super(
          initialScale:
              initialScale == null ? null : initialScale * _scaleExternal,
        );

  final LinkedPhotoViewControllerGroup _controllerGroup;
  double _scaleExternal;
  double get scaleExternal => _scaleExternal;

  set scaleExternal(double newScale) {
    double oldScale = _scaleExternal;
    _scaleExternal = newScale;
    if (_controllerGroup.scale != null && scale != null) {
      super.setScaleInvisibly(_controllerGroup.scale! / oldScale * newScale);
    } else {
      super.setScaleInvisibly(scale);
    }
  }

  @override
  void setScaleInvisibly(double? scale) {
    for (final controller in _controllerGroup._allControllers) {
      final scaledScale = _controllerGroup.scale == null
          ? null
          : scale! / scaleExternal * controller.scaleExternal;
      controller._setScaleInvisiblyInternal(scaledScale);
    }
  }

  void _setScaleInvisiblyInternal(double? scale) {
    super.setScaleInvisibly(scale);
  }

  @override
  set value(PhotoViewControllerValue newValue) {
    for (final controller in _controllerGroup._allControllers) {
      final scaledScale = newValue.scale == null
          ? null
          : newValue.scale! / scaleExternal * controller.scaleExternal;

      controller._valueInternal = PhotoViewControllerValue(
        position: newValue.position,
        scale: scaledScale,
        rotation: newValue.rotation,
        rotationFocusPoint: newValue.rotationFocusPoint,
      );
    }

    // super.value = newValue;
  }

  set _valueInternal(PhotoViewControllerValue newValue) {
    super.value = newValue;
  }
}
