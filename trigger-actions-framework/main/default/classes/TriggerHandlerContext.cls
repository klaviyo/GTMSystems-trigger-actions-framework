public inherited sharing virtual class TriggerHandlerContext {
    private static Map<String, ContextData> contextDataByProviderKey = new Map<String, ContextData>();
    private static String lastContextTriggeringRecordsHashKey;

    public List<SObject> newRecords { public get; private set; }
    public List<SObject> oldRecords { public get; private set; }

    public TriggerHandlerContext() {
    }

    public virtual Map<String, ContextDataProvider> getContextDataProvidersByKey() {
        return new Map<String, ContextDataProvider>();
    }

    public void setTriggeringRecords(List<SObject> newRecords, List<SObject> oldRecords) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;

        String currentTriggeringRecordsHashKey = getHashKey(newRecords, oldRecords);

        Boolean contextTriggeringRecordsChanged = currentTriggeringRecordsHashKey != lastContextTriggeringRecordsHashKey;
        if (contextTriggeringRecordsChanged) {
            this.clearContextData();
        }

        lastContextTriggeringRecordsHashKey = currentTriggeringRecordsHashKey;
    }

    public Map<Id, SObject> getContextData(String dataProviderKey) {
        return this.getContextDataByProviderKey(dataProviderKey)?.recordsById;
    }

    public Map<String, SObject> getContextDataMappedByUniqueTextField(String dataProviderKey, Schema.SObjectField field) {
        ContextData contextData = this.getContextDataByProviderKey(dataProviderKey);

        contextData.addMappingByTextFieldIfNotThere(field);
        return contextData.recordsByUniqueTextField.get(field);
    }

    private ContextData getContextDataByProviderKey(String dataProviderKey) {
        ContextDataProvider provider = this.getContextDataProvidersByKey()?.get(dataProviderKey);
        if (provider == null) {
            throw new TriggerHandlerContextException('Context data provider not found for key: ' + dataProviderKey);
        }

        if (this.newRecords == null && this.oldRecords == null) {
            return new ContextData(new Map<Id, SObject>());
        }

        if (contextDataByProviderKey.get(dataProviderKey) == null) {
            Map<Id, SObject> recordsById = provider.queryRecords(this.newRecords, this.oldRecords);
            contextDataByProviderKey.put(dataProviderKey, new ContextData(recordsById));
        }

        return contextDataByProviderKey.get(dataProviderKey);
    }

    protected virtual void clearContextData() {
        contextDataByProviderKey = new Map<String, ContextData>();
        lastContextTriggeringRecordsHashKey = null;
    }

    private String getHashKey(List<SObject> newRecords, List<SObject> oldRecords) {
        return (newRecords?.hashCode() ?? 0) + '-' + (oldRecords?.hashCode() ?? 0);
    }

    public interface ContextDataProvider {
        Map<Id, SObject> queryRecords(List<SObject> triggerNew, List<SObject> triggerOld);
    }

    public class TriggerHandlerContextException extends Exception {
    }

    private class ContextData {
        public Map<Id, SObject> recordsById { public get; private set; }
        public Map<Schema.SObjectField, Map<String, SObject>> recordsByUniqueTextField { public get; private set; }

        private String sObjectTypeName;

        public ContextData(Map<Id, SObject> recordsById) {
            this.recordsById = recordsById;
            this.recordsByUniqueTextField = new Map<Schema.SObjectField, Map<String, SObject>>();
            this.sObjectTypeName = recordsById.values().getSObjectType()?.toString() ?? 'SObject';
        }

        public ContextData addMappingByTextFieldIfNotThere(Schema.SObjectField field) {
            if (this.recordsByUniqueTextField.containsKey(field)) {
                return this;
            }

            // Dynamic instantiation needed to avoid runtime casting issues when using the context
            Map<String, SObject> recordByFieldValue = (Map<String, SObject>) Type.forName('Map<String, ' + sObjectTypeName + '>').newInstance();
            for (SObject record : this.recordsById.values()) {
                String fieldValue = (String) record.get(field);
                recordByFieldValue.put(fieldValue, record);
            }

            this.recordsByUniqueTextField.put(field, recordByFieldValue);
            return this;
        }
    }
}
