public inherited sharing abstract class KlaviyoTriggerHandler {
    protected virtual Type getContextImplType() {
        return TriggerHandlerContext.class;
    }

    protected TriggerHandlerContext constructContext(List<SObject> newRecords, List<SObject> oldRecords) {
        Type contextImplType = this.getContextImplType();
        TriggerHandlerContext context = (TriggerHandlerContext) contextImplType.newInstance();
        context.setTriggeringRecords(newRecords, oldRecords);

        return context;
    }

    @TestVisible
    protected void logFailedAutomationDMLsIfAny(List<DML.DMLOperation> dmlOperations) {
        for (DML.DMLOperation dmlOperation : dmlOperations) {
            if (dmlOperation.success != false) {
                continue;
            }

            TritonBuilder logBuilder = new TritonBuilder()
                .area('TriggerHandler')
                .type('dml')
                .level(TritonTypes.Level.ERROR)
                .summary('Failed to execute DML operation')
                .details(JSON.serialize(dmlOperation));

            Triton.instance.addLog(logBuilder);
        }

        Triton.instance.flush();
    }
}
