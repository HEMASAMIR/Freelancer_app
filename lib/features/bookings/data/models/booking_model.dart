class BookingModel {
  final String? id;
  final String? userId;
  final String? listingId;
  final String? checkIn;
  final String? checkOut;
  final int? guests;
  final num? subtotal;
  final String? commissionRateId;
  final String? status;
  final String? escrowStatus;
  final String? createdAt;

  BookingModel({
    this.id,
    this.userId,
    this.listingId,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.subtotal,
    this.commissionRateId,
    this.status,
    this.escrowStatus,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      listingId: json['listing_id']?.toString(),
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      guests: json['guests'],
      subtotal: json['subtotal'],
      commissionRateId: json['commission_rate_id']?.toString(),
      status: json['status'],
      escrowStatus: json['escrow_status'],
      createdAt: json['created_at'],
    );
  }
}
