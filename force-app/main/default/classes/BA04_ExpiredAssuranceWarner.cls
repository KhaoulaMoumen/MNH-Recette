global class BA04_ExpiredAssuranceWarner implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        // EXECUTE BATCH WITH SCOPE = 10
        Database.executeBatch(new ExpiredAssuranceWarner(),10);
        
    }
}