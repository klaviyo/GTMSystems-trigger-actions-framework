public inherited sharing abstract class Populator {
    public interface BeforeInsert {
        Boolean isQualifiedForPopulation(SObject newRecord, TriggerHandlerContext context);
        void populate(SObject newRecord, TriggerHandlerContext context);
    }

    public interface BeforeUpdate {
        Boolean isQualifiedForPopulation(SObject newRecord, SObject oldRecord, TriggerHandlerContext context);
        void populate(SObject newRecord, SObject oldRecord, TriggerHandlerContext context);
    }

    @TestVisible
    protected Boolean isFieldChanged(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
        return SObjectUtils.isFieldChanged(newRecord, oldRecord, field);
    }

    @TestVisible
    protected Boolean isFieldChangedToTrue(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
        return SObjectUtils.isFieldChangedToTrue(newRecord, oldRecord, field);
    }

    @TestVisible
    protected Boolean isFieldChangedToNotNull(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
        return SObjectUtils.isFieldChangedToNotNull(newRecord, oldRecord, field);
    }

    @TestVisible
    protected Boolean isAnyFieldChanged(SObject newRecord, SObject oldRecord, List<Schema.SObjectField> fields) {
        return SObjectUtils.isAnyFieldChanged(newRecord, oldRecord, fields);
    }

    protected Boolean isFieldChangeFromBlank(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
        return this.isFieldChanged(newRecord, oldRecord, field) && String.isBlank((String) oldRecord.get(field));
    }

    @TestVisible
    protected Boolean isNotNull(SObject record, Schema.SObjectField field) {
        return record.get(field) != null;
    }

    @TestVisible
    protected Boolean isNull(SObject record, Schema.SObjectField field) {
        return record.get(field) == null;
    }

    @TestVisible
    protected Boolean isNotBlank(SObject record, Schema.SObjectField field) {
        return record.get(field) != null;
    }

    @TestVisible
    protected Boolean isNot(SObject record, Schema.SObjectField field) {
        return record.get(field) == null;
    }
}
