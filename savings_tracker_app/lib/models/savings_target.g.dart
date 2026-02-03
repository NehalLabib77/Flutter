// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_target.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsTargetAdapter extends TypeAdapter<SavingsTarget> {
  @override
  final int typeId = 1;

  @override
  SavingsTarget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsTarget(
      targetAmount: fields[0] as double,
      targetDate: fields[1] as DateTime,
      createdDate: fields[2] as DateTime,
      isCompleted: fields[3] as bool? ?? false,
      isMissed: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsTarget obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.targetAmount)
      ..writeByte(1)
      ..write(obj.targetDate)
      ..writeByte(2)
      ..write(obj.createdDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.isMissed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsTargetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
