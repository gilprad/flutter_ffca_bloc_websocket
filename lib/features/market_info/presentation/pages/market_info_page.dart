import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../shared/app_constant.dart';
import '../../../watchlist/presentation/pages/watchlist_page.dart';
import '../bloc/market_info_bloc.dart';
import '../bloc/market_info_event.dart';
import '../bloc/market_info_state.dart';
import '../widgets/market_info_header.dart';
import '../widgets/scrollable_price_chart.dart';
import '../widgets/symbol_selector.dart';

class MarketInfoPage extends StatelessWidget {
  const MarketInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          injector<MarketInfoBloc>()
            ..add(const MarketInfoStarted(symbols: AppConstant.defaultSymbols)),
      child: const _MarketInfoView(),
    );
  }
}

class _MarketInfoView extends StatelessWidget {
  const _MarketInfoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Info'),
        actions: [
          IconButton(
            tooltip: 'Watchlist',
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WatchlistPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocBuilder<MarketInfoBloc, MarketInfoState>(
            builder: (context, state) {
              final selected = state.selectedSymbol;
              final points = state.pointsForSelected();
              final last = state.lastForSelected();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SymbolSelector(
                    symbols: state.symbols,
                    selected: selected,
                    onSelected: (s) => context.read<MarketInfoBloc>().add(
                      MarketInfoSymbolSelected(s),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MarketInfoHeader(
                    symbol: selected ?? '-',
                    lastPrice: last?.price ?? 0,
                    dailyDiff: last?.dailyDiff,
                    dailyChangePercent: last?.dailyChangePercent,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ScrollablePriceChart(
                      points: points,
                      pointSpacing: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.status == MarketInfoStatus.error)
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
