# Ascend

A mobile-first self-improvement RPG that combines habit building, focus tools, workout tracking, and personal progression.

## Current features
- Daily quests with XP rewards and the main Ascend rank ladder
- Automatic daily quest rollover and weekly habit check-in reset
- Activity-based streaks, seven-day momentum chart, and consistency milestones
- Focus sessions that award XP based on completed session length
- Add and remove quests and habits as routines change
- Habit check-ins and weekly rhythm indicators
- Focus timer (planning tool only; it does not block other Android apps)
- Personalized workout setup based on goals, experience, equipment, schedule, and session length
- Set-by-set workout logging with reps and optional dumbbell working weight
- Separate workout ranks, exercise LP, performance scores, and best logged results
- Workout history and seven-day activity overview
- Adaptive on-device coach insights based on quests, habits, and training history
- Supabase email/password accounts, private cloud saves, and username-based friends
- Mobile-first layout and PWA cache

## Coaching and AI status
The current coach uses transparent, on-device rules and the player's own logged data. It is **not connected to a live AI model yet**. A real AI coach must be called through a secure server-side function; any model API key must be stored as a server secret and must never be placed in browser code.

## Important limitations
- Workout sets, reps, and weights are manually logged; Ascend does not verify form or count repetitions with the camera.
- Workout scores are personal progress indicators, not medical measurements or comparisons against other people's bodies.
- Focus Mode is a timer and planning aid. A browser-based website cannot block or monitor other Android apps.
- Ascend is a general wellness tool, not a medical device or a substitute for qualified coaching or healthcare.

## Run
Open `index.html` in a browser or deploy the repository with GitHub Pages.

## Supabase setup
1. Create a separate Supabase project for Ascend.
2. Open the SQL Editor in that project.
3. Run the complete script in [supabase/schema.sql](./supabase/schema.sql).
4. In Supabase Authentication URL Configuration, set the Site URL to the deployed Ascend Pages URL and allow that same URL as a redirect.
5. Email confirmation may need to be completed before the first login.

The browser uses only the project's publishable key. Never put a database password or service-role key in this repository.
