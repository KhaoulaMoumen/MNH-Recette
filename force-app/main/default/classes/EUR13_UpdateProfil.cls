global class EUR13_UpdateProfil implements Schedulable {
    
  global void execute(SchedulableContext ctx) {
        // EXECUTE BATCH WITH SCOPE = 3 
        Database.executeBatch(new BA01_UpdateAccountProfil(),3);
    
    }
}