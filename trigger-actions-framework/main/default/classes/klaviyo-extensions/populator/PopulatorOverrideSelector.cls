public inherited sharing class PopulatorOverrideSelector extends SOQL implements SOQL.Selector {
    @TestVisible
    private static final String MOCK_ID = 'PopulatorOverrideSelector';

    public static PopulatorOverrideSelector query() {
        return new PopulatorOverrideSelector();
    }

    private PopulatorOverrideSelector() {
        super(Trigger_Action_Populator_Override__mdt.SObjectType);
        with(Trigger_Action_Populator_Override__mdt.Apex_Class_Name__c, Trigger_Action_Populator_Override__mdt.Active__c, Trigger_Action_Populator_Override__mdt.Before_Insert__c, Trigger_Action_Populator_Override__mdt.Before_Update__c, Trigger_Action_Populator_Override__mdt.sObject_Trigger_Setting__c);
        mockId(MOCK_ID);
    }

    public PopulatorOverrideSelector byInactive() {
        whereAre(Filter.with(Trigger_Action_Populator_Override__mdt.Active__c).equal(false));
        return this;
    }

    public PopulatorOverrideSelector byBeforeInsert() {
        whereAre(Filter.with(Trigger_Action_Populator_Override__mdt.Before_Insert__c).equal(true));
        return this;
    }

    public PopulatorOverrideSelector byBeforeUpdate() {
        whereAre(Filter.with(Trigger_Action_Populator_Override__mdt.Before_Update__c).equal(true));
        return this;
    }

    public PopulatorOverrideSelector byActive() {
        whereAre(Filter.with(Trigger_Action_Populator_Override__mdt.Active__c).equal(true));
        return this;
    }
    

    public PopulatorOverrideSelector bySObjectTriggerSettingObjectAPIName(String sobjectName) {
        whereAre(Filter.with('sObject_Trigger_Setting__mdt__r', sObject_Trigger_Setting__mdt.Object_API_Name__c).equal(sobjectName));
        return this;
    }
}