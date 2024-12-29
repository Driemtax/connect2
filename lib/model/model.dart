import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

part 'model.g.dart';

const tableTag = SqfEntityTable(
  tableName: 'Tag',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityField('name', DbType.text),
    SqfEntityFieldRelationship(
        relationType: RelationType.MANY_TO_MANY,
        parentTable: tableContactDetail,
        deleteRule: DeleteRule.NO_ACTION,
        manyToManyTableName: 'ContactDetailTag'),
  ],
);

const tableContactDetail = SqfEntityTable(
  tableName: 'ContactDetail',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityField('phoneContactId', DbType.text),
  ],
);

@SqfEntityBuilder(connect2DatabaseModel)
const connect2DatabaseModel = SqfEntityModel(
  modelName: 'Connect2DB',
  databaseName: 'app.db',
  databaseTables: [
    tableTag,
    tableContactDetail,
  ],
  sequences: [],
);
