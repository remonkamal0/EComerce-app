import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'review_order_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Address selectedAddress;
  final String deliveryMethod;
  final bool hasInstallation;

  const PaymentMethodsScreen({
    super.key,
    required this.selectedAddress,
    required this.deliveryMethod,
    this.hasInstallation = false,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const _cardMethod = 'Credit / Debit Card';
  String _selectedMethod = 'Cash on Delivery';
  final List<String> _demoCards = [];
  String? _selectedCard;

  Future<void> _addDemoCard() async {
    final lastFour = await showDialog<String>(
      context: context,
      builder: (_) => const _AddDemoCardDialog(),
    );
    if (!mounted || lastFour == null) return;
    setState(() {
      if (!_demoCards.contains(lastFour)) _demoCards.add(lastFour);
      _selectedCard = lastFour;
    });
  }

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'Cash on Delivery',
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when you receive your order',
      'icon': Icons.payments_outlined,
      'badges': <Widget>[],
    },
    {
      'id': _cardMethod,
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, etc.',
      'icon': Icons.credit_card,
      'badges': <Widget>[
        const _Badge(text: 'VISA', color: Color(0xFF1A1F71)),
        const SizedBox(width: 4),
        const _Badge(text: 'MC', color: Color(0xFFEB001B)),
        const SizedBox(width: 4),
        const _Badge(text: 'AMEX', color: Color(0xFF006FCF)),
      ],
    },
    {
      'id': 'Digital Wallet',
      'title': 'Digital Wallet',
      'subtitle': 'Pay with Apple Pay or Google Pay',
      'icon': Icons.account_balance_wallet_outlined,
      'badges': <Widget>[
        const _Badge(text: 'Pay', color: Colors.black),
        const SizedBox(width: 4),
        const _Badge(text: 'GPay', color: Color(0xFF4285F4)),
      ],
    },
    {
      'id': 'Bank Transfer',
      'title': 'Bank Transfer',
      'subtitle': 'Transfer directly to our bank account',
      'icon': Icons.account_balance_outlined,
      'badges': <Widget>[],
    },
    {
      'id': 'Installment Payment',
      'title': 'Installment Payment',
      'subtitle': 'Pay in easy installments (3, 6, 12 months)',
      'icon': Icons.sync_alt,
      'badges': <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '0% Interest',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final accentPrimary = context.themeAccent;
    final payingByCard = _selectedMethod == _cardMethod;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: const Text('Payment Methods')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            children: [
              ..._methods.map((m) {
                final isSelected = _selectedMethod == m['id'];

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.mintLightBg
                            : context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? accentPrimary
                              : context.borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              setState(() => _selectedMethod = m['id']),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.mintBg
                                        : context.surfaceBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    m['icon'] as IconData,
                                    color: accentPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m['title'] as String,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: context.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        m['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.textSecondaryColor,
                                        ),
                                      ),
                                      if ((m['badges'] as List<Widget>)
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Wrap(
                                          children: m['badges'] as List<Widget>,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Radio<String>(
                                  value: m['id'] as String,
                                  groupValue: _selectedMethod,
                                  activeColor: accentPrimary,
                                  onChanged: (val) {
                                    if (val != null)
                                      setState(() => _selectedMethod = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected && m['id'] == _cardMethod) ...[
                      Text(
                        'Demo cards for this checkout',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (_selectedCard case final String selected)
                        _CardCoverFlow(
                          cards: _demoCards,
                          selected: selected,
                          onSelected: (value) =>
                              setState(() => _selectedCard = value),
                        ),
                      TextButton.icon(
                        onPressed: _addDemoCard,
                        icon: const Icon(Icons.add),
                        label: const Text('Add demo Visa'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 12),

              // Mint Security Banner (Mockup Match)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.mintBg,
                  borderRadius: BorderRadius.circular(16),
                  border: context.isDarkMode
                      ? Border.all(color: context.borderColor)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: accentPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Checkout is in demo mode. No payment will be charged.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: CustomButton(
              text: 'Continue to Review Order',
              onPressed: payingByCard && _selectedCard == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewOrderScreen(
                            selectedAddress: widget.selectedAddress,
                            deliveryMethod: widget.deliveryMethod,
                            paymentMethod: payingByCard
                                ? 'Demo Visa •••• $_selectedCard'
                                : _selectedMethod,
                            hasInstallation: widget.hasInstallation,
                          ),
                        ),
                      );
                    },
            ),
          ),
        ),
      ),
    );
  }
}

class _CardCoverFlow extends StatefulWidget {
  const _CardCoverFlow({
    required this.cards,
    required this.selected,
    required this.onSelected,
  });

  final List<String> cards;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<_CardCoverFlow> createState() => _CardCoverFlowState();
}

class _CardCoverFlowState extends State<_CardCoverFlow> {
  late final PageController _pages = PageController(
    initialPage: widget.cards.indexOf(widget.selected),
    viewportFraction: 0.68,
  );
  int? _destination;

  @override
  void didUpdateWidget(covariant _CardCoverFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == oldWidget.selected) return;
    final index = widget.cards.indexOf(widget.selected);
    if (_pages.hasClients && _pages.page?.round() == index) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted ||
          !_pages.hasClients ||
          widget.cards.indexOf(widget.selected) != index)
        return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _pages.jumpToPage(index);
        return;
      }
      _destination = index;
      await _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      if (mounted && _destination == index) {
        _destination = null;
        final visible = _pages.page?.round();
        if (visible != null && widget.cards[visible] != widget.selected) {
          widget.onSelected(widget.cards[visible]);
        }
      }
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final accent = context.themeAccent;
    return SizedBox(
      height: 136 + MediaQuery.textScalerOf(context).scale(14) * 2,
      child: PageView.builder(
        controller: _pages,
        allowImplicitScrolling: true,
        itemCount: widget.cards.length,
        onPageChanged: (index) {
          if (_destination == null && widget.cards[index] != widget.selected) {
            widget.onSelected(widget.cards[index]);
          }
        },
        itemBuilder: (context, index) {
          final card = widget.cards[index];
          final selected = card == widget.selected;
          return AnimatedBuilder(
            animation: _pages,
            child: Semantics(
              button: true,
              selected: selected,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 13,
                ),
                child: Material(
                  color: selected ? accent : context.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: selected ? accent : context.borderColor,
                    ),
                  ),
                  elevation: selected ? 5 : 0,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => widget.onSelected(card),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            selected ? Icons.check_circle : Icons.credit_card,
                            color: selected ? Colors.white : accent,
                          ),
                          Text(
                            'Demo Visa •••• $card',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : context.textPrimaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            builder: (context, child) {
              if (reducedMotion) return child!;
              final page = _pages.hasClients
                  ? _pages.page ?? _pages.initialPage.toDouble()
                  : _pages.initialPage.toDouble();
              final offset = (index - page).clamp(-1.0, 1.0).toDouble();
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY(offset * (rtl ? 0.52 : -0.52)),
                child: Transform.scale(
                  scale: 1 - offset.abs() * 0.16,
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddDemoCardDialog extends StatefulWidget {
  const _AddDemoCardDialog();

  @override
  State<_AddDemoCardDialog> createState() => _AddDemoCardDialogState();
}

class _AddDemoCardDialogState extends State<_AddDemoCardDialog> {
  String _digits = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add demo Visa'),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 4,
        decoration: const InputDecoration(labelText: 'Four test digits'),
        onChanged: (value) => setState(() => _digits = value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _digits.length == 4
              ? () => Navigator.pop(context, _digits)
              : null,
          child: const Text('Add card'),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
