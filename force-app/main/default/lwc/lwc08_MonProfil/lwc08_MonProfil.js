import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ESP_Client_Profil_ID from '@salesforce/label/c.ESP_Client_Profil_ID';

const FIELDS = ['User.Id', 
        'User.FirstName',
        'User.LastName',
        'User.Email',
        'User.Portail_RGPD__c',
        'User.ProfileId'
    ];

export default class Lwc08_MonProfil extends LightningElement {

currentUser;
userId = USER_ID;
isNotClient = true;

@wire(getRecord, { recordId: USER_ID, fields: FIELDS })
wiredRecord({ error, data }) {
    if (error) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        console.log(message);
    } else if (data) {
        this.currentUser = data;
        if(this.currentUser.fields.ProfileId.value == ESP_Client_Profil_ID) this.isNotClient = false;
        console.log('user='+ JSON.stringify(data));
    }
}
    
handleSubmit(event) {
    console.log('onsubmit event recordEditForm'+ event.detail.fields);
}

handleSuccess(event) {
    console.log('onsuccess event recordEditForm', event.detail.id);
    
    const successEvt =new ShowToastEvent({
        title: 'Success',
        message: 'RGPD updated',
        variant: 'success'
    });
    this.dispatchEvent(successEvt);
}
}