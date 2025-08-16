
class StyleCardItemModel {
  final Enum style;
  final String product;
  final String sum;
  final String styleName;
  final String imageSrc;

  StyleCardItemModel({
    required this.style,
    required this.product,
    required this.styleName,
    required this.sum,
    required this.imageSrc
  });
}
enum Styles{
  style1,style2,style3,style4
}
