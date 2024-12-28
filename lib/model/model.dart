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
  ],
);

const tableContactDetail = SqfEntityTable(
  tableName: 'ContactDetail',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityField('contactId', DbType.text),
  ],
);

const tableContactDetailTag = SqfEntityTable(
  tableName: 'ContactDetailTag',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityFieldRelationship(
      parentTable: tableContactDetail,
      deleteRule: DeleteRule.CASCADE,
      fieldName: 'contactDetailId',
    ),
    SqfEntityFieldRelationship(
      parentTable: tableTag,
      deleteRule: DeleteRule.CASCADE,
      fieldName: 'tagId',
    ),
  ],
);

const tableContactDetailRelation = SqfEntityTable(
  tableName: 'ContactDetailRelation',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  fields: [
    SqfEntityField('relationName', DbType.text),
    SqfEntityFieldRelationship(
      parentTable: tableContactDetail,
      deleteRule: DeleteRule.CASCADE,
      fieldName: 'contactDetailId1',
    ),
    SqfEntityFieldRelationship(
      parentTable: tableContactDetail,
      deleteRule: DeleteRule.CASCADE,
      fieldName: 'contactDetailId2',
    ),
  ],
);

@SqfEntityBuilder(connect2DatabaseModel)
const connect2DatabaseModel = SqfEntityModel(
  modelName: 'Connect2DB',
  databaseName: 'app.db',
  databaseTables: [
    tableTag,
    tableContactDetail,
    tableContactDetailTag,
    tableContactDetailRelation,
  ],
  sequences: [],
);
