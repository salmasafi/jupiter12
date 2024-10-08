// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';

part 'jupiter_state.dart';

class JupiterCubit extends Cubit<JupiterState> {
  JupiterCubit() : super(JupiterInitial());

  Future<void> changeImage(String id) async {
    try {
      String? imageUrl = await APiService().getUserImageById(id);
      emit(ImageChangedState(imageUrl));
    } catch (e) {
      print('Error fetching image: $e');
    }
  }
}