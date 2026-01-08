@IsTest
private class KlaviyoTriggerHandlerTest {
    @IsTest
    static void constructContext() {
        HandlerWithDefaultContextImpl handler = new HandlerWithDefaultContextImpl();
        TriggerHandlerContext context = handler.getContext(new List<SObject>(), new List<SObject>());
        Assert.isNotNull(context, 'TriggerHandlerContext instance should be returned.');
    }

    @IsTest
    static void logFailedAutomationDMLsIfAny() {
        DML.DMLOperation successInsertDML = getInsertDMLOperation(true);
        DML.DMLOperation failedInsertDML = getInsertDMLOperation(false);

        List<DML.DMLOperation> dmlOperations = new List<DML.DMLOperation>{ successInsertDML, failedInsertDML };

        Test.startTest();
        new HandlerWithDefaultContextImpl().logFailedAutomationDMLsIfAny(dmlOperations);
        Test.stopTest();

        List<pharos__Log__c> createdLogs = [SELECT Id FROM pharos__Log__c];

        Assert.areEqual(1, createdLogs.size(), 'Only one log should be created.');
    }

    private static DML.DMLOperation getInsertDMLOperation(Boolean success) {
        String dmlJSON = JSON.serialize(new Map<String, Object>{ 'dmlType' => 'INSERT_DML', 'success' => success });
        return (DML.DMLOperation) JSON.deserialize(dmlJSON, DML.InsertDML.class);
    }

    public class HandlerWithDefaultContextImpl extends KlaviyoTriggerHandler {
        public TriggerHandlerContext getContext(List<SObject> newRecords, List<SObject> oldRecords) {
            return this.constructContext(newRecords, oldRecords);
        }
    }
}
