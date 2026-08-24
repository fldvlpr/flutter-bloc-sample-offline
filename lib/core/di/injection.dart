import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/data_providers/note_api_provider.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/data_providers/note_local_provider.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/repositories/note_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../database/app_database.dart';

final sl = GetIt.instance; // sl stands for Service Locator

void init() {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => Connectivity());

  // 2. Data Providers
  sl.registerLazySingleton(() => NoteApiProvider(sl()));
  sl.registerLazySingleton(() => NoteLocalProvider(sl()));

  // 3. Repositories
  // get_it will automatically inject the 3 required classes into the repository
  sl.registerLazySingleton(() => NoteRepository(sl(), sl(), sl()));
}
