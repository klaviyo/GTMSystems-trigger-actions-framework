@IsTest(IsParallel=true)
private class PopulatorTest {
    @IsTest
    static void isFieldChangedTest() {
        // Test
        Boolean isFieldChanged = new CustomPopulator().isFieldChangedCheck(new Account(Name = 'Test'), new Account(Name = 'Test2'), Account.Name);

        // Verify
        Assert.isTrue(isFieldChanged, 'The field should be changed.');
    }

    @IsTest
    static void isNullTest() {
        // Test
        Boolean isNull = new CustomPopulator().isNullCheck(new Account(Name = 'Test'), Account.Name);

        // Verify
        Assert.isFalse(isNull, 'The field should not be null.');
    }

    @IsTest
    static void isNotNullTest() {
        // Test
        Boolean isNotNull = new CustomPopulator().isNotNullCheck(new Account(Name = 'Test'), Account.Name);

        // Verify
        Assert.isTrue(isNotNull, 'The field should be not null.');
    }

    @IsTest
    static void isFieldChangedToTrueTest() {
        Boolean isFieldChangedToTrue = new CustomPopulator().isFieldChangedToTrueCheck(new User(IsActive = true), new User(IsActive = false), Schema.User.IsActive);

        Assert.isTrue(isFieldChangedToTrue, 'Field should be identified as changed to true.');
    }

    @IsTest
    static void isFieldChangedToNotNullTest() {
        Boolean isFieldChangedToNotNull = new CustomPopulator()
            .isFieldChangedToNotNullCheck(new Account(Name = 'Updated Name'), new Account(Name = 'Original Name'), Schema.Account.Name);

        Assert.isTrue(isFieldChangedToNotNull, 'Field should be identified as changed to not null.');
    }

    @IsTest
    static void isFieldChangedFromBlankTest() {
        Boolean isFieldChangedFromBlank = new CustomPopulator().isFieldChangeFromBlankCheck(new Account(Name = 'Original Name'), new Account(Name = ''), Schema.Account.Name);

        Assert.isTrue(isFieldChangedFromBlank, 'Field should be identified as changed from blank.');
    }

    @IsTest
    static void isNotBlankTest() {
        Boolean isNotBlank = new CustomPopulator().isNotBlankCheck(new Account(Name = 'Test'), Schema.Account.Name);

        Assert.isTrue(isNotBlank, 'Field should be identified as not blank.');
    }

    @IsTest
    static void isNotTest() {
        Boolean isNot = new CustomPopulator().isNotCheck(new Account(Name = null), Schema.Account.Name);

        Assert.isTrue(isNot, 'Field should be identified as not.');
    }

    @IsTest
    static void isAnyFieldChangedTest() {
        Boolean isAnyFieldChanged = new CustomPopulator()
            .isAnyFieldChangedCheck(
                new Account(Name = 'Updated Name', Description = 'Description'),
                new Account(Name = 'Original Name', Description = 'Description'),
                new List<Schema.SObjectField>{ Schema.Account.Name, Schema.Account.Description }
            );

        Assert.isTrue(isAnyFieldChanged, 'Name should be identified as changed.');
    }

    static void isFieldChangeFromBlankTest() {
        // Test
        Boolean isFieldChangeFromBlank = new CustomPopulator().isFieldChangeFromBlankCheck(new Account(Name = 'Test'), new Account(Name = ''), Account.Name);

        // Verify
        Assert.isTrue(isFieldChangeFromBlank, 'The field should be changed from blank.');
    }

    private class CustomPopulator extends Populator {
        public Boolean isFieldChangedCheck(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
            return this.isFieldChanged(newRecord, oldRecord, field);
        }

        public Boolean isNotNullCheck(SObject record, Schema.SObjectField field) {
            return this.isNotNull(record, field);
        }

        public Boolean isNullCheck(SObject record, Schema.SObjectField field) {
            return this.isNull(record, field);
        }

        public Boolean isFieldChangedToTrueCheck(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
            return this.isFieldChangedToTrue(newRecord, oldRecord, field);
        }

        public Boolean isFieldChangedToNotNullCheck(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
            return this.isFieldChangedToNotNull(newRecord, oldRecord, field);
        }

        public Boolean isAnyFieldChangedCheck(SObject newRecord, SObject oldRecord, List<Schema.SObjectField> fields) {
            return this.isAnyFieldChanged(newRecord, oldRecord, fields);
        }

        public Boolean isFieldChangeFromBlankCheck(SObject newRecord, SObject oldRecord, Schema.SObjectField field) {
            return this.isFieldChangeFromBlank(newRecord, oldRecord, field);
        }

        public Boolean isNotBlankCheck(SObject record, Schema.SObjectField field) {
            return this.isNotBlank(record, field);
        }

        public Boolean isNotCheck(SObject record, Schema.SObjectField field) {
            return this.isNot(record, field);
        }
    }
}
