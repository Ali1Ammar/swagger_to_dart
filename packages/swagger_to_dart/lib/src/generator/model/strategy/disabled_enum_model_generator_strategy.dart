import 'package:code_builder/code_builder.dart';
import 'package:swagger_to_dart/swagger_to_dart.dart';

///
/// Enum Model Strategy that converts the enum to Object value without any change
///
/// Example:
///
/// ```dart
/// library;
///
/// import 'exports.dart';
///
/// typedef UserLevel = Object;
///
/// ```
///

class DisabledEnumModelGeneratorStrategy
    extends ModelGeneratorStrategy<MapEntry<String, OpenApiSchemas>> {
  const DisabledEnumModelGeneratorStrategy(super.context);

  @override
  Library build(MapEntry<String, OpenApiSchemas> model) {
    final className = Renaming.instance.renameClass(model.key);
    final filename = Renaming.instance.renameFile(className);

    return Library(
      (b) => b
        ..comments.addAll([
          model.key,
          ...JsonFactory.instance.encode(model.value.toJson()).split('\n'),
        ])
        ..name = filename
        ..directives.addAll([
          Directive.import('exports.dart'),
        ])
        ..body.addAll([
          TypeDef((b) => b
            ..name = className
            ..definition = refer('Object'))
        ]),
    );
  }
}
