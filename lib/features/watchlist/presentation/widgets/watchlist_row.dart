import 'package:flutter/material.dart';
import 'package:trading_view_ws/gen/assets.gen.dart';

import '../../../../shared/app_constant.dart';
import '../../../../shared/helper.dart';
import '../../../market_info/domain/entities/crypto_price_point.dart';

class WatchlistRow extends StatelessWidget {
  const WatchlistRow({super.key, required this.symbol, required this.point});

  final String symbol;
  final CryptoPricePoint? point;

  @override
  Widget build(BuildContext context) {
    final p = point;
    final last = p?.price;
    final chg = p?.dailyDiff;
    final chgPct = p?.dailyChangePercent;

    final up = (chg ?? 0) >= 0;
    final color = up ? AppConstant.greenColor : AppConstant.redColor;
    final formatPrice = Helper.formatPrice;

    final displaySymbol = symbol.replaceAll('-', '');
    final normalizedSymbol = symbol
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final icon = normalizedSymbol.startsWith('ETH')
        ? Assets.icons.icEth
        : Assets.icons.icBtc;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppConstant.secondaryContainer(context),
                  child: Image.asset(icon.path, width: 18, height: 18),
                ),
                const SizedBox(width: 10),
                Text(displaySymbol, style: AppConstant.titleSmall(context)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                last == null ? '—' : formatPrice(last),
                style: AppConstant.titleSmall(context)?.copyWith(
                  color: p == null ? null : color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                chg == null ? '—' : '${up ? '+' : ''}${formatPrice(chg)}',
                style: AppConstant.titleSmall(context)?.copyWith(
                  color: p == null ? null : color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                chgPct == null
                    ? '—'
                    : '${up ? '+' : ''}${chgPct.toStringAsFixed(2)}%',
                style: AppConstant.titleSmall(context)?.copyWith(
                  color: p == null ? null : color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
