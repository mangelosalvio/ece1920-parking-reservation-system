class Slot {
  String slotNo;
  String status;

  Slot({this.slotNo, this.status});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(slotNo: json['slot_no'], status: json['status']);
  }
}
