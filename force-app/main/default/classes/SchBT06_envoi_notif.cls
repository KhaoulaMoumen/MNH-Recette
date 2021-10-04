global class SchBT06_envoi_notif implements Schedulable {
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new BA08_envoi_notif(),25);
    }
    /*  executer le batch chaque jour à  6H  / 12H  / 18H :
SchBT06_envoi_notif m = new SchBT06_envoi_notif();
String sch = '0 0 6 * * ?'; 
String sch1 = '0 0 12 * * ?'; 
String sch2 = '0 0 18 * * ?'; 
String jobID = system.schedule('Run', sch, m);
String jobID1 = system.schedule('Run', sch1, m);
String jobID2 = system.schedule('Run', sch2, m);*/

}