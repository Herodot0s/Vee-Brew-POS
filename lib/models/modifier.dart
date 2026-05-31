class ModifierGroup {
  final String id;
  final String productId;
  final String name;
  final bool isRequired;
  final bool isMultiSelect;
  final List<ModifierOption> options;

  const ModifierGroup({
    required this.id,
    required this.productId,
    required this.name,
    this.isRequired = false,
    this.isMultiSelect = false,
    required this.options,
  });
}

class ModifierOption {
  final String id;
  final String groupId;
  final String name;
  final double priceDelta;
  final bool isDefault;

  const ModifierOption({
    required this.id,
    required this.groupId,
    required this.name,
    this.priceDelta = 0.0,
    this.isDefault = false,
  });
}
