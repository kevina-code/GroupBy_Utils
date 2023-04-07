/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : provides apex code coverage for GroupByUtils.cls
 * Created      : 04.05.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
@isTest
private class GroupByUtilsTest {
  @isTest
  static void test_groupByFieldPath() {
    List<Account> accounts = createTestAccounts();

    accounts[0].Parent = new Account();
    accounts[0].Parent.Owner = new User(FirstName = 'Bob');
    accounts[1].Parent = new Account();
    accounts[1].Parent.Owner = new User(FirstName = 'Bob');
    accounts[2].Parent = new Account();
    accounts[2].Parent.Owner = new User(FirstName = 'Sally');

    Test.startTest();
    Map<String, List<SObject>> accountsByOwnerFirstName = GroupByUtils.groupBy(
      accounts,
      'Parent.Owner.FirstName'
    );
    Test.stopTest();

    Assert.areEqual(
      accountsByOwnerFirstName.get('Bob').size(),
      2,
      'Expected accountsByOwnerFirstName to contain 2 records for "Bob"'
    );
    Assert.areEqual(
      accountsByOwnerFirstName.get('Sally').size(),
      1,
      'Expected accountsByOwnerFirstName to contain 1 record for "Sally"'
    );
  }

  @isTest
  static void test_groupByField() {
    List<Account> accounts = createTestAccounts();
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';

    Map<String, List<SObject>> accountMap = GroupByUtils.groupBy(
      accounts,
      Schema.Account.Type
    );

    Assert.areEqual(
      2,
      accountMap.get('Franchise').size(),
      'Expected accountMap to contain 2 record for "Franchise"'
    );
    Assert.areEqual(
      1,
      accountMap.get('Client').size(),
      'Expected accountMap to contain 1 record for "Client"'
    );
  }

  @isTest
  static void test_groupByFieldPath2() {
    List<Account> accounts = createTestAccounts();
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';
    update accounts;

    List<Contact> contacts = new List<Contact>();
    contacts.add(
      new Contact(
        FirstName = 'Ron',
        LastName = 'Burgandy',
        AccountId = accounts[0].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Jack',
        LastName = 'Black',
        AccountId = accounts[1].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Rose',
        LastName = 'Parks',
        AccountId = accounts[2].Id
      )
    );
    insert contacts;

    contacts = [SELECT Id, Account.Type FROM Contact WHERE Id IN :contacts];

    Map<String, List<SObject>> contactsByAccountType = GroupByUtils.groupBy(
      contacts,
      'Account.Type'
    );

    Assert.areEqual(
      2,
      contactsByAccountType.get('Franchise').size(),
      'Expected contactsByAccountType to contain 2 records for "Franchise"'
    );
    Assert.areEqual(
      1,
      contactsByAccountType.get('Client').size(),
      'Expected contactsByAccountType to contain 1 record for "Client"'
    );
  }

  @isTest
  static void test_groupByFieldUsingStrQueryParam() {
    List<Account> accounts = createTestAccounts();
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';
    update accounts;

    Map<Id, Account> accountMap = new Map<Id, Account>(accounts); // in a real scenario, this might be trigger.newMap

    Map<String, List<SObject>> accountsByType = GroupByUtils.groupBy(
      'SELECT Id, Type FROM Account WHERE Id IN :queryBindIds',
      accountMap.keySet(),
      Schema.Account.Type
    );

    Assert.areEqual(
      2,
      accountsByType.get('Franchise').size(),
      'Expected accountsByType to contain 1 record for "Franchise"'
    );
    Assert.areEqual(
      1,
      accountsByType.get('Client').size(),
      'Expected accountsByType to contain 1 record for "Client"'
    );
  }

  @isTest
  static void test_groupByFieldUsingStrQueryParam2() {
    List<Account> accounts = createTestAccounts();
    accounts[0].Type = 'Franchise';
    accounts[1].Type = 'Franchise';
    accounts[2].Type = 'Client';
    update accounts;

    List<Contact> contacts = new List<Contact>();
    contacts.add(
      new Contact(
        FirstName = 'Ron',
        LastName = 'Burgandy',
        AccountId = accounts[0].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Jack',
        LastName = 'Black',
        AccountId = accounts[1].Id
      )
    );
    contacts.add(
      new Contact(
        FirstName = 'Rose',
        LastName = 'Parks',
        AccountId = accounts[2].Id
      )
    );
    insert contacts;
    Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts); // in a real scenario, this might be trigger.newMap

    Map<String, List<SObject>> contactsByAccountType = GroupByUtils.groupBy(
      'SELECT Id, Account.Type FROM Contact WHERE Id IN :queryBindIds',
      contactMap.keySet(),
      'Account.Type'
    );

    Assert.areEqual(
      2,
      contactsByAccountType.get('Franchise').size(),
      'Expected contactsByAccountType to contain 1 record for "Franchise"'
    );
    Assert.areEqual(
      1,
      contactsByAccountType.get('Client').size(),
      'Expected contactsByAccountType to contain 1 record for "Client"'
    );
  }

  /** HELPER METHODS */
  private static List<Account> createTestAccounts() {
    List<Account> accounts = new List<Account>();
    accounts.add(new Account(Name = '1'));
    accounts.add(new Account(Name = '2'));
    accounts.add(new Account(Name = '3'));

    insert accounts;
    return accounts;
  }
}