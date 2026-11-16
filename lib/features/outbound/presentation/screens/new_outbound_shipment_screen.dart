import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/theme/colors.dart';
import 'package:mazr3a/core/theme/typography.dart';
import 'package:mazr3a/core/widgets/app_button.dart';
import 'package:mazr3a/core/widgets/app_dropdown_field.dart';
import 'package:mazr3a/core/widgets/app_snack_bar.dart';
import 'package:mazr3a/core/widgets/app_text.dart';
import 'package:mazr3a/core/widgets/app_text_field.dart';
import 'package:mazr3a/core/widgets/receipt_total_card.dart';
import 'package:mazr3a/features/outbound/domain/entity/inbound_product_option_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/presentation/view_model/outbound_cubit.dart';

@RoutePage()
class NewOutboundShipmentScreen extends StatelessWidget {
  const NewOutboundShipmentScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<OutboundCubit>(),
        child: const _NewOutboundShipmentView(),
      );
}

class _NewOutboundShipmentView extends StatefulWidget {
  const _NewOutboundShipmentView();

  @override
  State<_NewOutboundShipmentView> createState() =>
      _NewOutboundShipmentViewState();
}

class _NewOutboundShipmentViewState extends State<_NewOutboundShipmentView> {
  final _formKey = GlobalKey<FormState>();

  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _productTextController = TextEditingController();
  final _fieldController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _productTextController.dispose();
    _fieldController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submit(OutboundCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = cubit.state.selectedProduct ?? '';
    final type = cubit.state.selectedType ?? '';
    final field = _fieldController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final unitPrice = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final unit = cubit.state.unit ?? '';
    final total = cubit.state.liveTotal;

    final shipment = OutboundShipmentEntity(
      id: '',
      date: _dateController.text.trim(),
      product: product,
      type: type,
      field: field.isNotEmpty ? field : null,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      total: total,
    );

    cubit.addShipment(shipment);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfacePage,
      body: SafeArea(
        child: BlocConsumer<OutboundCubit, OutboundStates>(
          listener: (context, state) {
            if (state is OutboundSubmitSuccess) {
              context.router.navigatePath('/outbound/log');
            } else if (state is OutboundError) {
              AppSnackBar.showError(context, state.message);
            }

            if (state.unit != null && _unitController.text != state.unit) {
              _unitController.text = state.unit!;
            }

            if (state.unitPrice != null) {
              final parsedEntered = double.tryParse(_priceController.text.trim());
              if (parsedEntered != state.unitPrice) {
                final formattedPrice =
                    state.unitPrice!.truncateToDouble() == state.unitPrice
                        ? state.unitPrice!.toInt().toString()
                        : state.unitPrice!.toString();
                _priceController.text = formattedPrice;
              }
            } else if (state.selectedType == null) {
              _priceController.clear();
            }

            if (state.selectedProduct != null &&
                _productTextController.text != state.selectedProduct) {
              _productTextController.text = state.selectedProduct!;
            } else if (state.selectedProduct == null &&
                _productTextController.text.isNotEmpty) {
              _productTextController.clear();
            }
          },
          builder: (context, state) {
            final cubit = OutboundCubit.of(context);
            final isSubmitting = state is OutboundSubmitting;

            final matchingOption = state.options
                .where((o) => o.product == state.selectedProduct)
                .firstOrNull;
            final availableTypes = matchingOption?.types ?? const <String>[];

            return SingleChildScrollView(
              padding: EdgeInsets.all(32.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 820.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with brown upload-icon badge
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              color: colors.brandOutboundBrown
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.file_upload_outlined,
                              color: colors.brandOutboundBrown,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  StringsManager.newOutboundTitle,
                                  style: AppTypography.displayH1,
                                  color: colors.textPrimary,
                                ),
                                SizedBox(height: 4.h),
                                AppText(
                                  StringsManager.newOutboundSubtitle,
                                  style: AppTypography.bodyRegular,
                                  color: colors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),

                      // Single Band: SHIPMENT DETAILS
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: colors.borderDefault),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBandHeader(
                                StringsManager.sectionShipmentDetails,
                                colors,
                              ),
                              Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Column(
                                  children: [
                                    // Row 1: Date & Product
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AppTextField(
                                            label: StringsManager.labelDate,
                                            controller: _dateController,
                                            readOnly: true,
                                            onTap: _pickDate,
                                            suffixIcon: Icon(
                                              Icons.calendar_today_outlined,
                                              size: 18.sp,
                                            ),
                                            validator: (val) =>
                                                (val == null || val.trim().isEmpty)
                                                    ? StringsManager.dateRequired
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        Expanded(
                                          child: state.options.isEmpty
                                              ? _buildEmptyInboundPrompt(
                                                  context,
                                                  colors,
                                                )
                                              : _buildProductDropdown(
                                                  context,
                                                  cubit,
                                                  state.options,
                                                  state.selectedProduct,
                                                  colors,
                                                ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),

                                    // Row 2: Type (Dropdown) & Field (Optional Text)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AppDropdownField<String>(
                                            label: StringsManager.labelType,
                                            value: state.selectedType,
                                            hintText: StringsManager
                                                .selectDropdownHint,
                                            items: availableTypes
                                                .map(
                                                  (t) =>
                                                      DropdownMenuItem<String>(
                                                    value: t,
                                                    child: Text(t),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              cubit.selectType(
                                                val,
                                                currentQuantity:
                                                    _quantityController.text,
                                              );
                                            },
                                            validator: (val) =>
                                                (val == null || val.trim().isEmpty)
                                                    ? StringsManager.typeRequired
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        Expanded(
                                          child: AppTextField(
                                            label: StringsManager.labelField,
                                            controller: _fieldController,
                                            hintText:
                                                StringsManager.enterFieldHint,
                                            validator: (val) {
                                              if (val != null &&
                                                  val.trim().length > 100) {
                                                return 'Max 100 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),

                                    // Row 3: Unit (Read-only) & Unit Price (Editable)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AppTextField(
                                            label: StringsManager.labelUnit,
                                            controller: _unitController,
                                            readOnly: true,
                                            hintText: '-',
                                            validator: (val) =>
                                                (val == null || val.trim().isEmpty)
                                                    ? StringsManager.unitRequired
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        Expanded(
                                          child: AppTextField(
                                            label: StringsManager.colUnitPrice,
                                            controller: _priceController,
                                            hintText: StringsManager
                                                .enterUnitPriceHint,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            useMono: true,
                                            onChanged: (val) =>
                                                cubit.updateUnitPrice(
                                              unitPrice: val,
                                              quantity:
                                                  _quantityController.text,
                                            ),
                                            validator: (val) {
                                              if (val == null ||
                                                  val.trim().isEmpty) {
                                                return StringsManager
                                                    .unitPriceRequired;
                                              }
                                              final parsed =
                                                  double.tryParse(val.trim());
                                              if (parsed == null ||
                                                  parsed < 0) {
                                                return StringsManager
                                                    .invalidUnitPrice;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),

                                    // Row 4: Quantity & Available Quantity / Warning
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppTextField(
                                                label:
                                                    StringsManager.labelQuantity,
                                                controller: _quantityController,
                                                hintText: StringsManager
                                                    .enterQuantityHint,
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                                useMono: true,
                                                onChanged: (val) =>
                                                    cubit.updateQuantity(
                                                  quantity: val,
                                                  unitPrice:
                                                      _priceController.text,
                                                ),
                                                validator: (val) {
                                                  if (val == null ||
                                                      val.trim().isEmpty) {
                                                    return StringsManager
                                                        .quantityRequired;
                                                  }
                                                  final parsed =
                                                      double.tryParse(val.trim());
                                                  if (parsed == null ||
                                                      parsed <= 0) {
                                                    return StringsManager
                                                        .invalidQuantity;
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 6.h),
                                              _buildAvailableStockLabel(
                                                state,
                                                colors,
                                              ),
                                              if (state.quantityWarning !=
                                                  null) ...[
                                                SizedBox(height: 6.h),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      size: 16.sp,
                                                      color:
                                                          colors.brandAmber,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Expanded(
                                                      child: AppText(
                                                        state.quantityWarning!,
                                                        style: AppTypography
                                                            .bodySmall,
                                                        color:
                                                            colors.brandAmber,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        const Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Total Summary Card above Save Button
                              ReceiptTotalCard(
                                total: state.liveTotal,
                                accentColor: colors.brandOutboundBrown,
                              ),

                              // Full-width brown "Save Shipment" button
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
                                child: AppButton(
                                  text: isSubmitting
                                      ? 'Saving...'
                                      : StringsManager.saveShipment,
                                  isFullWidth: true,
                                  backgroundColor: colors.brandOutboundBrown,
                                  onPressed: isSubmitting
                                      ? null
                                      : () => _submit(cubit),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyInboundPrompt(BuildContext context, AppColors colors) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            StringsManager.labelProductType,
            style: AppTypography.labelField,
            color: colors.textPrimary,
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: colors.brandAmber.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colors.brandAmber,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AppText(
                    StringsManager.addInboundFirst,
                    style: AppTypography.bodySmall,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(width: 8.w),
                AppButton(
                  text: StringsManager.newReceipt,
                  height: 36.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  backgroundColor: colors.brandInboundGreen,
                  onPressed: () => context.router.navigatePath('/inbound/new'),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildProductDropdown(
    BuildContext context,
    OutboundCubit cubit,
    List<InboundProductOptionEntity> options,
    String? selectedProduct,
    AppColors colors,
  ) =>
      RawAutocomplete<String>(
        textEditingController: _productTextController,
        focusNode: FocusNode(),
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return options.map((o) => o.product);
          }
          final query = textEditingValue.text.trim().toLowerCase();
          return options
              .map((o) => o.product)
              .where((p) => p.toLowerCase().contains(query));
        },
        onSelected: (selection) {
          cubit.selectProduct(selection);
        },
        fieldViewBuilder:
            (context, controller, focusNode, onFieldSubmitted) =>
                AppTextField(
          label: StringsManager.labelProductType,
          controller: controller,
          focusNode: focusNode,
          hintText: StringsManager.enterProductHint,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.textMuted,
          ),
          onChanged: (val) {
            if (options.any((o) => o.product == val.trim())) {
              cubit.selectProduct(val.trim());
            } else if (selectedProduct != null) {
              cubit.selectProduct(null);
            }
          },
          validator: (val) {
            final effective = cubit.state.selectedProduct;
            if (effective == null || effective.isEmpty) {
              return StringsManager.productRequired;
            }
            return null;
          },
        ),
        optionsViewBuilder: (context, onSelected, filteredOptions) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8.r),
            color: colors.surfaceCard,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 220.h,
                maxWidth: 360.w,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = filteredOptions.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: AppText(
                      option,
                      style: AppTypography.bodyRegular,
                      color: colors.textPrimary,
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        ),
      );

  Widget _buildAvailableStockLabel(OutboundStates state, AppColors colors) {
    final available = state.availableQuantity;
    final formattedAvailable = available != null
        ? (available.truncateToDouble() == available
            ? available.toInt().toString()
            : available.toString())
        : '0';
    final unit = state.unit ?? '';

    return AppText(
      '${StringsManager.availableStock} $formattedAvailable $unit'.trim(),
      style: AppTypography.monoData,
      color: colors.textMuted,
    );
  }

  Widget _buildBandHeader(String label, AppColors colors) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colors.surfaceTableHead,
          border: Border(
            top: BorderSide(color: colors.borderDefault),
            bottom: BorderSide(color: colors.borderDefault),
          ),
        ),
        child: AppText(
          label,
          style: AppTypography.labelSectionMono,
          color: colors.textMuted,
        ),
      );
}
