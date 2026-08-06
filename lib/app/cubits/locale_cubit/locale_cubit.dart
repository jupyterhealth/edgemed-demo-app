import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';

part 'locale_state.dart';
part 'locale_cubit.freezed.dart';

@Injectable()
class LocaleCubit extends Cubit<LocaleState> {
  final LocalStorageRepository _localStorageRepository;
  LocaleCubit(this._localStorageRepository) : super(const LocaleState()) {
    init();
  }

  void init() {
    final savedLocale = _localStorageRepository.getLocale();
    if (savedLocale != null) {
      emit(state.copyWith(locale: savedLocale));
    } else {
      final phoneLocale = Locale(Platform.localeName.substring(0, 2));
      if (L10n.supported.contains(phoneLocale)) {
        emit(state.copyWith(locale: phoneLocale));
      } else {
        emit(state.copyWith(locale: L10n.supported.first));
      }
    }
  }

  void setLocale(Locale newLocale) async {
    if (L10n.supported.contains(newLocale)) {
      await _localStorageRepository.setLocale(newLocale);
      emit(state.copyWith(locale: newLocale));
    }
  }
}
