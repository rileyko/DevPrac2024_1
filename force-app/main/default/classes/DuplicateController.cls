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

  // 결과 저장
  public static List<SObject> resultList = new List<SObject>();

  // ------ Result Class -----
  public class resClass {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String ownerId;
  }

  // ------ Method ------

  // Get Specific FieldSet regarding to Obj
  @AuraEnabled(cacheable=true)
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
  @AuraEnabled(cacheable=true)
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
  @AuraEnabled(cacheable=true)
  public static List<resClass> getQueryResult() {
    getFieldSet();
    createQueryStr('01096522480');

    // Execute Query
    List<Account> acctList = Database.query(queryStrMap.get('Account'));
    List<Contact> contList = Database.query(queryStrMap.get('Contact'));
    List<Lead> leadList = Database.query(queryStrMap.get('Lead'));

    // Save Result
    resultList.addAll(acctList);
    resultList.addAll(contList);
    resultList.addAll(leadList);

    // Map to Wrapper Class
    List<resClass> result = new List<resClass>();
    for (Account acct : acctList) {
      resClass rc = new resClass();
      rc.name = acct.Name;
      rc.phone = acct.Phone;
      rc.ownerId = acct.OwnerId;
      result.add(rc);
    }
    for (Contact cont : contList) {
      resClass rc = new resClass();
      rc.name = cont.Account.Name;
      rc.phone = cont.MobilePhone;
      rc.ownerId = cont.OwnerId;
      result.add(rc);
    }
    for (Lead lead : leadList) {
      resClass rc = new resClass();
      rc.name = lead.Company;
      rc.phone = lead.Phone;
      rc.ownerId = lead.OwnerId;
      result.add(rc);
    }
    System.debug(result);
    return result;
  }
}
