import "package:flutter/material.dart";
import "package:pica_comic/comic_source/comic_source.dart";
import "package:pica_comic/foundation/app.dart";
import "package:pica_comic/network/res.dart";
import "package:pica_comic/views/page_template/comics_page.dart";

import "../../network/base_comic.dart";
import "../widgets/appbar.dart";
import "custom_comic_tile.dart";

class CategoryComicsPage extends StatefulWidget {
  const CategoryComicsPage({required this.category, this.param, required this.sourceKey,
    super.key});

  final String category;

  final String? param;

  final String sourceKey;

  @override
  State<CategoryComicsPage> createState() => _CategoryComicsPageState();
}

class _CategoryComicsPageState extends State<CategoryComicsPage> {
  late final CategoryComicsData data;
  late final List<CategoryComicsOptions> options;
  late List<String> optionsValue;

  void findData(){
    for(final source in ComicSource.sources){
      if(source.categoryData?.key == widget.sourceKey){
        data = source.categoryComicsData!;
        options = data.options.where((element) {
          if(element.notShowWhen.contains(widget.category)) {
            return false;
          } else if(element.showWhen != null){
            return element.showWhen!.contains(widget.category);
          }
          return true;
        }).toList();
        optionsValue = options.map((e) => e.options.keys.first).toList();
        return;
      }
    }
    throw "${widget.sourceKey} Not found";
  }

  @override
  void initState() {
    findData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: Text(widget.category),
      ),
      body: Column(
        children: [
          Expanded(child: _CustomCategoryComicsList(
            key: ValueKey("${widget.category} with ${widget.param} and $optionsValue"),
            loader: data.load,
            category: widget.category,
            options: optionsValue,
            param: widget.param,
            head: buildOptions(),
            sourceKey: widget.sourceKey,
          ))
        ],
      ),
    );
  }

  Widget buildOptionItem(String text, String value, int group, BuildContext context){
    return InkWell(
      onTap: (){
        if(value == optionsValue[group])  return;
        setState(() {
          optionsValue[group] = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: value == optionsValue[group] ?
            Theme.of(context).colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(text),
      ),
    );
  }

  Widget buildOptions(){
    List<Widget> children = [];
    for(var optionList in options){
      children.add(Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for(var option in optionList.options.entries)
            buildOptionItem(option.value, option.key, options.indexOf(optionList), context)
        ],
      ));
      if(options.last != optionList){
        children.add(const SizedBox(height: 8));
      }
    }
    return SliverToBoxAdapter(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...children,
        const Divider()
      ],
    ).paddingLeft(8).paddingRight(8),);
  }
}

class _CustomCategoryComicsList extends ComicsPage<BaseComic>{
  const _CustomCategoryComicsList({super.key, required this.loader, required this.category,
    required this.options, this.param, required this.head, required this.sourceKey});

  final CategoryComicsLoader loader;

  final String category;

  final List<String> options;

  final String? param;

  final String sourceKey;

  @override
  final Widget head;

  @override
  Future<Res<List<BaseComic>>> getComics(int i) async{
    return await loader(category, param, options, i);
  }

  @override
  String? get tag => "$category with $param and $options";

  @override
  String get title => "";

  @override
  ComicType get type => ComicType.other;

  @override
  bool get withScaffold => false;

  @override
  bool get showTitle => false;

  @override
  bool get showBackWhenError => false;

  @override
  bool get showBackWhenLoading => false;

  @override
  Widget buildItem(BuildContext context, BaseComic item) {
    return CustomComicTile(item as CustomComic);
  }
}
