# GroupBy_Utils

Easily group a list of SObject records by a specified field or field path

Usage:
```java
// sample data:
List<Account> accounts = [SELECT Id, ParentId, Industry, Owner.UserRole.Name FROM Account LIMIT 10];
```

```java
// group accounts by ParentId:
Map<String, List<Account>> acctsByParentId = GroupByUtils.groupBy(accounts, 'ParentId');
```

```java
// group accounts by Industry:
Map<String, List<Account>> acctsByIndustry = GroupByUtils.groupBy(accounts, Account.Industry);
```

```java
// group accounts by Industry using string field param:
Map<String, List<Account>> acctsByIndustry = GroupByUtils.groupBy(accounts, 'Industry');
```

```java
// group accounts by Owner.UserRole.Name:
Map<String, List<Account>> acctsByOwnerRoleName = GroupByUtils.groupBy(accounts, 'Owner.UserRole.Name');
```


Group accounts by Owner.UserRole.Name while reducing strain on heap size:
```java
// sample data:
Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account LIMIT 10]);

Map<Id, Account> createdByNames = GroupByUtils.groupBy(
    'SELECT Owner.UserRole.Name FROM Account WHERE Id IN :queryBindIds',
    accountMap.keyset(),    /* queryBindIds */
    'Owner.UserRole.Name'   /* fieldPath */
); 
```
