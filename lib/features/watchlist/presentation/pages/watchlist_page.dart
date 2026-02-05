import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../shared/app_constant.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/watchlist_row.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          injector<WatchlistBloc>()
            ..add(const WatchlistStarted(symbols: AppConstant.defaultSymbols)),
      child: const _WatchlistView(),
    );
  }
}

class _WatchlistView extends StatelessWidget {
  const _WatchlistView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) {
              return Column(
                children: [
                  _HeaderRow(),
                  const Divider(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.symbols.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final symbol = state.symbols[i];
                        final point = state.latestFor(symbol);
                        return WatchlistRow(symbol: symbol, point: point);
                      },
                    ),
                  ),
                  if (state.status == WatchlistStatus.error)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.errorMessage ?? 'Unknown error',
                        style: AppConstant.errorLabelStyle(context),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = AppConstant.tableHeaderLabelStyle(context);

    return Row(
      children: [
        Expanded(flex: 3, child: Text('Symbol', style: style)),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Last', style: style),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Chg', style: style),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Chg%', style: style),
          ),
        ),
      ],
    );
  }
}
