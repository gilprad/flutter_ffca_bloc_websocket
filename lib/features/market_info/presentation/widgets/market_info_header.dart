import 'package:flutter/material.dart';
import 'package:trading_view_ws/gen/assets.gen.dart';

import '../../../../shared/app_constant.dart';

class MarketInfoHeader extends StatelessWidget {
  const MarketInfoHeader({
    super.key,
    required this.symbol,
    required this.lastPrice,
    required this.dailyDiff,
    required this.dailyChangePercent,
  });

  final String symbol;
  final double lastPrice;
  final double? dailyDiff;
  final double? dailyChangePercent;

  @override
  Widget build(BuildContext context) {
    final diff = dailyDiff ?? 0.0;
    final percent = dailyChangePercent ?? 0.0;
    final up = diff >= 0;
    final color = up ? AppConstant.greenColor : AppConstant.redColor;
    final normalizedSymbol = symbol
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final icon = normalizedSymbol.startsWith('ETH')
        ? Assets.icons.icEth
        : Assets.icons.icBtc;

    return DecoratedBox(
      decoration: AppConstant.surfaceCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              child: Image.asset(icon.path),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: AppConstant.titleMedium(context)),
                  const SizedBox(height: 4),
                  Text(
                    lastPrice.toStringAsFixed(2),
                    style: AppConstant.headlineSmall(
                      context,
                    )?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${up ? '+' : ''}${diff.toStringAsFixed(2)}',
                      style: AppConstant.labelLarge(
                        context,
                      )?.copyWith(color: color, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${up ? '+' : ''}${percent.toStringAsFixed(2)}%',
                      style: AppConstant.labelMedium(
                        context,
                      )?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
