import 'mock_models.dart';

class UserData {
  static List<UserRequest> requests = [
    const UserRequest(
      id: 'r1',
      service: 'Plumbing',
      status: 'In Progress',
      date: '01 Sep 2026',
      description: 'Fix leaking kitchen sink and replace old pipes under the washbasin.',
      workerName: 'Ramesh Kumar',
    ),
    const UserRequest(
      id: 'r2',
      service: 'Housekeeping',
      status: 'Completed',
      date: '25 Aug 2026',
      description: 'Weekly deep cleaning for 2 BHK flat including kitchen and bathrooms.',
      workerName: 'Sunita Devi',
    ),
    const UserRequest(
      id: 'r3',
      service: 'AC Repair',
      status: 'Matched',
      date: '29 Aug 2026',
      description: 'AC not cooling in the bedroom. Needs gas refilling and servicing.',
      workerName: 'Suresh Yadav',
    ),
    const UserRequest(
      id: 'r4',
      service: 'Carpentry',
      status: 'Pending',
      date: '30 Aug 2026',
      description: 'Repair broken wardrobe door and fix table legs.',
      workerName: '',
    ),
  ];

  static List<AppNotification> notifications = [
    const AppNotification(
      id: 'n1',
      title: 'Worker Matched!',
      body: 'Suresh Yadav has been matched for your AC Repair request and will contact you shortly.',
      time: '10 min ago',
      type: 'match',
      read: false,
    ),
    const AppNotification(
      id: 'n2',
      title: 'Payment Successful',
      body: 'Your payment of ₹1,050 to Ramesh Kumar for Plumbing was successful.',
      time: '2 hours ago',
      type: 'payment',
      read: false,
    ),
    const AppNotification(
      id: 'n3',
      title: 'Booking Confirmed',
      body: 'Your Housekeeping booking with Sunita Devi is confirmed for 25 Aug, 9:00 AM.',
      time: '3 days ago',
      type: 'booking',
      read: true,
    ),
    const AppNotification(
      id: 'n4',
      title: 'New Worker Near You',
      body: 'A new verified Electrician is available near Dadar, rated 4.7★.',
      time: '5 days ago',
      type: 'worker',
      read: true,
    ),
    const AppNotification(
      id: 'n5',
      title: 'OTP Verified',
      body: 'Service start OTP has been verified for your plumbing request.',
      time: '1 week ago',
      type: 'otp',
      read: true,
    ),
    const AppNotification(
      id: 'n6',
      title: 'Rating Received',
      body: 'Thank you for rating Ramesh Kumar 5 stars! Your feedback helps the community.',
      time: '1 week ago',
      type: 'rating',
      read: true,
    ),
  ];

  static List<Map<String, dynamic>> transactions = [
    // id, title, amount, sign, date, type
    {'id': 't1', 'title': 'Payment to Ramesh Kumar', 'amount': 1050.0, 'sign': '-', 'date': '28 Aug 2026', 'type': 'Debit'},
    {'id': 't2', 'title': 'Wallet Top-up', 'amount': 2000.0, 'sign': '+', 'date': '28 Aug 2026', 'type': 'Credit'},
    {'id': 't3', 'title': 'Payment to Sunita Devi', 'amount': 750.0, 'sign': '-', 'date': '25 Aug 2026', 'type': 'Debit'},
    {'id': 't4', 'title': 'Cashback Reward', 'amount': 50.0, 'sign': '+', 'date': '24 Aug 2026', 'type': 'Credit'},
    {'id': 't5', 'title': 'Referral Bonus', 'amount': 150.0, 'sign': '+', 'date': '20 Aug 2026', 'type': 'Credit'},
  ];
}
