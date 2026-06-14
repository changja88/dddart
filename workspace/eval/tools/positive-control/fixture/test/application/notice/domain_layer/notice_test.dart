import 'package:flutter_test/flutter_test.dart';
import 'package:smaple/application/notice/domain_layer/notice/enum/notice_category.dart';
import 'package:smaple/application/notice/domain_layer/notice/notice.dart';

void main() {
  group('NoticeCategory', () {
    test('parses every server category code', () {
      expect(NoticeCategory.fromJson('notice'), NoticeCategory.notice);
      expect(NoticeCategory.fromJson('event'), NoticeCategory.event);
      expect(NoticeCategory.fromJson('emergency'), NoticeCategory.emergency);
    });

    test('rejects unknown category codes', () {
      expect(
        () => NoticeCategory.fromJson('spam'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Notice.isHighlighted', () {
    Notice make({required bool pinned, required NoticeCategory category}) {
      return Notice(
        id: 1,
        title: 't',
        category: category,
        pinned: pinned,
        publishedAt: DateTime(2026, 6, 14),
      );
    }

    test('pinned notice is highlighted', () {
      expect(
        make(pinned: true, category: NoticeCategory.notice).isHighlighted,
        isTrue,
      );
    });

    test('emergency notice is highlighted even when not pinned', () {
      expect(
        make(pinned: false, category: NoticeCategory.emergency).isHighlighted,
        isTrue,
      );
    });

    test('plain unpinned notice is not highlighted', () {
      expect(
        make(pinned: false, category: NoticeCategory.notice).isHighlighted,
        isFalse,
      );
    });
  });

  test('Notice.fromJson maps server keys', () {
    final notice = Notice.fromJson(const {
      'id': 7,
      'title': '점검 안내',
      'category': 'emergency',
      'pinned': false,
      'published_at': '2026-06-10T09:00:00.000',
    });

    expect(notice.id, 7);
    expect(notice.category, NoticeCategory.emergency);
    expect(notice.isHighlighted, isTrue);
  });
}
