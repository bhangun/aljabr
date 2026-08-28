class ViewBehavior {
  final bool movable;
  final bool closable;
  final bool pinnable;
  final bool supportsSplit;

  const ViewBehavior({
    this.movable = true,
    this.closable = true,
    this.pinnable = false,
    this.supportsSplit = false,
  });

  static const fixed = ViewBehavior(
    movable: false,
    closable: false,
  );

  static const panel = ViewBehavior(
    movable: true,
    closable: true,
    pinnable: true,
  );

  static const editor = ViewBehavior(
    movable: true,
    closable: true,
    pinnable: true,
    supportsSplit: true,
  );
}
