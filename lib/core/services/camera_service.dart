import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

/// Servicio para capturar fotos y videos desde la cámara o galería
/// Adaptado para tareas, cursos, y perfiles en Captus
class CameraService {
  static final CameraService _instance = CameraService._internal();
  final ImagePicker _imagePicker = ImagePicker();

  CameraService._internal();

  factory CameraService() {
    return _instance;
  }

  /// Capturar una foto desde la cámara
  Future<File?> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  /// Seleccionar una foto desde la galería
  Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking photo: $e');
      return null;
    }
  }

  /// Capturar un video desde la cámara
  Future<File?> captureVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing video: $e');
      return null;
    }
  }

  /// Seleccionar un video desde la galería
  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  /// Seleccionar múltiples fotos
  Future<List<File>> pickMultiplePhotos() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultipleMedia(
        imageQuality: 80,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple photos: $e');
      return [];
    }
  }
}
