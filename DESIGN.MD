# Coorporate Gig

## UI / UX Design System

This document is the authoritative UI specification for the
Coorporate Gig Flutter application.

The application is a mobile-first cooperative service marketplace
connecting clients with verified workers through cooperative
organizations and federations.

The UI should communicate:

- trust
- professionalism
- accessibility
- local community
- reliability
- transparency
- modern technology

The application must NOT look like a generic food-delivery,
ride-hailing, or e-commerce application.

---

# 1. PLATFORM

Target platform:

- Mobile-first
- Android primarily
- iOS-compatible architecture where practical

Design reference viewport:

- 390 x 844 logical pixels

All screens must adapt to different phone sizes.

Avoid fixed desktop-width layouts.

---

# 2. BRAND

Application name:

Coorporate Gig

Use "Coorporate Gig" consistently throughout the application.

Do not rename the application to Bharat Seva.

---

# 3. VISUAL STYLE

Overall visual direction:

- clean
- premium
- trustworthy
- modern
- spacious
- professional
- community-oriented

Primary visual foundation:

- white/light surfaces
- deep indigo/navy as the main brand accent
- subtle gray backgrounds
- soft borders
- rounded cards
- restrained shadows
- clear typography hierarchy

Avoid excessive gradients.

Avoid excessive bright colors.

Avoid giant colored headers.

Avoid overly playful UI.

The interface should feel like a high-trust professional
services platform.

---

# 4. COLOR PALETTE

The following colors are the OFFICIAL Coorporate Gig color palette.

Do not invent alternative primary colors.

## Brand Colors

Primary:
#4338CA
Deep Indigo

Primary Dark:
#3730A3
Indigo

Primary Light:
#EEF2FF
Soft Indigo

Secondary Cooperative Accent:
#0F766E
Teal

## Neutral Colors

Background:
#F8FAFC

Surface:
#FFFFFF

Primary Text:
#0F172A

Secondary Text:
#475569

Muted Text:
#94A3B8

Border:
#E2E8F0

## Semantic Colors

Success:
#16A34A

Success Background:
#DCFCE7

Warning:
#D97706

Warning Background:
#FEF3C7

Error:
#DC2626

Error Background:
#FEE2E2

## COLOR USAGE RULES

Primary Indigo (#4338CA) is the main application brand color.

Use Primary Indigo for:

- primary CTA buttons
- active navigation
- selected chips
- important interactive elements
- links
- active states

Use Primary Light (#EEF2FF) for:

- subtle highlighted containers
- selected card backgrounds
- information panels
- AI recommendation cards

Use Teal (#0F766E) sparingly to represent:

- cooperative identity
- federation identity
- cooperative-specific information

Use Green (#16A34A) ONLY for semantic success states:

- available workers
- verified states
- successful payments
- completed services

Use Amber ONLY for warnings.

Use Red ONLY for errors, cancellation, destructive actions,
or failed states.

The application background should primarily be #F8FAFC or white.

Do not use large saturated color blocks as page backgrounds.

Do not use green as the main application theme.

Do not introduce random purple, blue, cyan, orange, or green shades.

All colors must be defined centrally in Flutter ThemeData
or a dedicated AppColors class rather than hard-coded throughout
individual widgets.

---

# 5. TYPOGRAPHY

Use a modern sans-serif font.

Hierarchy:

Large page heading:

- bold
- approximately 24–28px

Section heading:

- semibold
- approximately 18–20px

Card title:

- semibold
- approximately 16–18px

Body:

- approximately 14–16px

Secondary information:

- approximately 12–14px

Labels:

- approximately 11–13px

Maintain clear hierarchy.

Do not use excessive font weights.

---

# 6. SPACING

Use a consistent spacing system.

Preferred values:

4
8
12
16
20
24
32

Most screen content should use approximately 16px
horizontal padding.

Cards should generally have:

- 12–20px internal padding
- 12–20px corner radius

Avoid cramped layouts.

Allow whitespace between major sections.

---

# 7. CARDS

Cards are a major UI component.

Default card:

- white surface
- rounded corners
- subtle border
- extremely subtle shadow
- 12–20px radius
- 12–20px padding

Do not create heavy floating shadows.

Cards should feel lightweight and organized.

---

# 8. BUTTONS

Primary button:

- deep indigo/navy background
- white text
- rounded corners
- medium/large height
- semibold text

Secondary button:

- light background
- indigo text
- subtle border

Danger button:

- restrained red treatment

Buttons should have obvious touch targets.

Avoid tiny buttons.

---

# 9. SEARCH

Search fields should be:

- rounded
- light gray background
- search icon on the left
- readable placeholder
- generous horizontal padding

Example:

"Search workers, skills or services"

Search should feel prominent but not dominate the screen.

---

# 10. CHIPS

Service/category chips should be rounded.

Selected chip:

- indigo background
- white text

Unselected:

- light gray background
- dark/gray text

Examples:

Electrician
Plumber
Carpenter
Painter
AC Technician

---

# 11. MAP UI

Client discovery uses a prominent map section.

The map should:

- have rounded corners
- occupy meaningful screen space
- display worker markers
- show worker availability
- support a selected worker state

For the prototype:

A realistic static/mock map is acceptable.

Do NOT block the UI implementation waiting for a
production maps API.

Architecture should allow a real map provider to be added later.

A selected worker may appear in a floating card over the map.

Example:

Rajesh Kumar
Electrician
★ 4.8
8 yrs experience
Verified

[View Profile]

---

# 12. WORKER CARDS

Worker cards should communicate trust quickly.

Typical information:

Worker photograph
Name
Profession
Rating
Experience
Jobs completed
Distance
Cooperative affiliation
Verification status

Example:

Rajesh Kumar
Master Electrician
★ 4.8

8 yrs exp • 240 jobs • 1.2 km

Goa Electrical Workers Cooperative

Possible badges:

BEST MATCH
VERIFIED
AVAILABLE

Do not overload cards with unnecessary information.

---

# 13. VERIFICATION

Verification is important to the product.

Use subtle badges for:

- Aadhaar Verified
- Skill Verified
- Cooperative Verified

Verification should visually increase trust without looking
like a gaming badge system.

---

# 14. CLIENT EXPERIENCE

The primary client journey is:

Home
↓
Search / Worker Discovery
↓
Search Results
↓
Worker Profile
↓
Request Service
↓
Photo Attachment
↓
Matching Engine
↓
Booking
↓
OTP Verification
↓
Active Service
↓
Payment
↓
Feedback / Rating

Secondary client destinations:

My Requests
My Bookings
Service History
Previously Hired Workers
Notifications
Profile

---

# 15. CLIENT HOME

The client home screen should contain:

HEADER

Left:

- profile/avatar
- location
- location dropdown

Example:

Panaji, Goa

Right:

- notification icon

GREETING

Example:

Good evening, Rahul

Subtitle:

Find trusted professionals near you.

SEARCH

Search workers, skills or services

SERVICE CHIPS

Electrician
Plumber
Carpenter

MAP

Prominent rounded map card.

Show worker markers.

Show selected worker preview when appropriate.

AVAILABLE NEAR YOU

Section title:

Available near you

Optional:

See All

WORKER CARDS

Show nearby available workers.

BOTTOM NAVIGATION

Home
Requests
Profile

Home is active.

---

# 16. CLIENT SEARCH

Search screen should support searching for:

- professions
- skills
- services
- workers

Examples:

Electrician
Plumber
Carpenter
AC repair
Fan installation

Results should use worker cards.

Filters may include:

Distance
Rating
Availability
Experience
Skill
Cooperative

---

# 17. WORKER PROFILE

Worker profile should prioritize trust.

Include:

Profile photo
Name
Profession
Rating
Experience
Completed jobs
Verification
Skills
Cooperative
About
Reviews
Availability

Primary CTA:

Request Service

Secondary action:

Contact / View availability where appropriate.

---

# 18. REQUEST SERVICE

Request screen should allow:

Service type
Brief description
Preferred date
Preferred time
Location
Additional notes
Photo attachments

Example description:

"Kitchen socket is not working."

Photos can provide visual context for the worker.

Primary CTA:

Request Service

---

# 19. MATCHING ENGINE

The matching screen represents the cooperative matching process.

It should visually communicate:

Request received
↓
Worker skills evaluated
↓
Distance considered
↓
Availability checked
↓
Best cooperative worker selected

The experience should feel intelligent and trustworthy.

Do not overuse flashy AI animations.

---

# 20. OTP

OTP verification is used to confirm:

- service start
- service completion where appropriate

UI:

Large OTP input.

Clear explanation.

Example:

"Enter the OTP shared by your customer."

or:

"Enter the OTP provided by your worker."

Use a clear verification state.

---

# 21. ACTIVE SERVICE

Show:

Worker information
Service
Location
Status
Start time
Estimated completion
Contact/action options

Clearly display:

SERVICE IN PROGRESS

Primary actions should be obvious.

---

# 22. PAYMENT

Payment screen should clearly show:

Service charge
Visit charge
Platform/cooperative fee where applicable
Total

Use a transparent breakdown.

Support prototype payment methods such as:

UPI
Card
Cash

Cash must be represented as a legitimate payment option because
the platform must accommodate users who prefer cash.

For the prototype, payment can be simulated.

---

# 23. FEEDBACK

After service completion:

Rating
Review
Optional feedback tags

Example tags:

Professional
On time
Good quality
Friendly
Affordable

Primary CTA:

Submit Review

---

# 24. PREVIOUSLY HIRED WORKERS

Client can see workers hired previously.

Each worker entry should include:

Photo
Name
Profession
Last service
Rating
Cooperative

Primary action:

Book Again

This should make repeat service fast.

---

# 25. CLIENT NOTIFICATIONS

Notifications should cover:

Booking confirmed
Worker matched
Worker arriving
OTP required
Service started
Service completed
Payment received
Review reminder

Use grouped/read/unread states.

---

# 26. WORKER EXPERIENCE

Worker flow:

Worker Dashboard
↓
Job Requests
↓
Job Details
↓
Accept / Decline
↓
OTP
↓
Active Job
↓
Complete Service
↓
Payment / Earnings

Worker dashboard should prominently display:

Available / Offline status
Today's jobs
Upcoming jobs
Earnings
Pending requests
Recent activity

---

# 27. WORKER JOB CARDS

Job cards should show:

Client
Service
Location
Date/time
Estimated earnings
Distance
Status

Statuses:

NEW
ACCEPTED
UPCOMING
ACTIVE
COMPLETED
CANCELLED

---

# 28. WORKER PROFILE

Worker profile should include:

Profile photo
Name
Profession
Skills
Experience
Verification
Cooperative
Reviews
Rating
Jobs completed
Transactions
Earnings
Job history

Worker should be able to communicate professional credibility
clearly.

---

# 29. COOPERATIVE ADMIN

Admin is MOBILE-FIRST.

The admin dashboard must NOT look like a desktop enterprise
dashboard squeezed onto a phone.

Use:

- cards
- sections
- horizontal scrolling where useful
- compact charts
- clear KPI blocks
- bottom navigation or structured navigation

Core admin areas:

Dashboard
Workers
Jobs
Allocation
Forecasting
Federation

---

# 30. COOPERATIVE DASHBOARD

Important KPIs:

Active Workers
Active Jobs
Pending Requests
Completed Jobs
Average Rating
Today's Demand

Use compact KPI cards.

---

# 31. WORKER MANAGEMENT

Admin can view:

Worker list
Availability
Skills
Verification
Performance
Jobs completed
Ratings
Earnings

Actions:

View
Assign
Deactivate / Activate
Update details

---

# 32. WORKFORCE ALLOCATION

Show:

Current demand
Available workers
Skill requirements
Skill shortages
Worker availability

Provide a recommendation such as:

"3 additional electricians recommended in Panaji."

Recommendations should be visually prominent.

---

# 33. AI DEMAND FORECASTING

This is one of the key differentiating features.

The dashboard should communicate:

Historical demand
↓
AI demand forecast
↓
Demand hotspots
↓
Skill requirements
↓
Workforce recommendation

Example:

Electrician demand

Today:
32 jobs

Forecast tomorrow:
41 jobs

Expected increase:
+28%

Recommended workers:
+4 electricians

Use simple clean charts.

The prototype may use realistic mock forecasting data.

Do not claim a real ML model exists if it is only simulated.

The architecture should allow a real forecasting service to be
connected later.

---

# 34. FEDERATION ADMINISTRATION

The cooperative federation view should show:

Cooperatives
Workers
Service coverage
Demand by region
Worker distribution
Performance

Example:

Goa Federation

Cooperatives:
12

Workers:
428

Active services:
86

Today's demand:
134

Use geographic/region cards where appropriate.

---

# 35. NAVIGATION

Navigation must feel natural on mobile.

Client:

Home
Requests
Profile

Worker:

Dashboard
Jobs
Profile

Admin:

Dashboard
Workers
Operations
Profile

Additional screens should be reached from these primary sections.

---

# 36. ICONS

Use a consistent icon library.

Prefer Material Icons or another standard Flutter icon system.

Do not mix random icon styles.

Icons should be simple and recognizable.

---

# 37. IMAGES

Worker/profile imagery should feel realistic and professional.

If actual image assets are unavailable:

Use local placeholders or generated mock assets.

Do not rely on remote image URLs for core functionality.

---

# 38. STATES

Every important screen should account for:

Loading
Empty
Error
Success

Examples:

No workers nearby
No pending jobs
No bookings
Payment successful
Service completed

Avoid blank screens.

---

# 39. RESPONSIVENESS

Design for phones first.

Never create:

- fixed desktop dashboards
- tiny text
- horizontal overflow
- clipped buttons
- inaccessible touch targets

Use SafeArea where appropriate.

Support scrolling where content exceeds the viewport.

---

# 40. ACCESSIBILITY

Maintain:

- readable contrast
- sufficiently large touch targets
- clear labels
- meaningful icons
- semantic buttons where appropriate

Do not communicate important information using color alone.

---

# 41. ANIMATION

Animations should be subtle.

Good uses:

- page transitions
- matching progress
- card expansion
- loading states
- success confirmation

Avoid excessive animations.

---

# 42. COMPONENT ARCHITECTURE

Create reusable components for:

- AppHeader
- SearchBar
- ServiceChip
- WorkerCard
- VerificationBadge
- RatingDisplay
- PrimaryButton
- SecondaryButton
- StatusBadge
- KPI Card
- BottomNavigation
- SectionHeader
- MapCard

Avoid duplicating UI implementations.

---

# 43. MOCK DATA

The prototype should use centralized mock data.

Example workers:

Rajesh Kumar
Master Electrician
4.8 rating
8 years
240 jobs

Anil Desai
Residential Electrician
4.5 rating
3 years
85 jobs

Use consistent data across:

- search
- worker profile
- matching
- booking
- active service
- feedback

This should make the prototype feel like one connected
application rather than unrelated screens.

---

# 44. PROTOTYPE PRIORITY

Priority order:

1. Application launches
2. Navigation works
3. Client flow works end-to-end
4. Worker flow works
5. Admin flow works
6. Stitch visual fidelity
7. Mock AI forecasting
8. Mock map
9. Animations
10. Production backend

Do not block progress on:

- production authentication
- real payments
- production maps
- real machine-learning infrastructure

These can be integrated later.

---

# 45. MOST IMPORTANT RULE

When implementing any screen:

FIRST understand the intended design.

SECOND follow this document.

THIRD preserve consistency with existing screens.

DO NOT invent a completely different design language.

DO NOT turn the application into a generic Material UI demo.

The final application should feel like ONE cohesive product.

Coorporate Gig should look like a polished cooperative
professional-services marketplace built specifically for India.
