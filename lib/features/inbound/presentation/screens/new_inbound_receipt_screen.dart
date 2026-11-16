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
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/presentation/view_model/inbound_cubit.dart';

@RoutePage()
class NewInboundReceiptScreen extends StatelessWidget {
  const NewInboundReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<InboundCubit>(),
        child: const _NewInboundReceiptView(),
      );
}

class _NewInboundReceiptView extends StatefulWidget {
  const _NewInboundReceiptView();

  @override
  State<_NewInboundReceiptView> createState() => _NewInboundReceiptViewState();
}

class _NewInboundReceiptViewState extends State<_NewInboundReceiptView> {
  final _formKey = GlobalKey<FormState>();

  final _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _itemController = TextEditingController();
  final _categoryController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _supplierController = TextEditingController();

  String? _selectedUnit = 'kg';
  String? _selectedPayment = 'Cash';

  final List<String> _units = const ['kg', 'ton', 'crate', 'bag'];
  final List<String> _payments = const ['Cash', 'Deferred'];

  @override
  void dispose() {
    _dateController.dispose();
    _itemController.dispose();
    _categoryController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
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

  void _submit(InboundCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final total = cubit.state.liveTotal;

    final receipt = InboundReceiptEntity(
      id: '',
      date: _dateController.text.trim(),
      item: _itemController.text.trim(),
      category: _categoryController.text.trim(),
      type: _typeController.text.trim(),
      quantity: quantity,
      unit: _selectedUnit ?? 'kg',
      pricePerUnit: price,
      total: total,
      supplier: _supplierController.text.trim(),
      payment: _selectedPayment?.toLowerCase() ?? 'cash',
    );

    cubit.addReceipt(receipt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfacePage,
      body: SafeArea(
        child: BlocConsumer<InboundCubit, InboundStates>(
          listener: (context, state) {
            if (state is InboundSubmitSuccess) {
              context.router.navigatePath('/inbound/log');
            } else if (state is InboundError) {
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            final cubit = InboundCubit.of(context);
            final isSubmitting = state is InboundSubmitting;

            return SingleChildScrollView(
              padding: EdgeInsets.all(32.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 820.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with green download-icon badge
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              color: colors.brandInboundGreen
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.file_download_outlined,
                              color: colors.brandInboundGreen,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                StringsManager.newInboundTitle,
                                style: AppTypography.displayH1,
                                color: colors.textPrimary,
                              ),
                              SizedBox(height: 4.h),
                              AppText(
                                StringsManager.newInboundSubtitle,
                                style: AppTypography.bodyRegular,
                                color: colors.textMuted,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),

                      // Card divided into 3 labeled bands
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
                              // Band 1: RECEIPT DETAILS
                              _buildBandHeader(
                                StringsManager.sectionReceiptDetails,
                                colors,
                              ),
                              Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Column(
                                  children: [
                                    Row(
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
                                          child: AppTextField(
                                            label: StringsManager.labelItemName,
                                            controller: _itemController,
                                            hintText: StringsManager
                                                .enterItemNameHint,
                                            validator: (val) =>
                                                (val == null || val.trim().isEmpty)
                                                    ? StringsManager.itemNameRequired
                                                    : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppTextField(
                                            label: StringsManager.labelCategory,
                                            controller: _categoryController,
                                            hintText: StringsManager
                                                .enterCategoryHint,
                                            validator: (val) =>
                                                (val == null || val.trim().isEmpty)
                                                    ? StringsManager.categoryRequired
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        Expanded(
                                          child: AppTextField(
                                            label: StringsManager.labelType,
                                            controller: _typeController,
                                            hintText: StringsManager
                                                .enterTypeHint,
                                            validator: (val) =>
                                                (val == null || val.trim().isEmpty)
                                                    ? StringsManager.typeRequired
                                                    : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Band 2: QUANTITY & PRICING
                              _buildBandHeader(
                                StringsManager.sectionQuantityPricing,
                                colors,
                              ),
                              Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: StringsManager.labelQuantity,
                                        controller: _quantityController,
                                        hintText:
                                            StringsManager.enterQuantityHint,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        useMono: true,
                                        onChanged: (_) => cubit.updateLiveTotal(
                                          quantity: _quantityController.text,
                                          unitPrice: _priceController.text,
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return StringsManager
                                                .quantityRequired;
                                          }
                                          final parsed =
                                              double.tryParse(val.trim());
                                          if (parsed == null || parsed <= 0) {
                                            return StringsManager
                                                .invalidQuantity;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    Expanded(
                                      child: AppDropdownField<String>(
                                        label: StringsManager.labelUnit,
                                        value: _selectedUnit,
                                        hintText:
                                            StringsManager.selectDropdownHint,
                                        items: _units
                                            .map(
                                              (u) => DropdownMenuItem<String>(
                                                value: u,
                                                child: Text(u),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () => _selectedUnit = val,
                                        ),
                                        validator: (val) => val == null
                                            ? StringsManager.unitRequired
                                            : null,
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    Expanded(
                                      child: AppTextField(
                                        label: StringsManager.labelPricePerUnit,
                                        controller: _priceController,
                                        hintText: StringsManager.enterPriceHint,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        useMono: true,
                                        onChanged: (_) => cubit.updateLiveTotal(
                                          quantity: _quantityController.text,
                                          unitPrice: _priceController.text,
                                        ),
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return StringsManager.priceRequired;
                                          }
                                          final parsed =
                                              double.tryParse(val.trim());
                                          if (parsed == null || parsed <= 0) {
                                            return StringsManager.invalidUnitPrice;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Band 3: SUPPLIER & PAYMENT
                              _buildBandHeader(
                                StringsManager.sectionSupplierPayment,
                                colors,
                              ),
                              Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: StringsManager.labelSupplier,
                                        controller: _supplierController,
                                        hintText: StringsManager
                                            .enterSupplierHint,
                                        validator: (val) =>
                                            (val == null || val.trim().isEmpty)
                                                ? StringsManager.supplierRequired
                                                : null,
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    Expanded(
                                      child: AppDropdownField<String>(
                                        label: StringsManager.labelPaymentType,
                                        value: _selectedPayment,
                                        hintText:
                                            StringsManager.selectDropdownHint,
                                        items: _payments
                                            .map(
                                              (p) => DropdownMenuItem<String>(
                                                value: p,
                                                child: Text(p),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () => _selectedPayment = val,
                                        ),
                                        validator: (val) => val == null
                                            ? StringsManager.paymentTypeRequired
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Summary Card above Save Button
                              ReceiptTotalCard(
                                total: state.liveTotal,
                                accentColor: colors.brandInboundGreen,
                              ),

                              // Full-width green "Save Receipt" button
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
                                child: AppButton(
                                  text: isSubmitting
                                      ? 'Saving...'
                                      : StringsManager.saveReceipt,
                                  isFullWidth: true,
                                  backgroundColor: colors.brandInboundButton,
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
