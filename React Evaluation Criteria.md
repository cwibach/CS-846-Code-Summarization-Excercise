## REACT ##
All React comments should be very concise, with a brief explanation of each prop passed, as well as a description of what is rendered and what key information is shown/used on the screen. Api's called are not necessary.

Each component's evaluation criteria outlines what information should be included, which should be matched if similar structures to the ones in other React files are followed.

### 1. Landlord Profile ###

#### Edit Landlord Profile ####
Criteria:
- Form to edit landlord profile info (first name, last name, phone, not email)
- Item: dictionary with landlord info
- handleChangeMode: function reverting to profile view
- userID: landlord user id
- getProfile: function to refresh profile info


Good Example (with guidelines):

    Renders a form allowing a landlord to edit their profile (first name, last name, phone).
    item: object containing current profile fields { first_name, last_name, phone }
    handleChangeMode: function to toggle edit/view mode in parent
    userID: id of the current landlord
    getProfile: function to refresh profile data after a successful save


Bad Example (without guidelines):

    EditLandlordProfile Component
    
    Renders a form that allows a landlord to edit their profile information
    (first name, last name, phone). Accepts an `item` prop containing the
    current profile values and calls the backend API to persist changes.
    Props: { item, handleChangeMode, userID, getProfile } — `getProfile` is
    invoked after a successful save to refresh the parent view.


#### Landlord Profile ####
Criteria:
- Landlord’s profile information or edit screen with:
- Name, email, phone number


Good Example (with guidelines):

    Renders the landlord profile page with navigation and an editable profile card.
    Props: none
    - uses UserContext to obtain `userId` for API calls
    - toggles Edit mode and mounts `EditLandlordProfile` for inline editing

Bad Example (without guidelines):

    LandlordProfile Component
    
    Parent view for landlord profile management. Fetches and displays the
    landlord's profile (name, email, phone), provides navigation for landlord
    actions (Add Posting, My Units), and toggles into an edit mode that
    mounts `EditLandlordProfile` for inline editing. Uses `UserContext` to
    determine the current user and calls the backend to retrieve/update data.

### 2. Search Units ###

#### Interested List ####
Criteria:
- List of renters interested in a unit
- unitID: id of the unit renters interested in
- userID: id of current user

Good Example (with guidelines):

    Renders a list of renters who expressed interest in a unit.
    unitID: posting id for the unit
    userId: current user's id (used for API filtering/context)


Bad Example (without guidelines):

    InterestedList Component
    
    Displays a list of renters who have expressed interest in a specific rental unit.
    Fetches interested renters from the backend API using the unit's posting ID and current user's ID.
    Only renders the list if there are interested renters, displaying them in a styled container
    with a purple header and utilizing the RenterList component for rendering individual renter profiles.


#### ListUnits ####
Criteria:
- List of units which can be expanded, and list of renters interested in last expanded unit
- Units: list of unit objects to display
- userID: id of the current user

Good Example (with guidelines):

    Renders a list of units with single-unit expand/collapse behavior.
    units: array of unit objects to display
    userId: current user's id (used for interest/favourite actions)

Bad Example (without guidelines):

    ListofUnits Component
    
    Manages and displays a list of rental units with expandable/collapsible functionality.
    Shows "No Results" message when no units are available. Allows users to expand a single unit
    at a time to view detailed information including landlord contact details and pricing.
    When a unit is expanded, also displays the InterestedList showing renters interested in that unit.
    Coordinates between ExpandedUnitInfo and UnexpandedUnitInfo components to toggle unit display states.



#### SearchMenuUnits ####
Criteria:
- Search menu for user to find units
- How to sort, price range, bedrooms range, bathrooms range, and favourites only all selectable
- setUnitList: function settling list of units
- setUnitMode: function to switch to list display
- setAlertVisible: set an alert to visible
- setAlertMessage: set messages of alerts
- userID: id of current user


Good Example (with guidelines):

    This component renders the search & filter UI for units (sorting, price/bed/bath ranges,
    "Only Show Favourites" toggle) and validates inputs before requesting filtered results.
    Key UI elements shown: sort options, min/max price, min/max bedrooms, min/max bathrooms, reset button, validation alerts, "Only Show Favourites" checkbox.
    setUnitList: function to update parent with filtered units
    setUnitMode: function to switch parent view into unit-list mode
    setAlertVisible: function to show/hide validation alerts in parent
    setAlertMessage: function to set the alert text in parent
    userId: current user's id (included in filter API request for favourites/permissions)

Bad Example (without guidelines):

    SearchMenuUnits Component
    
    Provides a comprehensive search and filter interface for rental units.
    Features include: sorting options (oldest/newest, price ascending/descending),
    filtering by price range, number of bedrooms, and number of bathrooms.
    Includes validation to ensure maximum values exceed minimum values and displays
    appropriate error alerts. Offers a "Reset Filters" button to clear all selections
    and an "Only Show Favourites" checkbox to filter units the user has marked as interested.
    Calls the backend API with all filter parameters and updates the parent component's unit list.

#### UnitInfoBoth ####
- Separate comment block for each component in file

ExpandedUnitInfo:
- Expanded view of unit
- Address, # bedrooms, # bathrooms, price/person, landlord contact info, if favourited by user
- Unit: dictionary with unit info
- unExpandUnit: function to collapse view
- userID: id of current user

UnExpandedUnitInfo:
- Collapsed view of unit’s info
- Address and if user has favourited unit
- Unit: dictionary with unit info
- expandUnit: function to expand view
- userID: id of current user

Good Example (with guidelines):

First Component

    This component renders the expanded unit details view (full address, # bedrooms, # bathrooms,
    per-person price, total price, and landlord contact) and a favourite/unfavourite control.
    unit: object containing unit details shown (posting_id, address, rooms, bathrooms, apt_price, phone, email, ...)
    unExpandUnit: function to collapse/hide the expanded view
    userId: current user's id (used for interest/favourite API calls)

Second Component

    Renders condensed unit info (address + favourite button).
    unit: object with unit details
    expandUnit: function to expand this unit's view
    userId: current user's id (used for interest/favourite API calls)



Bad Example (without guidelines):


    UnitInfoBoth Component
    
    Contains two exported components for displaying rental unit information:
    
    1. ExpandedUnitInfo: Shows complete unit details including address, number of bedrooms/bathrooms,
        pricing (per person and total), landlord contact information (phone and email), and a
        favourite/unfavourite button. Checks the user's interest status on mount and provides
        functionality to toggle interest. Includes a "Hide Details" button to collapse the view.
    
    2. UnexpandedUnitInfo: Shows condensed unit information with only the address and
        favourite/unfavourite button. Includes a "See Details" button to expand the view.
    
    Both components manage interest state independently, calling backend APIs to check and
    update whether the current user has marked the unit as a favourite.
