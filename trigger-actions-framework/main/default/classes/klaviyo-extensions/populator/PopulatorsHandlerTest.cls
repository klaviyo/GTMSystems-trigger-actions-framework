@IsTest(IsParallel=true)
private class PopulatorsHandlerTest {
    private static final String POPULATED_ACCOUNT_NAME = 'Populated Account';
    private static final String ACCOUNT_CONTEXT_USER_DATA_PROVIDER_KEY = 'USER';
    private static final Id ACCOUNT_ID = DatabaseService.getFakeId(Account.SObjectType);

    @IsTest
    static void beforeInsertTestWhenQualified() {
        // Setup
        Account account = new Account(Name = 'Test Account', Industry = 'IT');

        List<SObject> newAccounts = new List<SObject>{ account };

        // Test
        new CustomPopulatorsHandler().beforeInsert(newAccounts);

        // Verify
        Assert.areEqual(POPULATED_ACCOUNT_NAME, account.Name, 'The account name should be populated.');
        Assert.areEqual(getCurrentUser().Name, account.Description, 'The account description should be populated.');
    }

    @IsTest
    static void beforeUpdateTestWhenQualified() {
        // Setup
        Account oldAccount = new Account(Id = ACCOUNT_ID, Name = 'Test Account', Industry = 'IT');
        Account newAccount = new Account(Id = ACCOUNT_ID, Name = 'Test Account', Industry = 'Retail');

        List<SObject> newAccounts = new List<SObject>{ newAccount };
        List<SObject> oldAccounts = new List<SObject>{ oldAccount };

        // Test
        new CustomPopulatorsHandler().beforeUpdate(newAccounts, oldAccounts);

        // Verify
        Assert.areEqual(POPULATED_ACCOUNT_NAME, newAccount.Name, 'The account name should be populated.');
        Assert.areEqual(getCurrentUser().Name, newAccount.Description, 'The account description should be populated.');
    }

    @IsTest
    static void beforeInsertTestWhenNotQualified() {
        // Setup
        Account account = new Account(Name = 'Test Account', Industry = null);

        List<SObject> newAccounts = new List<SObject>{ account };

        // Test
        new CustomPopulatorsHandler().beforeInsert(newAccounts);

        // Verify
        Assert.areEqual('Test Account', account.Name, 'The account name should not be populated.');
        Assert.isNull(account.Description, 'The account description should not be populated.');
    }

    @IsTest
    static void beforeUpdateTestWhenNotQualified() {
        // Setup
        Account oldAccount = new Account(Id = ACCOUNT_ID, Name = 'Test Account', Industry = 'IT');
        Account newAccount = new Account(Id = ACCOUNT_ID, Name = 'Test Account', Industry = 'IT');

        List<SObject> newAccounts = new List<SObject>{ newAccount };
        List<SObject> oldAccounts = new List<SObject>{ oldAccount };

        // Test
        new CustomPopulatorsHandler().beforeUpdate(newAccounts, oldAccounts);

        // Verify
        Assert.areEqual('Test Account', newAccount.Name, 'The account name should not be populated.');
        Assert.isNull(newAccount.Description, 'The account description should not be populated.');
    }

    @IsTest
    static void bulkBeforeInsertTestWhenQualified() {
        // Setup
        List<Account> newAccounts = new List<Account>();

        for (Integer i = 0; i < 10; i++) {
            newAccounts.add(new Account(Name = 'Test Account ' + i, Industry = 'IT'));
        }

        // Test
        Integer queriesBefore = Limits.getQueries();
        new CustomPopulatorsHandler().beforeInsert(newAccounts);
        Integer queriesAfter = Limits.getQueries();

        Assert.areEqual(1, queriesAfter - queriesBefore, 'Only one query should be executed.');

        // Verify
        User currentUser = getCurrentUser();

        for (Account account : newAccounts) {
            Assert.areEqual(POPULATED_ACCOUNT_NAME, account.Name, 'The account name should be populated.');
            Assert.areEqual(currentUser.Name, account.Description, 'The account description should be populated.');
        }
    }

    @IsTest
    static void bulkBeforeUpdateTestWhenQualified() {
        // Setup
        List<Account> newAccounts = new List<Account>();
        List<Account> oldAccounts = new List<Account>();

        Account oldAccount = new Account(Id = ACCOUNT_ID, Name = 'Test Account', Industry = 'Retail');
        Account newAccount = new Account(Id = ACCOUNT_ID, Name = 'Test Account', Industry = 'IT');

        newAccounts.add(newAccount);
        oldAccounts.add(oldAccount);

        for (Integer i = 0; i < 10; i++) {
            Id accountId = DatabaseService.getFakeId(Account.SObjectType);

            newAccounts.add(new Account(Id = accountId, Name = 'Test Account ' + i, Industry = 'IT'));
            oldAccounts.add(new Account(Id = accountId, Name = 'Test Account ' + i, Industry = 'Retail'));
        }

        // Test
        Integer queriesBefore = Limits.getQueries();
        new CustomPopulatorsHandler().beforeUpdate(newAccounts, oldAccounts);
        Integer queriesAfter = Limits.getQueries();

        Assert.areEqual(1, queriesAfter - queriesBefore, 'Only one query should be executed.');

        // Verify
        User currentUser = getCurrentUser();

        Assert.areEqual(currentUser.Name, newAccount.Description, 'The account description should be populated.');

        for (Account account : newAccounts) {
            Assert.areEqual(POPULATED_ACCOUNT_NAME, account.Name, 'The account name should be populated.');
        }
    }
    

    private static User getCurrentUser() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    private without sharing class CustomPopulatorsHandler extends PopulatorsHandler implements PopulatorsHandler.BeforeInsert, PopulatorsHandler.BeforeUpdate {
        protected override Type getContextImplType() {
            return AccountContext.class;
        }

        public List<Populator.BeforeInsert> getBeforeInsertPopulators() {
            return new List<Populator.BeforeInsert>{ new AccountBeforeInsertPopulator() };
        }

        public List<Populator.BeforeUpdate> getBeforeUpdatePopulators() {
            return new List<Populator.BeforeUpdate>{ new AccountBeforeUpdatePopulator() };
        }
    }

    private without sharing class AccountBeforeInsertPopulator extends Populator implements Populator.BeforeInsert {
        public Boolean isQualifiedForPopulation(SObject newRecord, TriggerHandlerContext context) {
            return this.isNotNull(newRecord, Account.Industry);
        }

        public void populate(SObject newRecord, TriggerHandlerContext context) {
            Account account = (Account) newRecord;

            Map<Id, SObject> userByAccountId = (Map<Id, SObject>) context.getContextData(ACCOUNT_CONTEXT_USER_DATA_PROVIDER_KEY);
            User user = (User) userByAccountId.get(ACCOUNT_ID);

            account.Name = POPULATED_ACCOUNT_NAME;
            account.Description = user?.Name;
        }
    }

    private without sharing class AccountBeforeUpdatePopulator extends Populator implements Populator.BeforeUpdate {
        public Boolean isQualifiedForPopulation(SObject newRecord, SObject oldRecord, TriggerHandlerContext context) {
            return this.isFieldChanged(newRecord, oldRecord, Account.Industry);
        }

        public void populate(SObject newRecord, SObject oldRecord, TriggerHandlerContext context) {
            Account account = (Account) newRecord;

            Map<Id, SObject> userByAccountId = (Map<Id, SObject>) context.getContextData(ACCOUNT_CONTEXT_USER_DATA_PROVIDER_KEY);
            User user = (User) userByAccountId.get(ACCOUNT_ID);

            account.Name = POPULATED_ACCOUNT_NAME;
            account.Description = user?.Name;
        }
    }

    private without sharing class AccountContext extends TriggerHandlerContext {
        public override Map<String, TriggerHandlerContext.ContextDataProvider> getContextDataProvidersByKey() {
            return new Map<String, TriggerHandlerContext.ContextDataProvider>{ ACCOUNT_CONTEXT_USER_DATA_PROVIDER_KEY => new UserContextDataProvider() };
        }
    }

    private without sharing class UserContextDataProvider implements TriggerHandlerContext.ContextDataProvider {
        public Map<Id, SObject> queryRecords(List<SObject> triggerNew, List<SObject> triggerOld) {
            return new Map<Id, SObject>{ ACCOUNT_ID => [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()] };
        }
    }
}
