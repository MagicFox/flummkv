import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Wraps MMKV on iOS) and  Android, providing
/// a persistent store for simple data.
class Flummkv {
  static const MethodChannel _channel =
      const MethodChannel('sososdk.github.com/flummkv');
  static const String ID = "id";
  static const String CRYPT = "crypt";
  static const String KEY = "key";
  static const String VALUE = "value";

  Flummkv._();

  static Future<T?> decode<T>(
    String key, {
    String? id,
    String? crypt,
    T? defaultValue,
    Object? reviver(Object? key, Object? value)?,
  }) {
    if (T != bool && T != int && T != double && T != String && T != Uint8List) {
      return get<String>(key, id: id, crypt: crypt).then((value) {
        if (value == null) {
          return defaultValue;
        } else {
          return jsonDecode(value, reviver: reviver);
        }
      });
    } else {
      return get<T>(key, id: id, crypt: crypt, defaultValue: defaultValue);
    }
  }

  static Future<T?> get<T>(
    String key, {
    String? id,
    String? crypt,
    T? defaultValue,
  }) {
    if (T == bool) {
      return getBool(
        key,
        id: id,
        crypt: crypt,
        defaultValue: defaultValue as bool,
      ) as Future<T>;
    } else if (T == int) {
      return getInt(
        key,
        id: id,
        crypt: crypt,
        defaultValue: defaultValue as int,
      ) as Future<T>;
    } else if (T == double) {
      return getDouble(
        key,
        id: id,
        crypt: crypt,
        defaultValue: defaultValue as double,
      ) as Future<T>;
    } else if (T == String) {
      return getString(
        key,
        id: id,
        crypt: crypt,
        defaultValue: defaultValue as String,
      ) as Future<T>;
    } else if (T == Uint8List) {
      return getUint8List(
        key,
        id: id,
        crypt: crypt,
        defaultValue: defaultValue as Uint8List,
      ) as Future<T>;
    } else {
      throw TypeError();
    }
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a bool.
  static Future<bool> getBool(
    String key, {
    String? id,
    String? crypt,
    bool? defaultValue,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    bool? value = await _channel.invokeMethod<bool>('getBool', params);
    return value ?? defaultValue ?? false;
  }

  /// Reads a value from persistent storage, throwing an exception if it's not an int.
  static Future<int> getInt(
    String key, {
    String? id,
    String? crypt,
    int? defaultValue,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    int? value = await _channel.invokeMethod<int>('getInt', params);
    return value ?? defaultValue ?? 0;
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a double.
  static Future<double> getDouble(
    String key, {
    String? id,
    String? crypt,
    double? defaultValue,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    double? value = await _channel.invokeMethod('getDouble', params);
    return value ?? defaultValue ?? 0.0;
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a string.
  static Future<String> getString(
    String key, {
    String? id,
    String? crypt,
    String? defaultValue,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    String? value = await _channel.invokeMethod('getString', params);
    return value ?? defaultValue ?? "";
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a `Uint8List`.
  static Future<Uint8List> getUint8List(
    String key, {
    String? id,
    String? crypt,
    Uint8List? defaultValue,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    Uint8List? value = await _channel.invokeMethod('getBytes', params);
    return value ?? defaultValue ?? Uint8List.fromList([]);
  }

  static Future<bool> encode(
    String key,
    dynamic value, {
    String? id,
    String? crypt,
    Object? toEncodable(Object? nonEncodable)?,
  }) {
    if (value is! bool &&
        value is! int &&
        value is! double &&
        value is! String &&
        value is! Uint8List) {
      value = jsonEncode(value, toEncodable: toEncodable);
    }
    return set(key, value, id: id, crypt: crypt);
  }

  static Future<bool> set(
    String key,
    dynamic value, {
    String? id,
    String? crypt,
  }) {
    if (value is bool) {
      return setBool(key, value, id: id, crypt: crypt);
    } else if (value is int) {
      return setInt(key, value, id: id, crypt: crypt);
    } else if (value is double) {
      return setDouble(key, value, id: id, crypt: crypt);
    } else if (value is String) {
      return setString(key, value, id: id, crypt: crypt);
    } else if (value is Uint8List) {
      return setUint8List(key, value, id: id, crypt: crypt);
    } else {
      throw TypeError();
    }
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  static Future<bool> setBool(
    String key,
    bool value, {
    String? id,
    String? crypt,
  }) =>
      _setValue('Bool', id, crypt, key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  static Future<bool> setInt(
    String key,
    int value, {
    String? id,
    String? crypt,
  }) =>
      _setValue('Int', id, crypt, key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  static Future<bool> setDouble(
    String key,
    double value, {
    String? id,
    String? crypt,
  }) =>
      _setValue('Double', id, crypt, key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  static Future<bool> setString(
    String key,
    String value, {
    String? id,
    String? crypt,
  }) =>
      _setValue('String', id, crypt, key, value);

  /// Saves a `Uint8List` [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  static Future<bool> setUint8List(
    String key,
    Uint8List value, {
    String? id,
    String? crypt,
  }) =>
      _setValue('Bytes', id, crypt, key, value);

  static Future<bool> _setValue(
    String? valueType,
    String? id,
    String? crypt,
    String? key,
    Object? value,
  ) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    if (value == null) {
      bool? flag = await _channel.invokeMethod('removeByKey', params);
      return flag ?? false;
    } else {
      params[VALUE] = value;
      bool? flag = await _channel.invokeMethod('set$valueType', params);
      return flag ?? false;
    }
  }

  /// Removes an entry from persistent storage.
  static Future<bool> removeByKey(
    String key, {
    String? id,
    String? crypt,
  }) =>
      _setValue(null, id, crypt, key, null);

  /// `True` if the [key] contains.
  static Future<bool> contains(
    String key, {
    String? id,
    String? crypt,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    bool? flag = await _channel.invokeMethod('contains', params);
    return flag ?? false;
  }

  /// Android only.
  static Future<int> getValueSize(
    String key, {
    String? id,
    String? crypt,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
      KEY: key,
    };
    int? value = await _channel.invokeMethod('getValueSize', params);
    return value ?? 0;
  }

  /// Completes with true once the user preferences for the app has been cleared.
  static Future<bool> clear({
    String? id,
    String? crypt,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
    };
    bool? flag = await _channel.invokeMethod('clear', params);
    return flag ?? false;
  }

  /// Get item count.
  static Future<int> count({
    String? id,
    String? crypt,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
    };
    int? flag = await _channel.invokeMethod('count', params);
    return flag ?? 0;
  }

  /// Get all keys.
  static Future<List<String>> allKeys({
    String? id,
    String? crypt,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
    };
    List<dynamic>? list = await _channel.invokeMethod('allKeys', params);
    List<String> strList = list?.cast<List<String>>().cast() ?? [];
    return strList;
  }

  /// Get storage file size.
  static Future<int> totalSize({
    String? id,
    String? crypt,
  }) async {
    final Map<String, dynamic> params = {
      ID: id,
      CRYPT: crypt,
    };
    int flag = await _channel.invokeMethod('totalSize', params);
    return flag;
  }

  /// Android only.
  static Future<int?>? pageSize() {
    return _channel.invokeMethod<int>('pageSize', {});
  }
}

class Mmkv {
  String? id;

  /// cryptKey's length <= 16
  String? crypt;

  Mmkv({this.id, this.crypt});

  Future<bool> encode(
    String key,
    dynamic value, {
    Object? toEncodable(Object? nonEncodable)?,
  }) {
    if (value is! bool &&
        value is! int &&
        value is! double &&
        value is! String &&
        value is! Uint8List) {
      value = jsonEncode(value, toEncodable: toEncodable);
    }
    return Flummkv.encode(
      key,
      value,
      id: id,
      crypt: crypt,
      toEncodable: toEncodable,
    );
  }

  Future<T?> get<T>(String key, {T? defaultValue}) {
    return Flummkv.get(key, id: id, crypt: crypt, defaultValue: defaultValue);
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a bool.
  Future<bool> getBool(String key, {bool? defaultValue}) {
    return Flummkv.getBool(
      key,
      id: id,
      crypt: crypt,
      defaultValue: defaultValue,
    );
  }

  /// Reads a value from persistent storage, throwing an exception if it's not an int.
  Future<int> getInt(String key, {int? defaultValue}) {
    return Flummkv.getInt(
      key,
      id: id,
      crypt: crypt,
      defaultValue: defaultValue,
    );
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a double.
  Future<double> getDouble(String key, {double? defaultValue}) {
    return Flummkv.getDouble(
      key,
      id: id,
      crypt: crypt,
      defaultValue: defaultValue,
    );
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a string.
  Future<String> getString(String key, {String? defaultValue}) {
    return Flummkv.getString(
      key,
      id: id,
      crypt: crypt,
      defaultValue: defaultValue,
    );
  }

  /// Reads a value from persistent storage, throwing an exception if it's not a `Uint8List`.
  Future<Uint8List> getUint8List(String key, {Uint8List? defaultValue}) {
    return Flummkv.getUint8List(
      key,
      id: id,
      crypt: crypt,
      defaultValue: defaultValue,
    );
  }

  Future<T?> decode<T>(
    String key, {
    T? defaultValue,
    Object? reviver(Object? key, Object? value)?,
  }) {
    return Flummkv.decode(
      key,
      id: id,
      crypt: crypt,
      defaultValue: defaultValue,
      reviver: reviver,
    );
  }

  Future<bool> set(String key, dynamic value) {
    return Flummkv.set(key, value, id: id, crypt: crypt);
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  Future<bool> setBool(String key, bool value) =>
      Flummkv.setBool(key, value, id: id, crypt: crypt);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  Future<bool> setInt(String key, int value) =>
      Flummkv.setInt(key, value, id: id, crypt: crypt);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  Future<bool> setDouble(String key, double value) =>
      Flummkv.setDouble(key, value, id: id, crypt: crypt);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  Future<bool> setString(String key, String value) =>
      Flummkv.setString(key, value, id: id, crypt: crypt);

  /// Saves a `Uint8List` [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [removeByKey()] on the [key].
  Future<bool> setUint8List(String key, Uint8List value) =>
      Flummkv.setUint8List(key, value, id: id, crypt: crypt);

  /// Removes an entry from persistent storage.
  Future<bool> removeByKey(String key) =>
      Flummkv.removeByKey(key, id: id, crypt: crypt);

  /// `True` if the [key] contains.
  Future<bool> contains(String key) =>
      Flummkv.contains(key, id: id, crypt: crypt);

  /// Android only.
  Future<int> getValueSize(String key) =>
      Flummkv.getValueSize(key, id: id, crypt: crypt);

  Future<bool> clear() => Flummkv.clear(id: id, crypt: crypt);

  Future<int> count() => Flummkv.count(id: id, crypt: crypt);

  /// Get all keys.
  Future<List<String>> allKeys() => Flummkv.allKeys(id: id, crypt: crypt);

  Future<int> totalSize() => Flummkv.totalSize(id: id, crypt: crypt);
}
