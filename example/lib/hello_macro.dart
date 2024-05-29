import 'dart:async';

import 'package:macros/macros.dart';

final _dartCore = Uri.parse('dart:core');

macro class Hello implements ClassDeclarationsMacro {
  const Hello();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz,
      MemberDeclarationBuilder builder,
      ) async {
    final fields = await builder.fieldsOf(clazz);
    final fieldsString = fields.map((f) => f.identifier.name).join(', ');

    // ignore: deprecated_member_use
    final print = await builder.resolveIdentifier(_dartCore, 'print');
    final printCode = NamedTypeAnnotationCode(name: print);

    builder.declareInType(
      DeclarationCode.fromParts([
        'void hello() {',
        printCode,
        "('Hello! I am ${clazz.identifier.name}. I have $fieldsString.');}",
      ]),
    );
  }
}
