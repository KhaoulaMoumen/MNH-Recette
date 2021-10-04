import { LightningElement , api , track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import activerPartenaire from '@salesforce/apex/Lwc07_ActiverPartenaireController.activerPartenaire';
import labelActivationNonPermise from '@salesforce/label/c.LABS_SF_MSG_ACTIVATION_PARTENAIRE_NON_PERMISE';
import labelActivationOk from '@salesforce/label/c.LABS_SF_MSG_ACTIVATION_PARTENAIRE_REUSSIE';

export default class Lwc07_ActiverPartenaire extends LightningElement {
    @api recordId;
    @track error ;
    @track record;
    @track loading = true;

    label = {
        labelActivationNonPermise,
        labelActivationOk
    };

    connectedCallback() {
        activerPartenaire({ contactId : this.recordId})
            .then(result => {
                this.showToastMessage('success', 
                                        'Succès', 
                                        this.label.labelActivationOk, 
                                        '5000', 
                                        'dismissable')                                  
                this.closeQuickAction();
            })
            .catch(error => {
                console.error(error);
                this.loading = false;

                if(error.body.message != null) {
                    // on est dans une custom exception
                    var exception = JSON.parse(error.body.message);
                    if(exception.name == "PermissionException" && exception.code == 1) {
                        this.showToastMessage('error', 
                            'Erreur', 
                            this.label.labelActivationNonPermise, 
                            '50000', 
                            'sticky'); 
                    } else {
                        this.showToastMessage('error', 
                            'Erreur', 
                             exception.message, 
                            '50000', 
                            'sticky');
                    }
                } else {
                    // exception provenant de SF
                    console.error('Exception serveur SF'); 
                    // TODO comment attraper le message d'erreur de SF ???    
                }

                this.closeQuickAction();
            });
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

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}