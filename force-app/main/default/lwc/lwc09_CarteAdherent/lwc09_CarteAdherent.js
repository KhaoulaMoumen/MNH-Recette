import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import sendEmailVerif from '@salesforce/apex/CTRL06_UserProfile.sendEmailverification';
import ESP_Client_Profil_ID from '@salesforce/label/c.ESP_Client_Profil_ID';

const FIELDS = ['User.Id', 
                'User.Account.sirenSiret__c',
                'User.AccountId',
                'User.ContactId',
                'User.FullPhotoUrl',
                'User.Account.Metier_de_reference_principal__c',
                'User.Account.Name2__c',
                'User.Name',
                'User.ProfileId'
            ];

export default class Lwc09_CarteAdherent extends LightningElement {

    userId = USER_ID;
    currentUser;
    qrCodeURL;
    siret;
    newDate = new Date();
    userName;
    photoURL;
    metierPrincipal;
    nomEnseigne;
    todayDate;
    boxAdherent = false;
    boxClient = false;

    apiURL = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=';
    verifURL = 'https://pro.synerciel.fr/VF11_QR_Checking?Siret='
    
    @track emailAddr;
    @track showButton = true;
    @track showBox = false;
    showQRCode = true;

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
            console.log('user='+ JSON.stringify(data));
            if(this.currentUser.fields.ProfileId.value == ESP_Client_Profil_ID) {
                this.boxClient = true;
                this.boxAdherent = false;
            }
            else {
                this.boxAdherent = true;
                this.boxClient = false;
            }

            if(data.fields.Account.value != null) {
                console.log("le user est relié à un compte");
                this.siret = data.fields.Account.value.fields.sirenSiret__c.value;
                this.qrCodeURL = this.apiURL + this.verifURL + this.siret;
                this.showQRCode = true;
                this.userName = data.fields.Name.value;
                this.photoURL = data.fields.FullPhotoUrl.value;
                this.metierPrincipal = data.fields.Account.value.fields.Metier_de_reference_principal__c.value;
                this.nomEnseigne = data.fields.Account.value.fields.Name2__c.value;
                this.todayDate = "Le "+this.newDate.toLocaleString();
            } else {
                // problème, le user courant n'est pas relié à un compte
                console.log("le user n'est pas relié à un compte");
                this.showQRCode = false;
            }
        }
    }

    handleEmailAddress(event) {
        this.emailAddr = event.target.value;
    }

    share(event) {
        this.showBox = true;
        this.showButton = false;
    }

    sendEmail(event) {
        console.log("sendEmail to : " + this.emailAddr);
        console.log("accountId : " + this.currentUser.fields.AccountId.value);
        console.log("contactId : " + this.currentUser.fields.ContactId.value);
        sendEmailVerif({ accountId : this.currentUser.fields.AccountId.value, contactId : this.currentUser.fields.ContactId.value,
                                    emailAddress : this.emailAddr})
            .then(result => {
                this.showToastMessage('success', 'Succès', 'Email envoyé !', '5000', 'dismissable');
                this.showBox = false;
                this.showButton = true;    
            })
            .catch(error => {  
                this.showToastMessage('error', 'Erreur !', 'Impossible d\'envoyer l\'email', '50000', 'sticky');    
                console.log('error', 'Erreur !', 'Error received: code '+ error.errorCode + ', ' +  'message ' + error.body.message);                    
            });
    }

    closeBox(event) {
        this.showBox = false;
        this.showButton = true;
    }

    showToastMessage(typeToast, titleToast, messageToDisplay, duration, mode) {
        const event = new ShowToastEvent({title: titleToast,
            message: messageToDisplay,
            duration: duration,
            key: 'info_alt',
            variant: typeToast,
            mode: mode});
        this.dispatchEvent(event);
    }
}