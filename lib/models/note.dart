import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class NoteModel {
  final int? id;
  final DateTime createdAt;
  final DateTime? updateAt;
  final String userId;
  final String title;
  final String? content;
  final String? subject;
  final bool isPinned;

  const NoteModel({
    this.id,
    required this.createdAt,
    this.updateAt,
    required this.userId,
    required this.title,
    this.content,
    this.subject,
    this.isPinned = false,
  });

  Color get color {
    final index = (id ?? Random().nextInt(100)) % AppColors.courseColors.length;
    return AppColors.courseColors[index].withAlpha(38);
  }

  Color get accentColor {
    final index = (id ?? Random().nextInt(100)) % AppColors.courseColors.length;
    return AppColors.courseColors[index];
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updateAt: json['update_at'] != null
          ? DateTime.tryParse(json['update_at'] as String)
          : null,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      subject: json['subject'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'update_at': updateAt?.toIso8601String(),
        'user_id': userId,
        'title': title,
        'content': content,
        'subject': subject,
        'is_pinned': isPinned,
      };

  NoteModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updateAt,
    String? userId,
    String? title,
    String? content,
    String? subject,
    bool? isPinned,
  }) {
    return NoteModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updateAt: updateAt ?? this.updateAt,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}