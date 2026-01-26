import React from 'react';
import Typography from "@material-ui/core/Typography";
import history from '../Navigation/history';
import { Button } from '@mui/material';

const NavButton = ({ destination, text, strong }) => {
    /*
    This component renders a button to be used for page navigation
    destination: the path to navigate to when the button is clicked
    text: the text to be displayed on the button
    strong: a boolean indicating if the text should be displayed bolded or not
    */
    const goToPage = () => {
        history.push(destination);
    }

    return (
        <>
            <Button
                color="inherit"
                style={{ cursor: "pointer" }}
                onClick={goToPage}
                size='medium'
                sx={{ p: 2 }}>
                <Typography variant="h5" noWrap>
                    {(strong) ? (<>
                        <strong>{text}</strong>
                    </>) : (<>
                        {text}
                    </>)}
                </Typography>
            </Button>
        </>
    );
}

export default NavButton;
