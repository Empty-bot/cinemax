enum LoadStatus { idle, loading, success, error }

/// État d'un chargement asynchrone : chargement, succès ou erreur.
class LoadState<T> {
  const LoadState._(this.status, this.data, this.error);

  const LoadState.idle() : this._(LoadStatus.idle, null, null);
  const LoadState.loading([T? previous]) : this._(LoadStatus.loading, previous, null);
  const LoadState.success(T data) : this._(LoadStatus.success, data, null);
  const LoadState.error(String message, [T? previous]) : this._(LoadStatus.error, previous, message);

  final LoadStatus status;
  final T? data;
  final String? error;

  bool get isLoading => status == LoadStatus.loading;
  bool get hasError => status == LoadStatus.error;
  bool get hasData => data != null;
}
