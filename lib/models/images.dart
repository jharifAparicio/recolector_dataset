class Images {
  final String id;
  final String localFolder;
  final String cloudFoler;

  Images({
    required this.id,
    required this.localFolder,
    required this.cloudFoler,
  });

  Images copyWith({String? id, String? localFolder, String? cloudFoler}) {
    return Images(
      id: id ?? this.id,
      localFolder: localFolder ?? this.localFolder,
      cloudFoler: cloudFoler ?? this.cloudFoler,
    );
  }
}
