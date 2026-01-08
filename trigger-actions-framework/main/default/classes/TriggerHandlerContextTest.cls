@IsTest
private class TriggerHandlerContextTest {
    private static Integer queryExecutions = 0;
    private static final String OPPORTUNITY_CONTEXT_DATA_PROVIDER_KEY = 'opportunity';

    @IsTest
    static void getContextDataRecordsReturned() {
        Account oldAccount = new Account(Id = DatabaseService.getFakeId(Account.SObjectType), Name = 'Test Account');
        Account newAccount = oldAccount.clone(true, true, true);

        TriggerHandlerContext context = new SomeAccountOpportunityContext();
        context.setTriggeringRecords(new List<SObject>{ newAccount }, new List<SObject>{ oldAccount });

        Test.startTest();
        Map<Id, SObject> accountOpportunityById = context.getContextData(OPPORTUNITY_CONTEXT_DATA_PROVIDER_KEY);
        Test.stopTest();

        Assert.areEqual(1, accountOpportunityById.size(), 'Context opportunity data should be returned.');
    }

    @IsTest
    static void getContextDataQueryRunOnceForMultipleCalls() {
        Account oldAccount = new Account(Id = DatabaseService.getFakeId(Account.SObjectType), Name = 'Test Account');
        Account newAccount = oldAccount.clone(true, true, true);

        TriggerHandlerContext context = new SomeAccountOpportunityContext();
        context.setTriggeringRecords(new List<SObject>{ newAccount }, new List<SObject>{ oldAccount });

        Test.startTest();
        context.getContextData(OPPORTUNITY_CONTEXT_DATA_PROVIDER_KEY);
        context.getContextData(OPPORTUNITY_CONTEXT_DATA_PROVIDER_KEY);
        Map<Id, SObject> accountOpportunityById = context.getContextData(OPPORTUNITY_CONTEXT_DATA_PROVIDER_KEY);
        Test.stopTest();

        Assert.areEqual(1, queryExecutions, 'Query should be run only once for multiple calls.');
        Assert.areEqual(1, accountOpportunityById.size(), 'Context opportunity data should be returned.');
    }

    public class SomeAccountOpportunityContext extends TriggerHandlerContext {
        public override Map<String, ContextDataProvider> getContextDataProvidersByKey() {
            return new Map<String, ContextDataProvider>{ OPPORTUNITY_CONTEXT_DATA_PROVIDER_KEY => new SomeOpportunityDataProvider() };
        }
    }

    public class SomeOpportunityDataProvider implements TriggerHandlerContext.ContextDataProvider {
        public Map<Id, SObject> queryRecords(List<SObject> triggerNew, List<SObject> triggerOld) {
            queryExecutions++;

            Opportunity opportunity = new Opportunity(Id = DatabaseService.getFakeId(Opportunity.SObjectType), Name = 'Test Opportunity', AccountId = triggerNew[0].Id);
            return new Map<Id, SObject>{ opportunity.Id => opportunity };
        }
    }
}
