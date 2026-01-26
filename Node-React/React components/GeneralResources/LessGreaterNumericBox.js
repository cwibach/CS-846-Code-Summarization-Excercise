import React from 'react';
import { TextField, InputAdornment, Typography, ThemeProvider, CssBaseline, Grid } from '@mui/material';
import { appTheme } from "../../themes/theme";


const LessGreaterNumericBox = ({ minValue, maxValue, minChange, maxChange, minLabel, maxLabel, centreLabel, icon }) => {
    /*
    This component renders two numeric input boxes side by side with labels, used for specifying minimum and maximum values
    minValue: the current value of the minimum input box
    maxValue: the current value of the maximum input box
    minChange: function to handle changes in the minimum input box
    maxChange: function to handle changes in the maximum input box
    minLabel: label for the minimum input box
    maxLabel: label for the maximum input box
    centreLabel: label displayed between the two input boxes
    icon: symbol to use within both input boxes such as $ or %
    */
    return (
        <ThemeProvider theme={appTheme}>
            <CssBaseline enableColorScheme />

            <Grid container spacing={2} alignItems={"center"}>
                <Grid item xs={3}></Grid>
                <Grid item xs={2}>
                    <Typography component={'span'}>
                        {minLabel}
                        <TextField
                            InputProps={{
                                startAdornment: <InputAdornment position="start"> {icon} </InputAdornment>
                            }}
                            value={minValue}
                            onChange={minChange}
                            fullWidth
                            style={{ backgroundColor: "#ffffff" }}
                            type="number"
                        />

                    </Typography>
                </Grid>
                <Grid item xs={2}>
                    <Typography
                        variant="h6"
                        textAlign={"center"}
                        component={'span'}
                    >
                        {centreLabel}
                    </Typography>
                </Grid>
                <Grid item xs={2}>
                    <Typography component={'span'}>
                        {maxLabel}
                        <TextField
                            InputProps={{
                                startAdornment: <InputAdornment position="start"> {icon} </InputAdornment>
                            }}
                            value={maxValue}
                            onChange={maxChange}
                            fullWidth
                            style={{ backgroundColor: "#ffffff" }}
                            type="number"
                        />

                    </Typography>
                </Grid>
                <Grid item xs={3}></Grid>
            </Grid>
        </ThemeProvider>
    )
}

export default LessGreaterNumericBox;