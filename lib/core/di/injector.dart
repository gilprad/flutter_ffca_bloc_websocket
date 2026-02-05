import 'package:get_it/get_it.dart';

import '../../features/market_info/data/datasources/crypto_ws_data_source.dart';
import '../ws/ws_manager.dart';
import '../../features/market_info/data/repositories/ws_managed_crypto_price_repository.dart';
import '../../features/market_info/domain/repositories/crypto_price_repository.dart';
import '../../features/market_info/presentation/bloc/market_info_bloc.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';

final injector = GetIt.instance;

void configureDependencies() {
  injector
    ..registerLazySingleton<CryptoWsDataSource>(() => CryptoWsDataSource())
    ..registerLazySingleton<WsManager>(() => WsManager(dataSource: injector()))
    ..registerLazySingleton<CryptoPriceRepository>(
      () => WsManagedCryptoPriceRepository(manager: injector()),
    )
    ..registerFactory<MarketInfoBloc>(
      () => MarketInfoBloc(repository: injector()),
    )
    ..registerFactory<WatchlistBloc>(
      () => WatchlistBloc(repository: injector()),
    );
}
