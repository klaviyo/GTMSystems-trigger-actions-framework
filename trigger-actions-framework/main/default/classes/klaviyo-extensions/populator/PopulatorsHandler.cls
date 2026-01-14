public inherited sharing abstract class PopulatorsHandler extends KlaviyoTriggerHandler implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    protected String sObjectName;
    public interface BeforeInsert {
        List<Populator.BeforeInsert> getBeforeInsertPopulators();
    }

    public interface BeforeUpdate {
        List<Populator.BeforeUpdate> getBeforeUpdatePopulators();
    }

    private List<Trigger_Action_Populator_Override__mdt> getBeforeInsertPopulatorOverrides() {
        if (this.sObjectName == null) {
            TritonBuilder logBuilder = new TritonBuilder()
                .area('TriggerHandler')
                .type('dml')
                .level(TritonTypes.Level.FINEST)
                .summary('sObjectName must be specified in sObject Populator Handler for proper functionality');
                
            Triton.instance.addLog(logBuilder);
            return new List<Trigger_Action_Populator_Override__mdt>();
        }

        return PopulatorOverrideSelector.query().byInactive().byBeforeInsert().bySObjectTriggerSettingObjectAPIName(this.sObjectName).toList();
    }

    private List<Trigger_Action_Populator_Override__mdt> getBeforeUpdatePopulatorOverrides() {
        if (this.sObjectName == null) {
            TritonBuilder logBuilder = new TritonBuilder()
                .area('TriggerHandler')
                .type('dml')
                .level(TritonTypes.Level.FINEST)
                .summary('sObjectName must be specified in sObject Populator Handler for proper functionality');

            Triton.instance.addLog(logBuilder);
            return new List<Trigger_Action_Populator_Override__mdt>();
        }

        return PopulatorOverrideSelector.query().byInactive().byBeforeUpdate().bySObjectTriggerSettingObjectAPIName(this.sObjectName != null ? this.sObjectName : '').toList();
    }

    @TestVisible
    protected virtual String getSObjectName () {
        return null;
    }

    public void beforeInsert(List<SObject> newRecords) {
        try {
            TriggerHandlerContext context = this.constructContext(newRecords, null);

            List<Populator.BeforeInsert> beforeInsertPopulators = ((PopulatorsHandler.BeforeInsert) this).getBeforeInsertPopulators();
            if (this.sObjectName != null) {
                for (Trigger_Action_Populator_Override__mdt populator : getBeforeInsertPopulatorOverrides()) {
                    Type populatorType = Type.forName(populator.Apex_Class_Name__c);
                    Populator.BeforeInsert bIpopulator = (Populator.BeforeInsert) populatorType.newInstance();
                    if (!populator.Active__c && beforeInsertPopulators.contains(bIpopulator)) {
                        beforeInsertPopulators.remove(beforeInsertPopulators.indexOf(bIpopulator));
                    }
                }
            }

            for (Populator.BeforeInsert populator : beforeInsertPopulators) {
                for (SObject newRecord : newRecords) {
                    if (populator.isQualifiedForPopulation(newRecord, context)) {
                        populator.populate(newRecord, context);
                    }
                }
            }
        } catch (Exception e) {
            Triton.instance.log(new TritonBuilder().area('Populator').exception(e));
        }
    }

    public void beforeUpdate(List<SObject> newRecords, List<SObject> oldRecords) {
        Map<Id, SObject> newRecordsById = new Map<Id, SObject>(newRecords);
        Map<Id, SObject> oldRecordsById = new Map<Id, SObject>(oldRecords);

        TriggerHandlerContext context = this.constructContext(newRecords, oldRecords);

        try {

            List<Populator.BeforeUpdate> beforeUpdatePopulators = ((PopulatorsHandler.BeforeUpdate) this).getBeforeUpdatePopulators();
            if (this.sObjectName != null) {
                for (Trigger_Action_Populator_Override__mdt populator : getBeforeUpdatePopulatorOverrides()) {
                    Type populatorType = Type.forName(populator.Apex_Class_Name__c);
                    Populator.BeforeUpdate bUpopulator = (Populator.BeforeUpdate) populatorType.newInstance();
                    if (!populator.Active__c && beforeUpdatePopulators.contains(bUpopulator)) {
                        beforeUpdatePopulators.remove(beforeUpdatePopulators.indexOf(bUpopulator));
                    }
                }
            }
            for (Populator.BeforeUpdate populator : beforeUpdatePopulators) {
                for (Id newRecordId : newRecordsById.keySet()) {
                    SObject newRecord = newRecordsById.get(newRecordId);
                    SObject oldRecord = oldRecordsById.get(newRecordId);

                    if (populator.isQualifiedForPopulation(newRecord, oldRecord, context)) {
                        populator.populate(newRecord, oldRecord, context);
                    }
                }
            }
        } catch (Exception e) {
            Triton.instance.log(new TritonBuilder().area('Populator').exception(e));
        }
    }
}
