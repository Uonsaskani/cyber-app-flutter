import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Map<String, dynamic>? _invoice;
  bool _loading = false;
  String? _status;
  Timer? _pollTimer;

  Future<void> _buy() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.requestPayment();
      setState(() {
        _invoice = data;
        _status = 'PENDING';
      });
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _check() async {
    if (_invoice == null) return;
    final status =
        await ApiService.checkPaymentStatus(_invoice!['invoiceId']);
    setState(() => _status = status);
    if (status == 'PAID') {
      _pollTimer?.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پرداخت تایید شد! اشتراک فعال شد.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خرید اشتراک')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _invoice == null
            ? Column(
                children: [
                  const Text('با خرید اشتراک، تمام ماژول‌ها باز می‌شوند.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _buy,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('ساخت فاکتور پرداخت'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('لطفاً دقیقاً همین مبلغ را واریز کنید:'),
                          const SizedBox(height: 8),
                          Text(
                            '${(_invoice!['finalAmount'] / 10).toStringAsFixed(0)} تومان',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _invoice!['cardNumber'],
                            style: const TextStyle(
                                fontSize: 18, letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('وضعیت: ${_status ?? "در انتظار"}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _check,
                    child: const Text('بررسی پرداخت'),
                  ),
                ],
              ),
      ),
    );
  }
}
