public with sharing class DuplicateController {
  public static Map<String, List<String>> getFields() {
    // Field Set Map
    Map<String, List<Schema.FieldSetMember>> fieldSetMap = new Map<String, List<Schema.FieldSetMember>>();

    // Get Field Set Value
    List<Schema.FieldSetMember> acctInfo = SObjectType.Account.FieldSets.AcctInfo.getFields();
    List<Schema.FieldSetMember> contInfo = SObjectType.Contact.FieldSets.ContInfo.getFields();
    List<Schema.FieldSetMember> leadInfo = SObjectType.Lead.FieldSets.LeadInfo.getFields();

    // Put Map Value
    fieldSetMap.put('Account', acctInfo);
    fieldSetMap.put('Contact', contInfo);
    fieldSetMap.put('Lead', leadInfo);

    // Set Obj & FieldSet Cols
    Map<String, List<String>> fieldListMap = new Map<String, List<String>>();
    List<String> objList = new List<String>(fieldSetMap.keySet());

    for (String obj : objList) {
      List<String> fields = new List<String>();
      for (Schema.FieldSetMember fieldList : fieldSetMap.get(obj)) {
        fields.add(fieldList.getFieldPath());
      }
      fieldListMap.put(obj, fields);
    }
    System.debug(fieldListMap);
    return fieldListMap;
  }
}
