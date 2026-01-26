import React from 'react';
import { Button} from '@mui/material';
import Alert from '@mui/material/Alert';
import AlertTitle from '@mui/material/AlertTitle';

export default function ErrorAlert({alertVisible, alertMessage, setAlertVisible}) {
    /*
    This component renders alert messages that are easily hidden, designed for errors
    alertVisible: boolean indicating if the alert should be shown
    alertMessage: the message to be displayed in the alert
    setAlertVisible: function to set the alert visibility state
    */

    const handleClose = () => {
        setAlertVisible(false);
    }

    return (
        <>
        {(alertVisible) ? (<>
            <Alert severity="error"
                action={
                    <Button color='inherit' size='small'
                        onClick={handleClose}>
                        CLOSE
                    </Button>
                }>
                <AlertTitle>Error</AlertTitle>
                {alertMessage}
            </Alert>
        </>) : (<>
        </>)}
        </>
    )
}

export function SuccessAlert({alertVisible, alertMessage, setAlertVisible}) {
    /*
    This component renders alert messages that are easily hidden, designed for success messages
    alertVisible: boolean indicating if the alert should be shown
    alertMessage: the message to be displayed in the alert
    setAlertVisible: function to set the alert visibility state
    */

    const handleClose = () => {
        setAlertVisible(false);
    }

    return (
        <>
        {(alertVisible) ? (<>
            <Alert severity="success"
                action={
                    <Button color='inherit' size='small'
                        onClick={handleClose}>
                        CLOSE
                    </Button>
                }>
                {alertMessage}
            </Alert>
        </>) : (<>
        </>)}
        </>
    )
}
