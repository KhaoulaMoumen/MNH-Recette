global class BA06_ToleratedExpiredAssuranceWarner implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        // EXECUTE BATCH WITH SCOPE = 10
        Database.executeBatch(new ToleratedExpiredAssuranceWarner(),10);
        
    }
}