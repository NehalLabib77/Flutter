import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hall.dart';
import '../models/room.dart';
import '../models/seat.dart';
import '../services/api_service.dart';

class HallListNotifier extends StateNotifier<AsyncValue<List<Hall>>> {
  final ApiService _api = ApiService();

  HallListNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHalls();
      final list = (response.data as List)
          .map((e) => Hall.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final hallListProvider =
    StateNotifierProvider<HallListNotifier, AsyncValue<List<Hall>>>((ref) {
      return HallListNotifier();
    });

class RoomListNotifier extends StateNotifier<AsyncValue<List<Room>>> {
  final ApiService _api = ApiService();

  RoomListNotifier() : super(const AsyncValue.loading());

  Future<void> fetchForHall(int hallId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHallRooms(hallId);
      final list = (response.data as List)
          .map((e) => Room.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final roomListProvider =
    StateNotifierProvider<RoomListNotifier, AsyncValue<List<Room>>>((ref) {
      return RoomListNotifier();
    });

class SeatListNotifier extends StateNotifier<AsyncValue<List<Seat>>> {
  final ApiService _api = ApiService();

  SeatListNotifier() : super(const AsyncValue.loading());

  Future<void> fetch(String roomId, int hallId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getRoomSeats(roomId, hallId);
      final list = (response.data as List)
          .map((e) => Seat.fromJson(e))
          .toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final seatListProvider =
    StateNotifierProvider<SeatListNotifier, AsyncValue<List<Seat>>>((ref) {
      return SeatListNotifier();
    });
