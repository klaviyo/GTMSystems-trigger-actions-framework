@isTest(isParallel=true)
private class PopulatorOverrideSelectorTest {
    @IsTest
    static void byParentId() {
        // Test
        String soql = PopulatorOverrideSelector.query().byInactive().toString();

        // Verify
        Assert.areEqual('SELECT Apex_Class_Name__c, Active__c, Before_Insert__c, Before_Update__c, sObject_Trigger_Setting__c FROM Trigger_Action_Populator_Override__mdt WHERE Active__c = :v1', soql, 'The generated SOQL should include Active__c filter.');
    }

    @IsTest
    static void byBeforeInsert() {
        // Test
        String soql = PopulatorOverrideSelector.query().byBeforeInsert().toString();

        // Verify
        Assert.areEqual('SELECT Apex_Class_Name__c, Active__c, Before_Insert__c, Before_Update__c, sObject_Trigger_Setting__c FROM Trigger_Action_Populator_Override__mdt WHERE Before_Insert__c = :v1', soql, 'The generated SOQL should include Before_Insert__c filter.');
    }

    @IsTest
    static void byBeforeUpdate() {
        // Test
        String soql = PopulatorOverrideSelector.query().byBeforeUpdate().toString();

        // Verify
        Assert.areEqual('SELECT Apex_Class_Name__c, Active__c, Before_Insert__c, Before_Update__c, sObject_Trigger_Setting__c FROM Trigger_Action_Populator_Override__mdt WHERE Before_Update__c = :v1', soql, 'The generated SOQL should include Before_Update__c filter.');
    }

    @IsTest
    static void byActive() {
        // Test
        String soql = PopulatorOverrideSelector.query().byActive().toString();

        // Verify
        Assert.areEqual('SELECT Apex_Class_Name__c, Active__c, Before_Insert__c, Before_Update__c, sObject_Trigger_Setting__c FROM Trigger_Action_Populator_Override__mdt WHERE Active__c = :v1', soql, 'The generated SOQL should include Active__c filter.');
    }

    @IsTest
    static void bySObjectTriggerSettingObjectAPIName() {
        // Test
        String soql = PopulatorOverrideSelector.query().bySObjectTriggerSettingObjectAPIName('Account').toString();

        // Verify
        Assert.areEqual('SELECT Apex_Class_Name__c, Active__c, Before_Insert__c, Before_Update__c, sObject_Trigger_Setting__c FROM Trigger_Action_Populator_Override__mdt WHERE sObject_Trigger_Setting__mdt__r.Object_API_Name__c = :v1', soql, 'The generated SOQL should include sObject_Trigger_Setting__mdt__r.Object_API_Name__c filter.');
    }
}