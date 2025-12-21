import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/file_upload/file_upload_event.dart';
import 'package:hisobchi/application/file_upload/file_upload_state.dart';
import 'package:hisobchi/infrastructure/repository/file_upload/file_upload_repository.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final FileUploadRepository _repository;

  FileUploadBloc({required FileUploadRepository repository})
      : _repository = repository,
        super(const FileUploadState()) {
    on<UploadFileEvent>(_onUploadFile);
    on<ResetUploadEvent>(_onResetUpload);
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(state.copyWith(
      status: FileUploadStatus.uploading,
      progress: 0.0,
      errorMessage: null,
    ));

    try {
      final response = await _repository.uploadFile(
        file: event.file,
        type: event.type,
        onProgress: (progress) {
          emit(state.copyWith(
            status: FileUploadStatus.uploading,
            progress: progress,
          ));
        },
      );

      emit(state.copyWith(
        status: FileUploadStatus.success,
        progress: 100.0,
        uploadedFileId: response.id,
        uploadedUrl: response.url,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FileUploadStatus.failure,
        errorMessage: e.toString(),
        progress: 0.0,
      ));
    }
  }

  Future<void> _onResetUpload(
    ResetUploadEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(const FileUploadState());
  }
}