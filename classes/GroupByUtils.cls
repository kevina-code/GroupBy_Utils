/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : Utility class for useful groupby routines
 * Created      : 03.25.2023
 *
 * Revisions:
 * Name : Date : Notes
 */
public without sharing class GroupByUtils {
  /**
   * @description: Group a list of queried SObjects by any field or field path on the SObject.
   * For example: group accounts by ParentId
   *  This method also supports passing in a string key with relationship fields
   *  For example, if you want to group Contacts by Account.Owner.Name
   * @param   records       list of SObject records to group
   * @param   fieldPath     property to get a map by (examples: Id, Account.Owner.Name, etc)
   * @return  propToPropMap records mapped to a specified field or field path
   */
  public static Map<String, List<SObject>> groupBy(
    List<SObject> records,
    String fieldPath
  ) {
    Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
    for (SObject obj : records) {
      try {
        SObject baseObj = obj;
        SObject tempObj = obj; // if fieldPath has a "." this holds the nested objects until fields is reached
        String fieldApiName = fieldPath;
        if (fieldPath.contains('.')) {
          // ex: Account.Owner.Name
          fieldApiName = fieldPath.substringAfterLast('.');
          for (
            String pathSegment : fieldPath.substringBeforeLast('.').split('\\.')
          ) {
            // dynamically accommodate for when path contains multiple nested SObjects (ex: Account.Owner.Name)
            tempObj = (SObject) tempObj.getSobject(pathSegment);
          }
        }

        if (tempObj.get(fieldApiName) != null) {
          String fieldValue = (String) tempObj.get(fieldApiName);
          if (!propToPropMap.containsKey(fieldValue)) {
            propToPropMap.put(fieldValue, new List<SObject>());
          }
          propToPropMap.get(fieldValue).add(baseObj);
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' +
          ex.getMessage() +
          ex.getStackTraceString()
        );
      }
    }
    return propToPropMap;
  }

  /**
   * @description: Group a list of queried SObjects by any field or field path on the SObject.
   * For example: group accounts by ParentId
   *  This flavor of the method takes a query string to inject into SOQL for loop to reduce heap size
   *  This flavor of the method also supports passing in a string key with relationship fields
   *  For example, if you want to group Contacts by Account.Owner.Name
   * @param   queryStr        the query to perform to get the records to perform group by on
   * @param   queryBindIds    ids to bind query to
   * @param   fieldPath       property to get a map by (examples: Id, Account.Owner.Name, etc)
   * @return  propToPropMap   records mapped to a specified field or field path
   */
  public static Map<String, List<SObject>> groupBy(
    String queryStr,
    Set<Id> queryBindIds,
    String fieldPath
  ) {
    Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
    for (SObject obj : Database.query(queryStr)) {
      try {
        SObject baseObj = obj;
        SObject tempObj = obj; // if fieldPath has a "." this holds the nested objects until fields is reached
        String fieldApiName = fieldPath;
        if (fieldPath.contains('.')) {
          // ex: Account.Owner.Name
          fieldApiName = fieldPath.substringAfterLast('.');
          for (
            String pathSegment : fieldPath.substringBeforeLast('.').split('\\.')
          ) {
            // dynamically accommodate for when path contains multiple nested SObjects (ex: Account.Owner.Name)
            tempObj = (SObject) tempObj.getSobject(pathSegment);
          }
        }

        if (tempObj.get(fieldApiName) != null) {
          String fieldValue = (String) tempObj.get(fieldApiName);
          if (!propToPropMap.containsKey(fieldValue)) {
            propToPropMap.put(fieldValue, new List<SObject>());
          }
          propToPropMap.get(fieldValue).add(baseObj);
        }
      } catch (Exception ex) {
        System.debug(
          'Error processing record, ignoring ' +
          ex.getMessage() +
          ex.getStackTraceString()
        );
      }
    }
    return propToPropMap;
  }

  /**
   * @description   Group a list of SObjects by any field (based on field value) on the SObject.
   * @param         records       : list of SObject records to group
   * @param         sObjField     : field to parse values and group by those values (ex: Account.Industry)
   * @return        propToPropMap : records mapped to a specified field or field path
   */
  public static Map<String, List<SObject>> groupBy(
    List<SObject> records,
    Schema.SObjectField sObjField
  ) {
    Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
    for (SObject obj : records) {
      try {
        if (obj.get(sObjField) != null) {
          if (!propToPropMap.containsKey((String) obj.get(sObjField))) {
            propToPropMap.put((String) obj.get(sObjField), new List<SObject>());
          }
          propToPropMap.get((String) obj.get(sObjField)).add(obj);
        }
      } catch (Exception e) {
        System.debug(
          'Error processing record, ignoring ' +
          e.getMessage() +
          e.getStackTraceString()
        );
      }
    }
    return propToPropMap;
  }

  /**
   * @description   Group a list of SObjects by any field (based on field value) on the SObject.
   *                This flavor of the method performs a SOQL for loop to reduce heap size
   * @param         queryStr        the query to perform to get the records to perform group by on
   * @param         queryBindIds    ids to bind query to
   * @param         sObjField       field to parse values and group by those values (ex: Account.Industry)
   * @return        propToPropMap   records mapped to a specified field or field path
   */
  public static Map<String, List<SObject>> groupBy(
    String queryStr,
    Set<Id> queryBindIds,
    Schema.SObjectField sObjField
  ) {
    Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
    for (SObject obj : Database.query(queryStr)) {
      try {
        if (obj.get(sObjField) != null) {
          if (!propToPropMap.containsKey((String) obj.get(sObjField))) {
            propToPropMap.put((String) obj.get(sObjField), new List<SObject>());
          }
          propToPropMap.get((String) obj.get(sObjField)).add(obj);
        }
      } catch (Exception e) {
        System.debug(
          'Error processing record, ignoring ' +
          e.getMessage() +
          e.getStackTraceString()
        );
      }
    }
    return propToPropMap;
  }
}