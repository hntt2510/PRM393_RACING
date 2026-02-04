import 'package:flutter/material.dart';

class TopUpDialog extends StatefulWidget {
  final double currentBalance;
  final Function(double amount) onTopUp;

  const TopUpDialog({
    super.key,
    required this.currentBalance,
    required this.onTopUp,
  });

  @override
  State<TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<TopUpDialog> {
  double? _selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();
  bool _isCustomAmount = false;

  final List<double> _presetAmounts = [500, 1000, 2000, 5000];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _selectPresetAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _isCustomAmount = false;
      _customAmountController.clear();
    });
  }

  void _selectCustomAmount() {
    setState(() {
      _isCustomAmount = true;
      _selectedAmount = null;
    });
  }

  void _confirmTopUp() {
    double amount = 0;

    if (_isCustomAmount) {
      amount = double.tryParse(_customAmountController.text) ?? 0;
    } else {
      amount = _selectedAmount ?? 0;
    }

    if (amount > 0) {
      widget.onTopUp(amount);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hoặc nhập số tiền nạp!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  double get _newBalance {
    double amount = 0;
    if (_isCustomAmount) {
      amount = double.tryParse(_customAmountController.text) ?? 0;
    } else {
      amount = _selectedAmount ?? 0;
    }
    return widget.currentBalance + amount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nạp tiền',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Balance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.currentBalance <= 0
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.currentBalance <= 0
                        ? Colors.red.shade300
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số dư hiện tại:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.currentBalance.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.currentBalance <= 0
                            ? Colors.red.shade700
                            : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preset Amounts
              const Text(
                'Chọn mức nạp:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presetAmounts.map((amount) {
                  final isSelected =
                      _selectedAmount == amount && !_isCustomAmount;
                  return GestureDetector(
                    onTap: () => _selectPresetAmount(amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade400,
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Custom Amount
              GestureDetector(
                onTap: _selectCustomAmount,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCustomAmount ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCustomAmount
                          ? Colors.blue.shade300
                          : Colors.grey.shade300,
                      width: _isCustomAmount ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: _isCustomAmount
                            ? Colors.blue.shade700
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _customAmountController,
                          keyboardType: TextInputType.number,
                          enabled: _isCustomAmount,
                          decoration: InputDecoration(
                            hintText: 'Nhập số tiền tùy chọn',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isCustomAmount
                                ? Colors.blue.shade700
                                : Colors.grey.shade600,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Preview New Balance
              if ((_selectedAmount != null ||
                      _customAmountController.text.isNotEmpty) &&
                  _newBalance > widget.currentBalance)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số dư sau khi nạp:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_newBalance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _confirmTopUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Nạp tiền',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
