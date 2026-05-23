// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'todo_model.dart';

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 0;

  @override
  TodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoModel(
      id:          fields[0] as String,
      title:       fields[1] as String,
      description: fields[2] as String,
      createdAt:   fields[3] as DateTime,
      isCompleted: fields[4] as bool? ?? false,
      completedAt: fields[5] as DateTime?,   // ✅ nullable — old data = null
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(6)            // ✅ was 5, now 6 fields
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveTitle)
      ..writeByte(2)
      ..write(obj.hiveDescription)
      ..writeByte(3)
      ..write(obj.hiveCreatedAt)
      ..writeByte(4)
      ..write(obj.hiveIsCompleted)
      ..writeByte(5)
      ..write(obj.hiveCompletedAt);  // ✅ NEW
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}