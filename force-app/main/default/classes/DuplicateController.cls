public with sharing class DuplicateController {
  // Object별 FieldSet 저장공간 -> 추후 Custom Metadata로 처리
  public static Map<String, String> objFieldSetMap = new Map<String, String>{
    'Account' => 'AcctInfo',
    'Contact' => 'ContInfo',
    'Lead' => 'LeadInfo'
  };

  // FieldSet의 Field 저장공간
  public static Map<String, List<String>> objFieldsMap = new Map<String, List<String>>();

  // Query String 저장공간
  public static Map<String, String> queryStrMap = new Map<String, String>();

  // ------ Method ------

  // Get Specific FieldSet regarding to Obj
  public static Map<String, List<String>> getFieldSet() {
    // Get FieldSet
    // Map을 For문으로 돌려서 대입하기 -> String은 Method에 적용이 안되낭?
    Schema.FieldSet acctFieldSet = Schema.SObjectType.Account.fieldSets.getMap()
      .get(objFieldSetMap.get('Account'));
    Schema.FieldSet contFieldSet = Schema.SObjectType.Contact.fieldSets.getMap()
      .get(objFieldSetMap.get('Contact'));
    Schema.FieldSet leadFieldSet = Schema.SObjectType.Lead.fieldSets.getMap()
      .get(objFieldSetMap.get('Lead'));

    // Get FieldSetMember
    Map<String, List<Schema.FieldSetMember>> FieldSetMembs = new Map<String, List<Schema.FieldSetMember>>();
    List<Schema.FieldSetMember> acctFieldSetMemb = acctFieldSet.getFields();
    List<Schema.FieldSetMember> contFieldSetMemb = contFieldSet.getFields();
    List<Schema.FieldSetMember> leadFieldSetMemb = leadFieldSet.getFields();
    FieldSetMembs.put('Account', acctFieldSetMemb);
    FieldSetMembs.put('Contact', contFieldSetMemb);
    FieldSetMembs.put('Lead', leadFieldSetMemb);

    // Get Fields & Add to Map
    for (String obj : FieldSetMembs.keySet()) {
      List<String> fields = new List<String>();
      for (Schema.FieldSetMember membs : FieldSetMembs.get(obj)) {
        fields.add(membs.fieldpath);
      }
      objFieldsMap.put(obj, fields);
    }
    return objFieldsMap;
  }

  // Create Query String - Obj별 Phone 기준 Duplicate 식별
  public static Map<String, String> createQueryStr(String searchTerm) {
    // Field Set 얻어오기
    getFieldSet();

    // Each Object

    for (String obj : objFieldsMap.keySet()) {
      String queryStr = 'SELECT ';
      String whereStr = ' WHERE ';
      for (String field : objFieldsMap.get(obj)) {
        queryStr += field + ', ';
      }
      // select ~ from
      queryStr += 'Id ';
      queryStr += 'FROM ';
      queryStr += obj;
      // where ~
      whereStr += objFieldsMap.get(obj)[1];
      whereStr += ' = ';
      whereStr += '\'' + searchTerm + '\'';
      queryStrMap.put(obj, queryStr + whereStr);
    }
    return queryStrMap;
  }

  // Execute Query
  public static List<SObject> getQueryResult() {
    getFieldSet();
    createQueryStr('01096522480');

    // Execute Query
    List<Account> acctList = Database.query(queryStrMap.get('Account'));
    List<Contact> contList = Database.query(queryStrMap.get('Contact'));
    List<Lead> leadList = Database.query(queryStrMap.get('Lead'));

    // Save Result
    List<SObject> resultList = new List<SObject>();
    resultList.addAll(acctList);
    resultList.addAll(contList);
    resultList.addAll(leadList);
    System.debug(resultList);

    return resultList;
  }
}
