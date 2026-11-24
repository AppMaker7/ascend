# Ascend

A sleek, mobile-first self-improvement dashboard prototype.

## Included
- Daily quests with XP rewards and progress tracking
- Rank progression and lifetime XP
- Habit list with weekly check-in indicators
- Focus timer
- Responsive mobile-first layout
- Local browser persistence and basic PWA setup

## Current limitations
This is a browser-based prototype. It does not yet create accounts, sync data between devices, block Android apps, or verify push-ups with the camera. Actual Android app blocking requires a native Android companion app and user-granted permissions. Camera-based exercise tracking is a separate feature to implement and test carefully.

## Run
Open index.html in a browser or deploy the repository with GitHub Pages.


## Accounts and friends
- Supabase email/password sign-up and login
- Username-based friend requests and rank comparison
- Private per-user cloud save through a server-validated RPC
- Row Level Security policies for profiles, player data, friend requests, and friendships

### Supabase setup
1. Create a separate Supabase project for Ascend.
2. Open the SQL Editor in that project.
3. Run the complete script in [supabase/schema.sql](./supabase/schema.sql).
4. In Supabase Authentication URL Configuration, set the Site URL to the deployed Ascend Pages URL and allow that same URL as a redirect.
5. Email confirmation may need to be completed before the first login.

The browser uses only the project's publishable key. Never put a database password or service-role key in this repository.
