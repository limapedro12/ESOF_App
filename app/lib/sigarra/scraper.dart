import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;

main() async {
  print('\n');
  print(await getTeacherUCs("feup", 211636, 2022));
  print('\n');
  print(await getUCInfo('feup', 501680));
}

bool isInList(List<int> l, int n) {
  for (int i in l) {
    if (i == n) {return true;}
  }
  return false;
}

Future<List<int>> getTeacherUCs(String faculty, int teacher, int year) async {
  final response = await http.Client().get(Uri.parse('https://sigarra.up.pt/$faculty/pt/ds_func_relatorios.querylist?pv_doc_codigo=$teacher&pv_outras_inst=S&pv_ano_lectivo=$year'));
  String body = response.body;

  BeautifulSoup soup = BeautifulSoup(body);

  var table = soup.find('*', id: 'conteudoinner');
  table = table!.find('table');
  var rows = table!.findAll('tr');
  rows = rows.sublist(1, rows.length-3);

  List<int> ids = [];

  for (Bs4Element row in rows) {
    var a = row.find('a');
    String s = a.toString();
    s = s.substring(52, 58);
    int i = int.parse(s);
    if (!isInList(ids, i)) {
      ids.add(i);
    }
  }

  return ids;
}

Future<List<String>> getUCInfo(String faculty, int id) async {
  final response = await http.Client().get(Uri.parse('https://sigarra.up.pt/$faculty/pt/ucurr_geral.ficha_uc_view?pv_ocorrencia_id=$id'));
  String body = response.body;

  BeautifulSoup soup = BeautifulSoup(body);

  var content = soup.find('*', id: 'conteudoinner');
  var h1 = content!.findAll('h1');
  var table = soup.find('*', class_: 'formulario');
  var td = table!.findAll('td');

  String name = h1[1].toString();
  name = name.substring(4, (name.length) - 5);

  String code = td[1].toString();
  code = code.substring(4, (code.length) - 5);

  String acronym = td[4].toString();
  acronym = acronym.substring(4, (acronym.length) - 5);

  return [name, code, acronym];
}
