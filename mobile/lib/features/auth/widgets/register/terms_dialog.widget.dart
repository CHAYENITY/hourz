import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

class TermsDialog extends ConsumerStatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  const TermsDialog({super.key, this.onAccept, this.onCancel});

  @override
  ConsumerState<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends ConsumerState<TermsDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;
  bool _hasReachedBottom = false;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final atBottom = position.pixels >= (position.maxScrollExtent - 8);
    if (_isAtBottom != atBottom) {
      setState(() {
        _isAtBottom = atBottom;
      });
    }
    if (!_hasReachedBottom && atBottom) {
      setState(() {
        _hasReachedBottom = true;
        _isAutoScrolling = false;
      });
    }
    // If user interacts while auto-scrolling, stop auto-scroll
    if (_isAutoScrolling && !_isUserInitiatedScroll) {
      // do nothing
    } else if (_isAutoScrolling) {
      setState(() {
        _isAutoScrolling = false;
      });
    }
  }

  // Track if user is interacting (touch/drag)
  bool _isUserInitiatedScroll = false;

  void _onPointerDown(PointerDownEvent event) {
    if (_isAutoScrolling) {
      setState(() {
        _isAutoScrolling = false;
      });
    }
    _isUserInitiatedScroll = true;
  }

  void _onPointerUp(PointerUpEvent event) {
    _isUserInitiatedScroll = false;
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollController.hasClients) return;
    setState(() {
      _isAutoScrolling = true;
    });
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
    // If user didn't interrupt, set _isAutoScrolling to false
    if (mounted && _isAutoScrolling) {
      setState(() {
        _isAutoScrolling = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ข้อตกลงการใช้งาน',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ปรับปรุงล่าสุด: 12 ตุลาคม 2568',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        widget.onCancel ?? () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.mutedForeground,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroText(),
                      const SizedBox(height: 24),
                      _buildSection('1. การใช้งานทั่วไป', [
                        _buildSubSection(
                          '1.1 เราคือใคร',
                          'Hourz คือแพลตฟอร์มที่เชื่อมคนสองกลุ่ม: "ผู้จ้าง" ที่ต้องการคนช่วยงานง่าย ๆ และ "ผู้ช่วย" ที่ต้องการหารายได้ในเวลาว่าง',
                        ),
                        _buildSubSection(
                          '1.2 การยอมรับ',
                          'การที่ท่านกดปุ่ม "ยอมรับ" หรือเข้าใช้แอปของเรา ถือว่าท่านตกลงตามข้อกำหนดทั้งหมดนี้ หากไม่เห็นด้วยกับข้อไหน ท่านจะไม่สามารถใช้ Hourz ได้',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('2. บัญชีของท่าน (เป็นได้ทั้ง 2 บทบาท)', [
                        _buildSubSection(
                          '2.1 ข้อมูลส่วนตัว',
                          'ท่านต้องใช้ข้อมูลจริงในการลงทะเบียน และต้องเก็บรหัสผ่านเป็นความลับ หากมีคนอื่นใช้บัญชีของท่านโดยไม่ได้รับอนุญาต โปรดรีบแจ้งให้เราทราบ',
                        ),
                        _buildSubSection(
                          '2.2 บทบาทที่มีหยู่ (Dual Role)',
                          'บัญชีเดียวของท่านสามารถเป็นได้ทั้ง "ผู้จ้าง" และ "ผู้ช่วย" สลับกันไปมาได้ตลอดเวลา',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('3. การให้บริการ', [
                        _buildSubSection(
                          '3.1 สำหรับผู้ช่วย (Helper)',
                          'ท่านต้องตั้งค่า ตำแหน่งหลัก ที่ท่านสะดวกจะรับงาน และเปิด/ปิดสถานะ "พร้อมรับงาน" เมื่อท่านว่าง',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('4. เงื่อนไขเพิ่มเติม (Mock)', [
                        _buildSubSection(
                          '4.1 การเก็บข้อมูล',
                          'Hourz จะเก็บข้อมูลของท่านเพื่อปรับปรุงบริการและความปลอดภัย ข้อมูลจะไม่ถูกเปิดเผยแก่บุคคลที่สามโดยไม่ได้รับอนุญาต',
                        ),
                        _buildSubSection(
                          '4.2 การระงับบัญชี',
                          'หากพบการใช้งานผิดวัตถุประสงค์ Hourz ขอสงวนสิทธิ์ในการระงับบัญชีโดยไม่ต้องแจ้งล่วงหน้า',
                        ),
                        _buildSubSection(
                          '4.3 การเปลี่ยนแปลงข้อตกลง',
                          'Hourz อาจมีการปรับปรุงข้อตกลงนี้เป็นครั้งคราว กรุณาตรวจสอบข้อตกลงฉบับล่าสุดทุกครั้งก่อนใช้งาน',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('5. ข้อจำกัดความรับผิด (Mock)', [
                        _buildSubSection(
                          '5.1 การใช้งานแอป',
                          'Hourz ไม่รับผิดชอบต่อความเสียหายที่เกิดจากการใช้งานแอปพลิเคชันในทุกกรณี',
                        ),
                        _buildSubSection(
                          '5.2 ข้อมูลที่ไม่ถูกต้อง',
                          'Hourz ไม่รับประกันว่าข้อมูลทั้งหมดในแอปจะถูกต้องหรือเป็นปัจจุบันเสมอไป',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('6. ติดต่อเรา (Mock)', [
                        _buildSubSection(
                          '6.1 ช่องทางการติดต่อ',
                          'หากมีข้อสงสัยเกี่ยวกับข้อตกลงนี้ กรุณาติดต่อทีมงาน Hourz ผ่านอีเมล support@hourz.com',
                        ),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: _hasReachedBottom
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                widget.onCancel ??
                                () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onAccept,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'ยอมรับ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryForeground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAutoScrolling ? null : _scrollToBottom,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          _isAutoScrolling
                              ? 'กำลังเลื่อน...'
                              : 'เลื่อนลงไปล่างสุด',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryForeground,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    return Text(
      'ข้อตกลงเหล่านี้จะอธิบายถึงสิ่งที่ท่านและ Hourz มีความรับผิดชอบต่อกันการใช้แอปของเราหมายความว่าท่านยอมรับข้อตกลงเหล่านี้แล้ว โปรดอ่านสักครู่ก่อนเริ่มใช้งานจริง',
      style: TextStyle(fontSize: 14, color: AppColors.foreground, height: 1.5),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...content,
      ],
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
