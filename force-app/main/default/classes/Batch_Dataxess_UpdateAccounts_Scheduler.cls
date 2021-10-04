global class Batch_Dataxess_UpdateAccounts_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_Dataxess_UpdateAccounts(), 10);
    }
  
}