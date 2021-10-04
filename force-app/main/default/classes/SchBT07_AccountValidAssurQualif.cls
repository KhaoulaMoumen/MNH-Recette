global class SchBT07_AccountValidAssurQualif implements Schedulable {
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new BA11_AccountValidAssurQualif(),25);
    }

}