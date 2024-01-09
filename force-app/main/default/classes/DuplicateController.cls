public with sharing class DuplicateController {
  // Object별 FieldSet 저장공간 -> 추후 Custom Metadata로 처리
  public static Map<String, String> objFieldSetMap = new Map<String, String>{
    'Account' => 'AcctInfo',
    'Contact' => 'ContInfo',
    'Lead' => 'LeadInfo'
  };
  public static Map<String, List<String>> objFieldsMap = new Map<String, List<String>>(); // FieldSet의 Field 저장공간
  public static Map<String, String> queryStrMap = new Map<String, String>(); // Query String 저장공간

  // ------ Result Class -----
  public class resClass {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String ownername;
  }

  // ------ Method ------
  // Get Specific FieldSet regarding to Obj
  @AuraEnabled(cacheable=true)
  public static Map<String, List<String>> getFieldSet() {
    // Get FieldSet
    // Map을 For문으로 돌려서 대입하기 -> String은 Method에 적용이 안되낭? // Glob
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
  public static Map<String, String> createQueryStr(String phoneNum) {
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
      whereStr += '\'' + phoneNum + '\'';
      queryStrMap.put(obj, queryStr + whereStr);
    }
    System.debug(queryStrMap);
    return queryStrMap;
  }

  // Execute Query
  @AuraEnabled
  public static List<resClass> getQueryResult(String phoneNum) {
    getFieldSet();
    createQueryStr(phoneNum);

    // Execute Query
    List<Account> acctList = Database.query(queryStrMap.get('Account'));
    List<Contact> contList = Database.query(queryStrMap.get('Contact'));
    List<Lead> leadList = Database.query(queryStrMap.get('Lead'));

    // Map to Wrapper Class -> Mapping 용 Custom Metadata***
    List<resClass> result = new List<resClass>();
    for (Account acct : acctList) {
      resClass rc = new resClass();
      rc.name = acct.Name;
      rc.phone = acct.Phone;
      rc.ownername = acct.Owner.Name;
      result.add(rc);
    }
    for (Contact cont : contList) {
      resClass rc = new resClass();
      rc.name = cont.Account.Name;
      rc.phone = cont.MobilePhone;
      rc.ownername = cont.Owner.Name;
      result.add(rc);
    }
    for (Lead lead : leadList) {
      resClass rc = new resClass();
      rc.name = lead.Company;
      rc.phone = lead.Phone;
      rc.ownername = lead.Owner.Name;
      result.add(rc);
    }
    System.debug(result);
    return result;
  }
}
