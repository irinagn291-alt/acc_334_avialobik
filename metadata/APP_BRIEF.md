<!-- gf-brief source=359920221bc8ff4ee56dbc4e52bd88cdc5419642e793eb231431140808e739e3 written=2026-10-22T02:36:49+03:00 -->
# Poolfold
## What it is
Poolfold is a dark, full-screen house desk for one night on the floor. It splits an opening cash amount across named doors, rings walk-ins once every door is seated, and runs an eight-name house card. It is for the person working that night: seating cash, counting doors, and advancing the on-deck pair.

## Launch and onboarding
Cold launch opens straight into a three-page intro. There is no tab bar and no sign-in. The interface is always dark. Each page has a picture, a title, a line of copy, and two buttons.

1. Title "Cash". Copy: "Split tonight's opening cash across the doors before anyone rings in." Buttons: "Next" and "Skip".
2. Title "Place". Copy: "Drag the remaining cash onto the open door. Every door has to match first." Buttons: "Next" and "Skip".
3. Title "Ring". Copy: "After the cash matches, ring walk-ins and advance the card." Buttons: "Continue" and "Skip".

"Next" moves to the next page. "Skip" on any page, and "Continue" on the last page, both leave the intro the same way. The app then opens the floor already clocked in, with the starter doors, roster, and house card described below.

## Screens
The floor is the only root screen. Other screens are sheets. Each sheet has "Close" at the top left. On iPhone the board sits above the cash card; when the window is wide, the board sits beside it. Amounts are US dollars with two decimal places. A number keyboard shows "Done".

### Floor
After the intro the large title is "Open". Under it: "Cash is still open. Seat the remaining amount on the last door."

The board shows four doors and a draggable cash chip. The chip's accessibility name is "Remaining lot". Its label is the cash still to place, starting at "$140.00". Each door shows its name and a line such as "Health 99. Cash $0.00". Tapping a door selects it. Dragging the chip onto a door seats as much remaining cash as that door can take.

The cash card is titled "Cash". It shows the remaining amount, then "Opening $140.00. Walk-ins $0.00." The button "Seat cash" seats the remaining cash on the selected door, up to that door's cap. It is dimmed once nothing is left to seat, and again once every door holds its full cap. A successful seat shows "Cash seated. Left …" with the new remainder.

The selected door's card shows the door name and "Health … Cap …". Buttons:

- "Ring walk-in" posts an $8.00 walk-in on that door only after every door is seated. Success reads "Walk-in posted. Taken …" with the walk-in total. Too early, it reads "Ring refused. Seat every door first." If the doors are not clocked open, it reads "Doors are closed. Clock in first."
- "Comp member" opens the "Comp" sheet.

Other messages on this screen: "No cash left to seat.", "Over cap. Pick the open door.", "No doors yet. Place a door.", "Cash posted.", "Ring posted.", "Ring refused.", "Comp posted.", "Comp refused."

Four buttons open sheets: "Clock", "Bracket", "Finance", "Settings".

If there are no doors, this screen instead shows the title "Empty", the line "No doors yet. Place the first door.", and "Place door", which adds a door named "North door" with a $50.00 cap. That empty state is what remains after "Reset all data", before the intro is finished again. Finishing the intro replaces it with the four starter doors.

### Comp
Title "Comp". Heading "Comp". Copy: "Type the member number. A comp posts a walk-in with no cash added." Field placeholder "Member number" (digits). Buttons: "Comp admission" and "Close". Fewer or more than 8 to 14 digits leaves the sheet open and shows "Plate refused. Use 8 to 14 digits." on the floor. A valid number closes the sheet and posts a walk-in that adds $0.00.

### Clock
Title "Clock". After the intro the heading is "Open". Section "Roster" lists "Ada Quill" with "Treasurer", "Moss Keene" with "Door", and "Ivo Brant" with "House". The timeline shows "Open", "Day" plus an eight-digit date, and "Ada Quill". Field placeholder "Name". "Add name" adds that name with the role "Door" and clears the field. A blank name does nothing. "Clock in" is dimmed while a shift is already open, which it is after the intro. There is no clock-out.

If the roster and the timeline are both empty, the sheet shows "Roster", "Roster empty. Add a name, then clock in.", the name field, and "Add name". After a name exists but nobody is clocked in, it can also show "No clock yet. Clock in to open the cash." A closed shift reads "Closed". If the saved night cannot be read, the note "Saved floor was unreadable. Restored the previous copy." or "Saved floor was unreadable. Started empty." appears, with "Retry load".

### Bracket
Title "Bracket". Heading "House card". Before the card is seeded: "Round 1 is set. Seed pairings, then tap the name that wins." and "Names land here after you seed the pairs." The bottom button is "Seed pairings". It seats any open door first, then builds the pairs only when every door already holds its full opening cash. Success: "Pairings live. Tap the on-deck name." Otherwise: "Seat every door, then seed the card." or "Clock in first, then seed the card."

The eight names are "Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", and "Lark". Pairs are labeled "Round 1", "Round 2", and "Round 3". An empty later seat reads "Winner arrives from the pair above". An on-deck name is a button titled with the name plus ", on deck".

Once the card is live, the floor title becomes "Live" and the line becomes "Card live. Ring doors. Advance the on-deck pair." The bracket says "Round … Tap the on-deck name, or advance the pair." The bottom button becomes "Advance on deck". Tapping an on-deck name, or that button, posts the winner. Success: "Advance posted." A name that is not on deck: "Fault. That name is not on deck." When no pair remains: "The card is finished."

If the night file fails to read: "The night file failed to read. Retry, then reopen." and "Retry load".

If the card has no names, the sheet shows "House card", "Eight names make the card. Add them, then seed the pairs.", four rows "Pair 1" through "Pair 4", and "Close". The intro always supplies the eight names, so that empty card is not what a finished intro shows. There is no button to type extra card names.

### Finance
Title "Finance". Label "Still open" and the remaining cash. The line reads "0 of 4 doors counted. Post the count to close the gap and ring a walk-in." as doors are marked, with the counted count updating. Totals: "Opening", "Seated", "Walk-ins", and "Day" with the eight-digit date. Each door is a button showing its name, "Seated … Cap …", and "Count this door". Tapping it switches that line to "Counted". Tapping again returns it to "Count this door". "Post the count" seats remaining cash onto the first door that still has room, marks every door "Counted", and, once every door is seated, also rings one $8.00 walk-in. It then shows "Count posted. Seated … Walk-ins …".

If there are no doors, the sheet also shows "Nothing posted yet. Seat cash on a door." If the saved night cannot be read: "Saved night was unreadable. Showing the last good copy." or the same unread notes as Clock, plus "Retry load".

### Settings
Title "Settings". Heading "Desk". With doors present: "Opening cash", a field whose placeholder is "Cents", prefilled with the cent count (14000 for the starter night), and "Save cash". "Save cash" stores a whole cent amount greater than zero. It is dimmed once any cash is seated. Each door is listed with its name, "Health …", and "Log maint", which raises that door's health number by one.

Also: "Show intro again", which returns to the three intro pages and then comes back to the same night; "Reset all data"; and "Contact Avialobik", which opens the support page. "Reset all data" asks "Reset all data? Stations, lots, and the tape are removed from this device." with "Reset all data" and "Cancel". Confirming wipes the night and shows the intro again.

If there are no doors: "No doors yet. Place the first one." and "Place door", which adds "North door" at a $50.00 cap.

### Goals
Not on the floor buttons. A separate "Goals" sheet exists with title "Goals", the label "Still to place", the remaining cash, and "4 door still open. Seat the cash on that door." Each door shows its name, "… seated of …", a fill bar, and "Seat cash" or "Seated". The bottom button starts as "Seat cash on North door", then names the next open door, and becomes "Night target met" when nothing remains. Tapping a seated door shows "… already holds its share." Other lines: "Every door holds its opening share.", "Nothing left to place.", "Cash seated on …. Still to place …", "Clock in first, then seat the cash.", and "Cash refused. Pick the open door." With no doors: "No doors yet. Place the first door, then seat its cash." and "Place first door", which adds "North door" and then shows "North door is on the board. Seat its cash next."

## Features
- Intro pages "Cash", "Place", and "Ring", with "Next", "Continue", and "Skip".
- Four doors — "North door", "East door", "West door", and "Box office" — with caps of $50.00, $40.00, $30.00, and $20.00.
- Opening cash of $140.00, shown under "Cash", and a draggable "Remaining lot" chip.
- "Seat cash" on the selected door, or by dropping the chip on a door.
- Door lines "Health … Cash …" and "Health … Cap …".
- "Ring walk-in" at $8.00 once every door is seated, and "Comp member" / "Comp admission" for a member number that adds no cash.
- "Clock" roster and an open shift, "Add name", and "Clock in".
- "House card" with eight names, "Seed pairings", "Advance on deck", and on-deck name buttons.
- "Finance" door count, "Count this door" / "Counted", "Post the count", and totals "Opening", "Seated", "Walk-ins", and "Day".
- "Settings" with "Opening cash", "Save cash", "Log maint", "Show intro again", "Reset all data", and "Contact Avialobik".
- The night returns on the next launch until it is reset.

## Behaviours that can look like bugs
- "Seat cash" stays dimmed until the night is "Open" and cash remains. After the intro it is available. It dims again when the remainder is $0.00. Seat the doors in order, or drag the chip onto a door that still has room.
- "Ring walk-in" before every door is seated does not add money. The floor says "Ring refused. Seat every door first." Seat the full $140.00, then ring.
- "Comp admission" does nothing useful until the member number has 8 to 14 digits. The floor says "Plate refused. Use 8 to 14 digits."
- "Seed pairings" does not start the card until every door is seated. It says "Seat every door, then seed the card."
- Tapping a name that is not on deck says "Fault. That name is not on deck." Tap the button whose title ends in ", on deck", or "Advance on deck".
- "Clock in" is dimmed after the intro because the shift is already "Open". There is no control to close it.
- "Save cash" is dimmed as soon as any cash is seated. Change the cents before the first "Seat cash".
- "Add name" with an empty "Name" field does nothing. Type a name first.
- Once every door is seated, the floor title changes from "Open" to "Closed" even though ringing and the card still work. The line under it is "Every door is seated. Ring a walk-in, or seed the card." "Clock" still says "Open".
- "Post the count" marks every door "Counted" even if you only tapped some of them, seats leftover cash, and may ring one walk-in by itself.
- The Goals line says "4 door still open" rather than "doors".
- Starter health numbers are not all under 100. "West door" starts at 100 and "Box office" at 101. "Log maint" makes them higher. That number is a door score, not a medical reading.
- "Show intro again" plays the three pages and returns to the same night. It does not clear doors, cash, or the card. "Reset all data" does.
- Dropping the cash chip on a door that is already full shows "Over cap. Pick the open door."

## Starter content and resume
Finishing or skipping the intro plants four doors (caps $50.00, $40.00, $30.00, $20.00), opening cash $140.00, walk-ins at $0.00, and an $8.00 walk-in rate. The roster is "Ada Quill" ("Treasurer"), "Moss Keene" ("Door"), and "Ivo Brant" ("House"), with "Ada Quill" already clocked "Open". The house card is "House card" with "Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", and "Lark", and no pairs yet. No cash is seated yet.

The same night is still there on the next launch, including seated cash, walk-ins, the count, and how far the card has advanced. "Reset all data" removes it and shows the intro again.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with other people, an account-deletion flow, and an App Tracking Transparency prompt. Names, member numbers, and the night stay in the app. "Reset all data" clears that night. It is not an account deletion.

## Data and support
The night stays on this device. "Contact Avialobik" in "Settings" opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show medical, clinical, or product-health information, and it has no citations. The word "Health" on a door is a floor score beside the cash on that door.

## Platform
US dollar amounts follow the device's currency formatting. The day number uses the device calendar. iPhone supports portrait and both landscapes. iPad supports portrait, upside-down portrait, and both landscapes. The app is full screen on iPhone and iPad. Minimum iOS version is 17.0. The interface is dark. A Watch face shows "Doors" and "Seat the open cash on the door." It does not edit the night.

## Category
Business.# Poolfold
## What it is
Poolfold is a dark, full-screen house desk for one night on the floor. It splits an opening cash amount across named doors, rings walk-ins once every door is seated, and runs an eight-name house card. It is for the person working that night: seating cash, counting doors, and advancing the on-deck pair.

## Launch and onboarding
Cold launch opens straight into a three-page intro. There is no tab bar and no sign-in. The interface is always dark. Each page has a picture, a title, a line of copy, and two buttons.

1. Title "Cash". Copy: "Split tonight's opening cash across the doors before anyone rings in." Buttons: "Next" and "Skip".
2. Title "Place". Copy: "Drag the remaining cash onto the open door. Every door has to match first." Buttons: "Next" and "Skip".
3. Title "Ring". Copy: "After the cash matches, ring walk-ins and advance the card." Buttons: "Continue" and "Skip".

"Next" moves to the next page. "Skip" on any page, and "Continue" on the last page, both leave the intro the same way. The app then opens the floor already clocked in, with the starter doors, roster, and house card described below.

## Screens
The floor is the only root screen. Other screens are sheets. Each sheet has "Close" at the top left. On iPhone the board sits above the cash card; when the window is wide, the board sits beside it. Amounts are US dollars with two decimal places. A number keyboard shows "Done".

### Floor
After the intro the large title is "Open". Under it: "Cash is still open. Seat the remaining amount on the last door."

The board shows four doors and a draggable cash chip. The chip's accessibility name is "Remaining lot". Its label is the cash still to place, starting at "$140.00". Each door shows its name and a line such as "Health 99. Cash $0.00". Tapping a door selects it. Dragging the chip onto a door seats as much remaining cash as that door can take.

The cash card is titled "Cash". It shows the remaining amount, then "Opening $140.00. Walk-ins $0.00." The button "Seat cash" seats the remaining cash on the selected door, up to that door's cap. It is dimmed once nothing is left to seat, and again once every door holds its full cap. A successful seat shows "Cash seated. Left …" with the new remainder.

The selected door's card shows the door name and "Health … Cap …". Buttons:

- "Ring walk-in" posts an $8.00 walk-in on that door only after every door is seated. Success reads "Walk-in posted. Taken …" with the walk-in total. Too early, it reads "Ring refused. Seat every door first." If the doors are not clocked open, it reads "Doors are closed. Clock in first."
- "Comp member" opens the "Comp" sheet.

Other messages on this screen: "No cash left to seat.", "Over cap. Pick the open door.", "No doors yet. Place a door.", "Cash posted.", "Ring posted.", "Ring refused.", "Comp posted.", "Comp refused."

Four buttons open sheets: "Clock", "Bracket", "Finance", "Settings".

If there are no doors, this screen instead shows the title "Empty", the line "No doors yet. Place the first door.", and "Place door", which adds a door named "North door" with a $50.00 cap. That empty state is what remains after "Reset all data", before the intro is finished again. Finishing the intro replaces it with the four starter doors.

### Comp
Title "Comp". Heading "Comp". Copy: "Type the member number. A comp posts a walk-in with no cash added." Field placeholder "Member number" (digits). Buttons: "Comp admission" and "Close". Fewer or more than 8 to 14 digits leaves the sheet open and shows "Plate refused. Use 8 to 14 digits." on the floor. A valid number closes the sheet and posts a walk-in that adds $0.00.

### Clock
Title "Clock". After the intro the heading is "Open". Section "Roster" lists "Ada Quill" with "Treasurer", "Moss Keene" with "Door", and "Ivo Brant" with "House". The timeline shows "Open", "Day" plus an eight-digit date, and "Ada Quill". Field placeholder "Name". "Add name" adds that name with the role "Door" and clears the field. A blank name does nothing. "Clock in" is dimmed while a shift is already open, which it is after the intro. There is no clock-out.

If the roster and the timeline are both empty, the sheet shows "Roster", "Roster empty. Add a name, then clock in.", the name field, and "Add name". After a name exists but nobody is clocked in, it can also show "No clock yet. Clock in to open the cash." A closed shift reads "Closed". If the saved night cannot be read, the note "Saved floor was unreadable. Restored the previous copy." or "Saved floor was unreadable. Started empty." appears, with "Retry load".

### Bracket
Title "Bracket". Heading "House card". Before the card is seeded: "Round 1 is set. Seed pairings, then tap the name that wins." and "Names land here after you seed the pairs." The bottom button is "Seed pairings". It seats any open door first, then builds the pairs only when every door already holds its full opening cash. Success: "Pairings live. Tap the on-deck name." Otherwise: "Seat every door, then seed the card." or "Clock in first, then seed the card."

The eight names are "Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", and "Lark". Pairs are labeled "Round 1", "Round 2", and "Round 3". An empty later seat reads "Winner arrives from the pair above". An on-deck name is a button titled with the name plus ", on deck".

Once the card is live, the floor title becomes "Live" and the line becomes "Card live. Ring doors. Advance the on-deck pair." The bracket says "Round … Tap the on-deck name, or advance the pair." The bottom button becomes "Advance on deck". Tapping an on-deck name, or that button, posts the winner. Success: "Advance posted." A name that is not on deck: "Fault. That name is not on deck." When no pair remains: "The card is finished."

If the night file fails to read: "The night file failed to read. Retry, then reopen." and "Retry load".

If the card has no names, the sheet shows "House card", "Eight names make the card. Add them, then seed the pairs.", four rows "Pair 1" through "Pair 4", and "Close". The intro always supplies the eight names, so that empty card is not what a finished intro shows. There is no button to type extra card names.

### Finance
Title "Finance". Label "Still open" and the remaining cash. The line reads "0 of 4 doors counted. Post the count to close the gap and ring a walk-in." as doors are marked, with the counted count updating. Totals: "Opening", "Seated", "Walk-ins", and "Day" with the eight-digit date. Each door is a button showing its name, "Seated … Cap …", and "Count this door". Tapping it switches that line to "Counted". Tapping again returns it to "Count this door". "Post the count" seats remaining cash onto the first door that still has room, marks every door "Counted", and, once every door is seated, also rings one $8.00 walk-in. It then shows "Count posted. Seated … Walk-ins …".

If there are no doors, the sheet also shows "Nothing posted yet. Seat cash on a door." If the saved night cannot be read: "Saved night was unreadable. Showing the last good copy." or the same unread notes as Clock, plus "Retry load".

### Settings
Title "Settings". Heading "Desk". With doors present: "Opening cash", a field whose placeholder is "Cents", prefilled with the cent count (14000 for the starter night), and "Save cash". "Save cash" stores a whole cent amount greater than zero. It is dimmed once any cash is seated. Each door is listed with its name, "Health …", and "Log maint", which raises that door's health number by one.

Also: "Show intro again", which returns to the three intro pages and then comes back to the same night; "Reset all data"; and "Contact Avialobik", which opens the support page. "Reset all data" asks "Reset all data? Stations, lots, and the tape are removed from this device." with "Reset all data" and "Cancel". Confirming wipes the night and shows the intro again.

If there are no doors: "No doors yet. Place the first one." and "Place door", which adds "North door" at a $50.00 cap.

### Goals
Not on the floor buttons. A separate "Goals" sheet exists with title "Goals", the label "Still to place", the remaining cash, and "4 door still open. Seat the cash on that door." Each door shows its name, "… seated of …", a fill bar, and "Seat cash" or "Seated". The bottom button starts as "Seat cash on North door", then names the next open door, and becomes "Night target met" when nothing remains. Tapping a seated door shows "… already holds its share." Other lines: "Every door holds its opening share.", "Nothing left to place.", "Cash seated on …. Still to place …", "Clock in first, then seat the cash.", and "Cash refused. Pick the open door." With no doors: "No doors yet. Place the first door, then seat its cash." and "Place first door", which adds "North door" and then shows "North door is on the board. Seat its cash next."

## Features
- Intro pages "Cash", "Place", and "Ring", with "Next", "Continue", and "Skip".
- Four doors — "North door", "East door", "West door", and "Box office" — with caps of $50.00, $40.00, $30.00, and $20.00.
- Opening cash of $140.00, shown under "Cash", and a draggable "Remaining lot" chip.
- "Seat cash" on the selected door, or by dropping the chip on a door.
- Door lines "Health … Cash …" and "Health … Cap …".
- "Ring walk-in" at $8.00 once every door is seated, and "Comp member" / "Comp admission" for a member number that adds no cash.
- "Clock" roster and an open shift, "Add name", and "Clock in".
- "House card" with eight names, "Seed pairings", "Advance on deck", and on-deck name buttons.
- "Finance" door count, "Count this door" / "Counted", "Post the count", and totals "Opening", "Seated", "Walk-ins", and "Day".
- "Settings" with "Opening cash", "Save cash", "Log maint", "Show intro again", "Reset all data", and "Contact Avialobik".
- The night returns on the next launch until it is reset.

## Behaviours that can look like bugs
- "Seat cash" stays dimmed until the night is "Open" and cash remains. After the intro it is available. It dims again when the remainder is $0.00. Seat the doors in order, or drag the chip onto a door that still has room.
- "Ring walk-in" before every door is seated does not add money. The floor says "Ring refused. Seat every door first." Seat the full $140.00, then ring.
- "Comp admission" does nothing useful until the member number has 8 to 14 digits. The floor says "Plate refused. Use 8 to 14 digits."
- "Seed pairings" does not start the card until every door is seated. It says "Seat every door, then seed the card."
- Tapping a name that is not on deck says "Fault. That name is not on deck." Tap the button whose title ends in ", on deck", or "Advance on deck".
- "Clock in" is dimmed after the intro because the shift is already "Open". There is no control to close it.
- "Save cash" is dimmed as soon as any cash is seated. Change the cents before the first "Seat cash".
- "Add name" with an empty "Name" field does nothing. Type a name first.
- Once every door is seated, the floor title changes from "Open" to "Closed" even though ringing and the card still work. The line under it is "Every door is seated. Ring a walk-in, or seed the card." "Clock" still says "Open".
- "Post the count" marks every door "Counted" even if you only tapped some of them, seats leftover cash, and may ring one walk-in by itself.
- The Goals line says "4 door still open" rather than "doors".
- Starter health numbers are not all under 100. "West door" starts at 100 and "Box office" at 101. "Log maint" makes them higher. That number is a door score, not a medical reading.
- "Show intro again" plays the three pages and returns to the same night. It does not clear doors, cash, or the card. "Reset all data" does.
- Dropping the cash chip on a door that is already full shows "Over cap. Pick the open door."

## Starter content and resume
Finishing or skipping the intro plants four doors (caps $50.00, $40.00, $30.00, $20.00), opening cash $140.00, walk-ins at $0.00, and an $8.00 walk-in rate. The roster is "Ada Quill" ("Treasurer"), "Moss Keene" ("Door"), and "Ivo Brant" ("House"), with "Ada Quill" already clocked "Open". The house card is "House card" with "Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", and "Lark", and no pairs yet. No cash is seated yet.

The same night is still there on the next launch, including seated cash, walk-ins, the count, and how far the card has advanced. "Reset all data" removes it and shows the intro again.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with other people, an account-deletion flow, and an App Tracking Transparency prompt. Names, member numbers, and the night stay in the app. "Reset all data" clears that night. It is not an account deletion.

## Data and support
The night stays on this device. "Contact Avialobik" in "Settings" opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show medical, clinical, or product-health information, and it has no citations. The word "Health" on a door is a floor score beside the cash on that door.

## Platform
US dollar amounts follow the device's currency formatting. The day number uses the device calendar. iPhone supports portrait and both landscapes. iPad supports portrait, upside-down portrait, and both landscapes. The app is full screen on iPhone and iPad. Minimum iOS version is 17.0. The interface is dark. A Watch face shows "Doors" and "Seat the open cash on the door." It does not edit the night.

## Category
Business.# Poolfold
## What it is
Poolfold is a dark, full-screen house desk for one night on the floor. It splits an opening cash amount across named doors, rings walk-ins once every door is seated, and runs an eight-name house card. It is for the person working that night: seating cash, counting doors, and advancing the on-deck pair.

## Launch and onboarding
Cold launch opens straight into a three-page intro. There is no tab bar and no sign-in. The interface is always dark. Each page has a picture, a title, a line of copy, and two buttons.

1. Title "Cash". Copy: "Split tonight's opening cash across the doors before anyone rings in." Buttons: "Next" and "Skip".
2. Title "Place". Copy: "Drag the remaining cash onto the open door. Every door has to match first." Buttons: "Next" and "Skip".
3. Title "Ring". Copy: "After the cash matches, ring walk-ins and advance the card." Buttons: "Continue" and "Skip".

"Next" moves to the next page. "Skip" on any page, and "Continue" on the last page, both leave the intro the same way. The app then opens the floor already clocked in, with the starter doors, roster, and house card described below.

## Screens
The floor is the only root screen. Other screens are sheets. Each sheet has "Close" at the top left. On iPhone the board sits above the cash card; when the window is wide, the board sits beside it. Amounts are US dollars with two decimal places. A number keyboard shows "Done".

### Floor
After the intro the large title is "Open". Under it: "Cash is still open. Seat the remaining amount on the last door."

The board shows four doors and a draggable cash chip. The chip's accessibility name is "Remaining lot". Its label is the cash still to place, starting at "$140.00". Each door shows its name and a line such as "Health 99. Cash $0.00". Tapping a door selects it. Dragging the chip onto a door seats as much remaining cash as that door can take.

The cash card is titled "Cash". It shows the remaining amount, then "Opening $140.00. Walk-ins $0.00." The button "Seat cash" seats the remaining cash on the selected door, up to that door's cap. It is dimmed once nothing is left to seat, and again once every door holds its full cap. A successful seat shows "Cash seated. Left …" with the new remainder.

The selected door's card shows the door name and "Health … Cap …". Buttons:

- "Ring walk-in" posts an $8.00 walk-in on that door only after every door is seated. Success reads "Walk-in posted. Taken …" with the walk-in total. Too early, it reads "Ring refused. Seat every door first." If the doors are not clocked open, it reads "Doors are closed. Clock in first."
- "Comp member" opens the "Comp" sheet.

Other messages on this screen: "No cash left to seat.", "Over cap. Pick the open door.", "No doors yet. Place a door.", "Cash posted.", "Ring posted.", "Ring refused.", "Comp posted.", "Comp refused."

Four buttons open sheets: "Clock", "Bracket", "Finance", "Settings".

If there are no doors, this screen instead shows the title "Empty", the line "No doors yet. Place the first door.", and "Place door", which adds a door named "North door" with a $50.00 cap. That empty state is what remains after "Reset all data", before the intro is finished again. Finishing the intro replaces it with the four starter doors.

### Comp
Title "Comp". Heading "Comp". Copy: "Type the member number. A comp posts a walk-in with no cash added." Field placeholder "Member number" (digits). Buttons: "Comp admission" and "Close". Fewer or more than 8 to 14 digits leaves the sheet open and shows "Plate refused. Use 8 to 14 digits." on the floor. A valid number closes the sheet and posts a walk-in that adds $0.00.

### Clock
Title "Clock". After the intro the heading is "Open". Section "Roster" lists "Ada Quill" with "Treasurer", "Moss Keene" with "Door", and "Ivo Brant" with "House". The timeline shows "Open", "Day" plus an eight-digit date, and "Ada Quill". Field placeholder "Name". "Add name" adds that name with the role "Door" and clears the field. A blank name does nothing. "Clock in" is dimmed while a shift is already open, which it is after the intro. There is no clock-out.

If the roster and the timeline are both empty, the sheet shows "Roster", "Roster empty. Add a name, then clock in.", the name field, and "Add name". After a name exists but nobody is clocked in, it can also show "No clock yet. Clock in to open the cash." A closed shift reads "Closed". If the saved night cannot be read, the note "Saved floor was unreadable. Restored the previous copy." or "Saved floor was unreadable. Started empty." appears, with "Retry load".

### Bracket
Title "Bracket". Heading "House card". Before the card is seeded: "Round 1 is set. Seed pairings, then tap the name that wins." and "Names land here after you seed the pairs." The bottom button is "Seed pairings". It seats any open door first, then builds the pairs only when every door already holds its full opening cash. Success: "Pairings live. Tap the on-deck name." Otherwise: "Seat every door, then seed the card." or "Clock in first, then seed the card."

The eight names are "Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", and "Lark". Pairs are labeled "Round 1", "Round 2", and "Round 3". An empty later seat reads "Winner arrives from the pair above". An on-deck name is a button titled with the name plus ", on deck".

Once the card is live, the floor title becomes "Live" and the line becomes "Card live. Ring doors. Advance the on-deck pair." The bracket says "Round … Tap the on-deck name, or advance the pair." The bottom button becomes "Advance on deck". Tapping an on-deck name, or that button, posts the winner. Success: "Advance posted." A name that is not on deck: "Fault. That name is not on deck." When no pair remains: "The card is finished."

If the night file fails to read: "The night file failed to read. Retry, then reopen." and "Retry load".

If the card has no names, the sheet shows "House card", "Eight names make the card. Add them, then seed the pairs.", four rows "Pair 1" through "Pair 4", and "Close". The intro always supplies the eight names, so that empty card is not what a finished intro shows. There is no button to type extra card names.

### Finance
Title "Finance". Label "Still open" and the remaining cash. The line reads "0 of 4 doors counted. Post the count to close the gap and ring a walk-in." as doors are marked, with the counted count updating. Totals: "Opening", "Seated", "Walk-ins", and "Day" with the eight-digit date. Each door is a button showing its name, "Seated … Cap …", and "Count this door". Tapping it switches that line to "Counted". Tapping again returns it to "Count this door". "Post the count" seats remaining cash onto the first door that still has room, marks every door "Counted", and, once every door is seated, also rings one $8.00 walk-in. It then shows "Count posted. Seated … Walk-ins …".

If there are no doors, the sheet also shows "Nothing posted yet. Seat cash on a door." If the saved night cannot be read: "Saved night was unreadable. Showing the last good copy." or the same unread notes as Clock, plus "Retry load".

### Settings
Title "Settings". Heading "Desk". With doors present: "Opening cash", a field whose placeholder is "Cents", prefilled with the cent count (14000 for the starter night), and "Save cash". "Save cash" stores a whole cent amount greater than zero. It is dimmed once any cash is seated. Each door is listed with its name, "Health …", and "Log maint", which raises that door's health number by one.

Also: "Show intro again", which returns to the three intro pages and then comes back to the same night; "Reset all data"; and "Contact Avialobik", which opens the support page. "Reset all data" asks "Reset all data? Stations, lots, and the tape are removed from this device." with "Reset all data" and "Cancel". Confirming wipes the night and shows the intro again.

If there are no doors: "No doors yet. Place the first one." and "Place door", which adds "North door" at a $50.00 cap.

### Goals
Not on the floor buttons. A separate "Goals" sheet exists with title "Goals", the label "Still to place", the remaining cash, and "4 door still open. Seat the cash on that door." Each door shows its name, "… seated of …", a fill bar, and "Seat cash" or "Seated". The bottom button starts as "Seat cash on North door", then names the next open door, and becomes "Night target met" when nothing remains. Tapping a seated door shows "… already holds its share." Other lines: "Every door holds its opening share.", "Nothing left to place.", "Cash seated on …. Still to place …", "Clock in first, then seat the cash.", and "Cash refused. Pick the open door." With no doors: "No doors yet. Place the first door, then seat its cash." and "Place first door", which adds "North door" and then shows "North door is on the board. Seat its cash next."

## Features
- Intro pages "Cash", "Place", and "Ring", with "Next", "Continue", and "Skip".
- Four doors — "North door", "East door", "West door", and "Box office" — with caps of $50.00, $40.00, $30.00, and $20.00.
- Opening cash of $140.00, shown under "Cash", and a draggable "Remaining lot" chip.
- "Seat cash" on the selected door, or by dropping the chip on a door.
- Door lines "Health … Cash …" and "Health … Cap …".
- "Ring walk-in" at $8.00 once every door is seated, and "Comp member" / "Comp admission" for a member number that adds no cash.
- "Clock" roster and an open shift, "Add name", and "Clock in".
- "House card" with eight names, "Seed pairings", "Advance on deck", and on-deck name buttons.
- "Finance" door count, "Count this door" / "Counted", "Post the count", and totals "Opening", "Seated", "Walk-ins", and "Day".
- "Settings" with "Opening cash", "Save cash", "Log maint", "Show intro again", "Reset all data", and "Contact Avialobik".
- The night returns on the next launch until it is reset.

## Behaviours that can look like bugs
- "Seat cash" stays dimmed until the night is "Open" and cash remains. After the intro it is available. It dims again when the remainder is $0.00. Seat the doors in order, or drag the chip onto a door that still has room.
- "Ring walk-in" before every door is seated does not add money. The floor says "Ring refused. Seat every door first." Seat the full $140.00, then ring.
- "Comp admission" does nothing useful until the member number has 8 to 14 digits. The floor says "Plate refused. Use 8 to 14 digits."
- "Seed pairings" does not start the card until every door is seated. It says "Seat every door, then seed the card."
- Tapping a name that is not on deck says "Fault. That name is not on deck." Tap the button whose title ends in ", on deck", or "Advance on deck".
- "Clock in" is dimmed after the intro because the shift is already "Open". There is no control to close it.
- "Save cash" is dimmed as soon as any cash is seated. Change the cents before the first "Seat cash".
- "Add name" with an empty "Name" field does nothing. Type a name first.
- Once every door is seated, the floor title changes from "Open" to "Closed" even though ringing and the card still work. The line under it is "Every door is seated. Ring a walk-in, or seed the card." "Clock" still says "Open".
- "Post the count" marks every door "Counted" even if you only tapped some of them, seats leftover cash, and may ring one walk-in by itself.
- The Goals line says "4 door still open" rather than "doors".
- Starter health numbers are not all under 100. "West door" starts at 100 and "Box office" at 101. "Log maint" makes them higher. That number is a door score, not a medical reading.
- "Show intro again" plays the three pages and returns to the same night. It does not clear doors, cash, or the card. "Reset all data" does.
- Dropping the cash chip on a door that is already full shows "Over cap. Pick the open door."

## Starter content and resume
Finishing or skipping the intro plants four doors (caps $50.00, $40.00, $30.00, $20.00), opening cash $140.00, walk-ins at $0.00, and an $8.00 walk-in rate. The roster is "Ada Quill" ("Treasurer"), "Moss Keene" ("Door"), and "Ivo Brant" ("House"), with "Ada Quill" already clocked "Open". The house card is "House card" with "Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", and "Lark", and no pairs yet. No cash is seated yet.

The same night is still there on the next launch, including seated cash, walk-ins, the count, and how far the card has advanced. "Reset all data" removes it and shows the intro again.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with other people, an account-deletion flow, and an App Tracking Transparency prompt. Names, member numbers, and the night stay in the app. "Reset all data" clears that night. It is not an account deletion.

## Data and support
The night stays on this device. "Contact Avialobik" in "Settings" opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show medical, clinical, or product-health information, and it has no citations. The word "Health" on a door is a floor score beside the cash on that door.

## Platform
US dollar amounts follow the device's currency formatting. The day number uses the device calendar. iPhone supports portrait and both landscapes. iPad supports portrait, upside-down portrait, and both landscapes. The app is full screen on iPhone and iPad. Minimum iOS version is 17.0. The interface is dark. A Watch face shows "Doors" and "Seat the open cash on the door." It does not edit the night.

## Category
Business.
