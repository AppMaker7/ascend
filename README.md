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
Ascend includes an AI chat interface and a Supabase Edge Function at [supabase/functions/ascend-coach/index.ts](./supabase/functions/ascend-coach/index.ts). The function verifies the signed-in Supabase user and calls OpenAI server-side. The OpenAI API key is read only from the `OPENAI_API_KEY` Edge Function secret; it is never shipped to the browser.

### Enable the AI coach
1. In the Ascend Supabase project, open **Edge Functions** and create a function named `ascend-coach`.
2. Deploy the code from [supabase/functions/ascend-coach/index.ts](./supabase/functions/ascend-coach/index.ts). You can also deploy it with the Supabase CLI from the repository using `supabase functions deploy ascend-coach`.
3. In Supabase **Edge Function Secrets**, add `OPENAI_API_KEY` with your OpenAI API key as its value. Do not put the key in GitHub, the app, or this chat.
4. Confirm the Edge Function has JWT verification enabled. The repository's `supabase/config.toml` enables it.
5. Sign in to Ascend, open the Coach card, and choose **Ask AI coach**.

OpenAI API usage is billed separately from a ChatGPT subscription and may incur charges. Review API billing and usage limits with a parent or guardian before enabling paid API usage. Never share the API key.


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
