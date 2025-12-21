import 'dart:io';

abstract class FileUploadEvent {}

class UploadFileEvent extends FileUploadEvent {
  final File file;
  final String type;

  UploadFileEvent({required this.file,required this.type});
}

class ResetUploadEvent extends FileUploadEvent {}