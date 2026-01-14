# Populators

A framework for organizing field population logic in trigger handlers with built-in qualification checks and context data providers.

## How to Use Populators

### Step 1: Create Individual Populator Class

1. Create a class using the following convention:
   - When you want to populate a single field: `ObjectNameFieldNamePopulator`, e.g., `AccountIndustryPopulator`, `ContactAccountPopulator`.
   - When you want to populate many fields: `ObjectNameBusinessUseCasePopulator`, e.g., `AccountAddressPopulator`, `SubscriptionPartnersPopulator`
2. Your class should implement `Populator.BeforeInsert` and/or `Populator.BeforeUpdate`:
   - `Populator.BeforeInsert` when it should be invoked before insert.
   - `Populator.BeforeUpdate` when it should be invoked before update.
   - `Populator.BeforeInsert` and `Populator.BeforeUpdate` when it should be invoked in both.
3. When you implement the interfaces, you'll be required to add the following methods:
   - Before Insert: `isQualifiedForPopulation(SObject newRecord, TriggerHandlerContext context)` - here you specify if the record is qualified for population. You have to return TRUE or FALSE.
   - Before Insert: `populate(SObject newRecord, TriggerHandlerContext context)` - here you set the value of field/fields.
   - Before Update: `isQualifiedForPopulation(SObject newRecord, SObject oldRecord, TriggerHandlerContext context)` - here you specify if the record is qualified for population. You have to return TRUE or FALSE.
   - Before Update: `populate(SObject newRecord, SObject oldRecord, TriggerHandlerContext context)` - here you set the value of field/fields.
4. Done. Let's move to the next step.

```java
public class MyFieldPopulator extends Populator implements Populator.BeforeInsert, Populator.BeforeUpdate {
    // For BeforeInsert
    public Boolean isQualifiedForPopulation(SObject newRecord, TriggerHandlerContext context) {
        MyObject__c record = (MyObject__c) newRecord;
        return this.isNotNull(record, MyObject__c.SomeField__c);
    }

    // For BeforeUpdate
    public Boolean isQualifiedForPopulation(SObject newRecord, SObject oldRecord, TriggerHandlerContext context) {
        return isQualifiedForPopulation(newRecord, context);
    }

    // For BeforeInsert
    public void populate(SObject newRecord, TriggerHandlerContext context) {
        MyObject__c record = (MyObject__c) newRecord;

        Map<Id, SomeRelatedObject> relatedData = (Map<Id, SomeRelatedObject>) context.getContextData('relatedDataKey');

        record.SomeField__c = relatedData.get(record.RelatedId__c)?.SomeValue__c;
    }

    // For BeforeUpdate
    public void populate(SObject newRecord, SObject oldRecord, TriggerHandlerContext context) {
        this.populate(newRecord, context);
    }
}
```

**Note!**

- Do not execute SOQL queries directly in populators. Use `TriggerHandlerContext` which is described below.

**Helper Methods Available** (when you extend `Populator` class - it's not a must-have):

- `isFieldChanged(newRecord, oldRecord, field)` - Check if a field value changed
- `isNull(record, field)` - Check if a field is null
- `isNotNull(record, field)` - Check if a field is not null

### Step 2: Create Trigger Handler Context (Optional)

If you need to query related data, extend `TriggerHandlerContext` and define context data providers:

1. Create a class using the following convention: `MyObjectTriggerHandlerContext`, e.g., `LifecycleEventTriggerHandlerContext`
2. You have to `override` the `getContextDataProvidersByKey()` method. You'll keep key-provider pairs here.
3. Add as many inner classes as you need to query related data. Each inner class should implement `ContextDataProvider`.

```java
public class MyObjectTriggerHandlerContext extends TriggerHandlerContext {
    public static final String RELATED_DATA_KEY = 'relatedData';
    // more keys here

    public override Map<String, ContextDataProvider> getContextDataProvidersByKey() {
        return new Map<String, ContextDataProvider>{
            RELATED_DATA_KEY => new RelatedDataProvider(),
            // more key-provider pairs here
        };
    }

    public class RelatedDataProvider implements ContextDataProvider {
        public Map<Id, SObject> queryRecords(List<SObject> triggerNew, List<SObject> triggerOld) {
            Set<Id> relatedObjectIds = SObjectUtils.getIdFieldValues(triggerNew, MyObject__c.RelatedObjectId__c);

            return new Map<Id, SObject>(
                [SELECT Id, Name FROM RelatedObject__c WHERE Id IN :relatedObjectIds]
            );
        }
    }

    // more providers here
}
```

**Note!**

- You always have to return `Map<Id, SObject>`. Id can be a record Id or related object Id.
- Defined keys are kept as `static final` so they can be used in Populators where data is retrieved.
- Context will ensure that only one SOQL query will be executed, and only when it's needed.

### Step 3: Create PopulatorsHandler Implementation

1. Create an object fields populator handler using the following convention: `MyObjectFieldsPopulator`, e.g., `AccountFieldsPopulator`
2. Extend `PopulatorsHandler`.
3. Implement `PopulatorsHandler.BeforeInsert` and/or `PopulatorsHandler.BeforeUpdate`:
   - `PopulatorsHandler.BeforeInsert` when it should be invoked before insert.
   - `PopulatorsHandler.BeforeUpdate` when it should be invoked before update.
   - `PopulatorsHandler.BeforeInsert` and `PopulatorsHandler.BeforeUpdate` when it should be invoked in both.
4. When you implement the interfaces, you'll be required to add the following methods:
   - Before Insert: `getBeforeInsertPopulators` - here you specify the list of before insert populators.
   - Before Update: `getBeforeUpdatePopulators` - here you specify the list of before update populators.
5. If you completed Step 2 (TriggerHandlerContext), you will override `getContextImplType()`.

```java
public class MyObjectFieldsPopulator extends PopulatorsHandler implements PopulatorsHandler.BeforeInsert, PopulatorsHandler.BeforeUpdate {
    public override System.Type getContextImplType() {
        return MyObjectTriggerHandlerContext.class;
    }

    public List<Populator.BeforeInsert> getBeforeInsertPopulators() {
        return new List<Populator.BeforeInsert>{
            new MyFieldPopulator(),
            new AnotherFieldPopulator()
        };
    }

    public List<Populator.BeforeUpdate> getBeforeUpdatePopulators() {
        return new List<Populator.BeforeUpdate>{
            new MyFieldPopulator(),
            new DifferentFieldPopulator()
        };
    }
}
```

### Step 4: Add `MyObjectFieldsPopulator` to Trigger Action Framework

Create Custom Metadata records for Trigger Action Framework:

1. Go to Setup > Custom Metadata
2. Find `Trigger Action`
3. Create a new custom metadata record for before insert and/or before update context

## How It Works

1. **Automatic Iteration**: The framework automatically iterates through all records in the trigger, and you always operate in the context of one record
2. **Qualification Check**: For each record, it calls `isQualifiedForPopulation()` on each populator
3. **Conditional Population**: Only if qualified, it calls `populate()` to update the record
4. **Context Data**: Context providers query related data once and make it available to all populators
5. **Error Handling**: All exceptions are caught and logged via Triton

## Example: Subscription\_\_c

See `SubscriptionFieldsPopulator` for a real implementation:

- **Populators**: Individual classes in `subscription-fields-populators/` directory
- **Context**: `SubscriptionTriggerHandlerContext` provides related OpportunityLineItems, Contracts, Products, etc.
- **Handler**: `SubscriptionFieldsPopulator` registers 6 insert populators and 6 update populators

## AI Prompt Template

Use the following prompt to build populators faster with AI assistance:

```
You are a Salesforce Developer. Based on the instructions in @populator/README.md and the current implementation in @classes/handlers/Subscription__c, follow the same convention and create a new populator with the following requirements:

**Object**: [ObjectName, e.g., Account__c]
**Field(s) to populate**: [FieldName(s), e.g., Industry__c]
**Value/Logic**: [Description of what value should be set and where it comes from]
**Qualification criteria**: [When should this population occur, e.g., "only when Industry__c is null and ParentAccount__c is not null"]
**Context needed**: [Any related data that needs to be queried, e.g., "Parent Account record"]

Please create:
1. The individual populator class
2. Any necessary context provider (if querying related data)
3. Update the main FieldsPopulator to register the new populator
4. Create a test class following the existing patterns
```

### Example Usage

```
You are a Salesforce Developer. Based on the instructions in @populator/README.md and the current implementation in @classes/handlers/Subscription__c, follow the same convention and create a new populator with the following requirements:

**Object**: Account__c
**Field(s) to populate**: Industry__c, Rating__c
**Value/Logic**: Copy Industry__c and Rating__c from Parent Account
**Qualification criteria**: Only when ParentAccount__c is not null and (Industry__c is null OR Rating__c is null)
**Context needed**: Parent Account records with Industry__c and Rating__c fields

Please create:
1. The individual populator class
2. Any necessary context provider (if querying related data)
3. Update the main FieldsPopulator to register the new populator
4. Create a test class following the existing patterns
```
