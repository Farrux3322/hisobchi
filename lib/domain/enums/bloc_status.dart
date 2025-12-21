///all blocs default status enum
enum BlocStatus { initial, loading, success, error, empty, notFound }

extension StatusExtension<T extends Enum> on T {
  bool get isInitial => name == 'initial';

  bool get isLoading => name == 'loading';

  bool get isSuccess => name == 'success';

  bool get isError => name == 'error';

  bool get isEmpty => name == 'empty';

  bool get isNotFound => name == 'notFound';
}
