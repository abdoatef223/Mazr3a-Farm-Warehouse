import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/helpers/text_normalizer.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inventory/data/datasource/inventory_local_datasource.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';
import 'package:mazr3a/features/inventory/domain/repo/inventory_repo.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

@Injectable(as: InventoryRepo)
class InventoryRepoImpl implements InventoryRepo {
  const InventoryRepoImpl(this._dataSource);

  final InventoryLocalDataSource _dataSource;

  @override
  FutureApiResult<List<InventoryItem>> getInventoryLevels() async {
    try {
      final inbounds = await _dataSource.getInbounds();
      final outbounds = await _dataSource.getOutbounds();

      final inboundGroups = <String, List<InboundReceiptEntity>>{};
      for (final r in inbounds) {
        final key = generateInventoryGroupKey(
          product: r.item,
          type: r.type,
          unit: r.unit,
        );
        inboundGroups.putIfAbsent(key, () => []).add(r);
      }

      final outboundGroups = <String, List<OutboundShipmentEntity>>{};
      for (final s in outbounds) {
        final key = generateInventoryGroupKey(
          product: s.product,
          type: s.type,
          unit: s.unit,
        );
        outboundGroups.putIfAbsent(key, () => []).add(s);
      }

      final allKeys = <String>{...inboundGroups.keys, ...outboundGroups.keys};
      final items = <InventoryItem>[];

      for (final key in allKeys) {
        final groupInbounds = inboundGroups[key] ?? [];
        final groupOutbounds = outboundGroups[key] ?? [];

        // Sort inbounds newest first to obtain the most recent inbound record's details
        groupInbounds.sort((a, b) {
          final d = b.date.compareTo(a.date);
          return d != 0 ? d : b.id.compareTo(a.id);
        });

        // Sort outbounds newest first as fallback if no inbounds exist
        groupOutbounds.sort((a, b) {
          final d = b.date.compareTo(a.date);
          return d != 0 ? d : b.id.compareTo(a.id);
        });

        final String displayProduct;
        final String displayType;
        final String displayUnit;
        final double lastPrice;

        if (groupInbounds.isNotEmpty) {
          final latest = groupInbounds.first;
          displayProduct = latest.item;
          displayType = latest.type;
          displayUnit = latest.unit;
          lastPrice = latest.pricePerUnit;
        } else {
          final latest = groupOutbounds.first;
          displayProduct = latest.product;
          displayType = latest.type;
          displayUnit = latest.unit;
          lastPrice = 0.0;
        }

        final totalIn = groupInbounds.fold<double>(
          0.0,
          (sum, r) => sum + r.quantity,
        );
        final totalOut = groupOutbounds.fold<double>(
          0.0,
          (sum, s) => sum + s.quantity,
        );
        final inStock = totalIn - totalOut;

        final totalInboundValue = groupInbounds.fold<double>(
          0.0,
          (sum, r) => sum + (r.quantity * r.pricePerUnit),
        );

        final weightedAvgPrice =
            totalIn > 0 ? (totalInboundValue / totalIn) : 0.0;
        final stockValue = inStock > 0 ? (inStock * weightedAvgPrice) : 0.0;

        items.add(
          InventoryItem(
            product: displayProduct,
            type: displayType,
            unit: displayUnit,
            totalIn: totalIn,
            totalOut: totalOut,
            inStock: inStock,
            lastPrice: lastPrice,
            weightedAvgPrice: weightedAvgPrice,
            stockValue: stockValue,
            normalizedKey: key,
          ),
        );
      }

      // Sort by Product ascending by default
      items.sort(
        (a, b) => a.product.toLowerCase().compareTo(b.product.toLowerCase()),
      );

      return ApiSuccess(data: items);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  FutureApiResult<List<InventoryMovement>> getInventoryMovements() async {
    try {
      final inbounds = await _dataSource.getInbounds();
      final outbounds = await _dataSource.getOutbounds();

      final inboundGroups = <String, List<InboundReceiptEntity>>{};
      for (final r in inbounds) {
        final key = generateInventoryGroupKey(
          product: r.item,
          type: r.type,
          unit: r.unit,
        );
        inboundGroups.putIfAbsent(key, () => []).add(r);
      }

      final outboundGroups = <String, List<OutboundShipmentEntity>>{};
      for (final s in outbounds) {
        final key = generateInventoryGroupKey(
          product: s.product,
          type: s.type,
          unit: s.unit,
        );
        outboundGroups.putIfAbsent(key, () => []).add(s);
      }

      final allKeys = <String>{...inboundGroups.keys, ...outboundGroups.keys};
      final allMovements = <InventoryMovement>[];

      for (final key in allKeys) {
        final groupInbounds = inboundGroups[key] ?? [];
        final groupOutbounds = outboundGroups[key] ?? [];

        // Determine latest display labels for the group
        final InboundReceiptEntity? latestInbound = groupInbounds.isNotEmpty
            ? (groupInbounds.toList()
              ..sort((a, b) {
                final d = b.date.compareTo(a.date);
                return d != 0 ? d : b.id.compareTo(a.id);
              }))
                .first
            : null;

        final OutboundShipmentEntity? latestOutbound = groupOutbounds.isNotEmpty
            ? (groupOutbounds.toList()
              ..sort((a, b) {
                final d = b.date.compareTo(a.date);
                return d != 0 ? d : b.id.compareTo(a.id);
              }))
                .first
            : null;

        final String displayProduct = latestInbound?.item ??
            latestOutbound?.product ??
            '';
        final String displayType = latestInbound?.type ??
            latestOutbound?.type ??
            '';
        final String displayUnit = latestInbound?.unit ??
            latestOutbound?.unit ??
            '';

        // Merge entries in chronological order (oldest first) to compute running balance
        final groupChronological = <_LedgerEntry>[];

        for (final r in groupInbounds) {
          groupChronological.add(
            _LedgerEntry(
              id: r.id,
              date: r.date,
              isOutbound: false,
              quantity: r.quantity,
              reference: r.supplier,
            ),
          );
        }

        for (final s in groupOutbounds) {
          groupChronological.add(
            _LedgerEntry(
              id: s.id,
              date: s.date,
              isOutbound: true,
              quantity: s.quantity,
              reference: StringsManager.shipmentReference,
            ),
          );
        }

        // Sort ascending by date, with inbound ordered before outbound on equal date
        groupChronological.sort((a, b) {
          final d = a.date.compareTo(b.date);
          if (d != 0) return d;
          if (a.isOutbound != b.isOutbound) {
            return a.isOutbound ? 1 : -1;
          }
          return a.id.compareTo(b.id);
        });

        var balance = 0.0;
        for (final entry in groupChronological) {
          if (entry.isOutbound) {
            balance -= entry.quantity;
            allMovements.add(
              InventoryMovement(
                id: entry.id,
                date: entry.date,
                type: MovementType.outbound,
                product: displayProduct,
                itemType: displayType,
                unit: displayUnit,
                quantity: -entry.quantity,
                runningBalance: balance,
                reference: entry.reference,
                normalizedKey: key,
              ),
            );
          } else {
            balance += entry.quantity;
            allMovements.add(
              InventoryMovement(
                id: entry.id,
                date: entry.date,
                type: MovementType.inbound,
                product: displayProduct,
                itemType: displayType,
                unit: displayUnit,
                quantity: entry.quantity,
                runningBalance: balance,
                reference: entry.reference,
                normalizedKey: key,
              ),
            );
          }
        }
      }

      // Sort entire movements ledger newest first (descending date/id)
      allMovements.sort((a, b) {
        final d = b.date.compareTo(a.date);
        if (d != 0) return d;
        return b.id.compareTo(a.id);
      });

      return ApiSuccess(data: allMovements);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }
}

class _LedgerEntry {
  const _LedgerEntry({
    required this.id,
    required this.date,
    required this.isOutbound,
    required this.quantity,
    required this.reference,
  });

  final String id;
  final String date;
  final bool isOutbound;
  final double quantity;
  final String reference;
}
