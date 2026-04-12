// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0: return TransactionType.expense;
      case 1: return TransactionType.income;
      case 2: return TransactionType.transfer;
      default: return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.expense: writer.writeByte(0); break;
      case TransactionType.income: writer.writeByte(1); break;
      case TransactionType.transfer: writer.writeByte(2); break;
    }
  }
}

class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 1;

  @override
  AccountType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0: return AccountType.cash;
      case 1: return AccountType.bank;
      case 2: return AccountType.creditCard;
      case 3: return AccountType.upi;
      default: return AccountType.bank;
    }
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    switch (obj) {
      case AccountType.cash: writer.writeByte(0); break;
      case AccountType.bank: writer.writeByte(1); break;
      case AccountType.creditCard: writer.writeByte(2); break;
      case AccountType.upi: writer.writeByte(3); break;
    }
  }
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 2;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Account(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as AccountType,
      balance: fields[4] as double,
      creditLimit: fields[5] as double?,
      outstandingDue: fields[6] as double,
      billingCycleStart: fields[7] as int?,
      dueDate: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.name)
      ..writeByte(3)..write(obj.type)
      ..writeByte(4)..write(obj.balance)
      ..writeByte(5)..write(obj.creditLimit)
      ..writeByte(6)..write(obj.outstandingDue)
      ..writeByte(7)..write(obj.billingCycleStart)
      ..writeByte(8)..write(obj.dueDate)
      ..writeByte(9)..write(obj.createdAt);
  }
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 3;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Category(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      icon: fields[3] as String,
      colorValue: fields[4] as int,
      parentCategoryId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.name)
      ..writeByte(3)..write(obj.icon)
      ..writeByte(4)..write(obj.colorValue)
      ..writeByte(5)..write(obj.parentCategoryId);
  }
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 4;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Transaction(
      id: fields[0] as String,
      userId: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as TransactionType,
      categoryId: fields[4] as String,
      accountId: fields[5] as String,
      toAccountId: fields[6] as String?,
      note: fields[7] as String?,
      date: fields[8] as DateTime,
      isRecurring: fields[9] as bool,
      recurringId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.amount)
      ..writeByte(3)..write(obj.type)
      ..writeByte(4)..write(obj.categoryId)
      ..writeByte(5)..write(obj.accountId)
      ..writeByte(6)..write(obj.toAccountId)
      ..writeByte(7)..write(obj.note)
      ..writeByte(8)..write(obj.date)
      ..writeByte(9)..write(obj.isRecurring)
      ..writeByte(10)..write(obj.recurringId);
  }
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 5;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Budget(
      id: fields[0] as String,
      userId: fields[1] as String,
      categoryId: fields[2] as String,
      monthlyLimit: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.categoryId)
      ..writeByte(3)..write(obj.monthlyLimit);
  }
}
