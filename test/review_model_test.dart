import 'package:flutter_test/flutter_test.dart';
import 'package:coorporate_gig/models/review.dart';

void main() {
  group('Review serialization', () {
    test('toJson includes worker_id when set', () {
      final review = Review(
        id: '',
        customerId: 'customer-1',
        workerId: '11111111-1111-1111-1111-111111111111',
        rating: 5,
        comment: 'Great work',
        tipWorker: true,
      );
      final json = review.toJson();
      expect(json['worker_id'], '11111111-1111-1111-1111-111111111111');
      expect(json['customer_id'], 'customer-1');
      expect(json['rating'], 5);
      expect(json['comment'], 'Great work');
      expect(json['tip_worker'], true);
    });

    test('omits worker_id when null', () {
      final review = Review(
        id: '',
        customerId: 'customer-1',
        workerId: null,
        rating: 4,
      );
      final json = review.toJson();
      expect(json.containsKey('worker_id'), isFalse);
      expect(json['customer_id'], 'customer-1');
      expect(json['rating'], 4);
    });

    test('fromJson round-trips a full review', () {
      final review = Review(
        id: 'rev-1',
        customerId: 'cust-1',
        workerId: '11111111-1111-1111-1111-111111111111',
        rating: 5,
        comment: 'Awesome',
        tipWorker: false,
      );
      final back = Review.fromJson({
        'id': 'rev-1',
        'customer_id': 'cust-1',
        'worker_id': '11111111-1111-1111-1111-111111111111',
        'rating': 5,
        'comment': 'Awesome',
        'tip_worker': false,
      });
      expect(back.id, review.id);
      expect(back.customerId, review.customerId);
      expect(back.workerId, review.workerId);
      expect(back.rating, review.rating);
      expect(back.comment, review.comment);
      expect(back.tipWorker, review.tipWorker);
    });
  });
}
