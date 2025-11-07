# Personalized Picks Feature

**Status:** ✅ Fully Implemented

## What We Built

A media recommendation system that uses Apple Foundation Models to generate personalized, contextual "picks" for each profile - think Netflix hero content, but actually smart.

## The Core Idea

Instead of showing generic "trending" or "popular" content, each profile gets **ONE perfect recommendation** based on:

1. **Their Profile Description** - Natural language description of their taste, patterns, and preferences
2. **Current Context** - What day/time it is (Friday 11pm vs Tuesday 10am)
3. **Watch History** - What they've been watching recently
4. **Available Library** - What's actually ready to stream

### Example Profile Description

```
Kate loves reality TV like Real Housewives and The Bachelor, which she has on
in the background while doing laundry or dishes (usually weekday mornings around
10am). She's also obsessed with Halloween - from late September through November,
she gravitates toward spooky content like Practical Magic, Hocus Pocus, and true
crime documentaries. Friday nights are sacred: she and her husband watch Dateline
NBC together at 11pm without fail. She avoids anything too intense or violent
unless it's true crime. Comfort shows like The Office get heavy rotation when
she needs to wind down.
```

### What Kate Gets

**Tuesday 10am:**

```json
{
  "caption": "Perfect background while doing morning tasks",
  "media": {
    "type": "tv_episode",
    "title": "The Real Housewives of Beverly Hills - S12E03"
  }
}
```

**October 15th, 8pm:**

```json
{
  "caption": "Getting into Halloween spirit 🎃",
  "media": {
    "type": "movie",
    "title": "Practical Magic"
  }
}
```

**Friday 11pm:**

```json
{
  "caption": "New episode of your Friday night tradition",
  "media": {
    "type": "tv_episode",
    "title": "Dateline NBC - Latest Episode"
  }
}
```

## What We Created

### 1. Database Schema

**Migration:** `db/migrate/20251106000001_create_picks.rb`

```ruby
create_table :picks do |t|
  t.references :profile
  t.references :pickable, polymorphic: true  # Movie, TvEpisode, TvShow
  t.string :caption
  t.jsonb :reasoning
  t.jsonb :context_snapshot
  t.datetime :generated_at
  t.datetime :expires_at
end
```

**Migration:** `db/migrate/20251106000002_add_description_to_profiles.rb`

```ruby
add_column :profiles, :description, :text
```

### 2. Model

**File:** `app/models/pick.rb`

```ruby
class Pick < ApplicationRecord
  belongs_to :profile
  belongs_to :pickable, polymorphic: true

  scope :current, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }

  def self.current_for(profile)
    for_profile(profile).current.first
  end
end
```

### 3. Swift Schema

**File:** `app/workflows/schemas/swift/PickRecommendation.swift`

Defines the structured output from the LLM:

```swift
@Generable
struct PickRecommendation: Codable {
    let type: MediaType      // Movie, TvEpisode, or TvShow
    let id: Int             // Database ID
    let caption: String     // "Perfect Friday night comfort watch"
}
```

### 4. LLM Workflow

**File:** `app/workflows/generate_pick.yml`

An Auto workflow that:

1. Loads the profile and validates it has a description
2. Fetches available media library (movies, shows, episodes)
3. Gets recent watch history
4. Sends everything to Apple's Foundation Models
5. Creates the Pick record with the LLM's recommendation

### 5. API Controller

**File:** `app/controllers/api/picks_controller.rb`

Endpoints:

- `GET /api/profiles/:id/pick` - Get current pick
- `POST /api/profiles/:id/pick/generate` - Generate new pick
- `DELETE /api/profiles/:id/pick` - Expire current pick
- `GET /api/profiles/:id/picks/history` - View past picks

### 6. Jbuilder Views

**Files:**

- `app/views/api/picks/_pick.json.jbuilder`
- `app/views/api/picks/show.json.jbuilder`
- `app/views/api/picks/index.json.jbuilder`

### 7. Routes

Added to `config/routes.rb`:

```ruby
resources :profiles do
  member do
    get 'pick', to: 'picks#show'
    post 'pick/generate', to: 'picks#generate'
    delete 'pick', to: 'picks#destroy'
    get 'picks/history', to: 'picks#history'
  end
end
```

## How to Use It

### 1. Run Migrations

```bash
bin/rails db:migrate
```

### 2. Add Profile Description

```bash
bin/rails console
```

```ruby
profile = Profile.first
profile.update(description: <<~DESC)
  Kate loves reality TV like Real Housewives and The Bachelor, which she has on
  in the background while doing laundry or dishes (usually weekday mornings around
  10am). She's also obsessed with Halloween - from late September through November,
  she gravitates toward spooky content like Practical Magic, Hocus Pocus, and true
  crime documentaries. Friday nights are sacred: she and her husband watch Dateline
  NBC together at 11pm without fail.
DESC
```

### 3. Generate a Pick

**Via API:**

```bash
curl -X POST http://localhost:3000/api/profiles/1/pick/generate
```

**Via Rails Console:**

```ruby
workflow = Auto::Workflow.create!(
  workflow_id: 'generate_pick',
  args: { profile_id: 1 }
)

# Wait for it to complete
sleep 5

# View the pick
Pick.current_for(Profile.first)
```

### 4. View the Pick

**Via API:**

```bash
curl http://localhost:3000/api/profiles/1/pick
```

**Response:**

```json
{
  "id": 1,
  "caption": "Perfect Friday night comfort watch",
  "generated_at": "2025-11-06T20:30:00Z",
  "expires_at": null,
  "media": {
    "type": "movie",
    "id": 45,
    "title": "Practical Magic",
    "year": 1998,
    "overview": "Two witch sisters...",
    "poster_path": "/abc123.jpg"
  }
}
```

## Architecture Decisions

### Why "Pick" instead of "Featured" or "Spotlight"?

✅ **Media-focused** - Won't clash with email/calendar features  
✅ **Clearly singular** - One item, not a collection  
✅ **Personal** - "Your pick", "Kate's pick"  
✅ **Clean polymorphic** - `belongs_to :pickable`

### Why Polymorphic Association?

The LLM can recommend:

- **Movie** - A single film
- **TvEpisode** - Specific episode (great for series you're watching)
- **TvShow** - Entire series (suggesting to start/binge it)
- **Future:** Collection, Album, Playlist

### Why Store the Pick?

Instead of generating on-the-fly:

1. **Performance** - LLM calls take 5-10 seconds
2. **Consistency** - Same pick shown across app refreshes
3. **Analytics** - Track what was recommended and when
4. **History** - See past picks
5. **Debugging** - Inspect reasoning

### Why Expire Instead of Delete?

Soft-delete pattern:

- Track pick history
- Analytics on what worked/didn't
- User can see "You dismissed this yesterday"

## Client Integration

### TV App Hero Section

```javascript
async function loadHero(profileId) {
  const response = await fetch(`/api/profiles/${profileId}/pick`);

  if (response.status === 404) {
    // No pick exists, generate one
    const newPick = await fetch(`/api/profiles/${profileId}/pick/generate`, {
      method: "POST",
    });
    return await newPick.json();
  }

  return await response.json();
}

const hero = await loadHero(profile.id);
displayHero({
  title: hero.media.title,
  caption: hero.caption,
  backdrop: hero.media.backdrop_path,
});
```

### Smart Refresh

```javascript
// Refresh pick if:
// - Older than 6 hours
// - Different time context (morning -> evening)
// - User explicitly requests

function shouldRefresh(pick) {
  const age = Date.now() - new Date(pick.generated_at);
  return age > 6 * 60 * 60 * 1000; // 6 hours
}
```

## What's Next

### Phase 2: Collections

When you implement collections:

```swift
enum MediaType: String, Codable {
    case Movie
    case TvEpisode
    case TvShow
    case Collection  // New!
}
```

The LLM can then recommend:

```json
{
  "type": "Collection",
  "id": 123,
  "caption": "Your Halloween favorites in one place"
}
```

### Phase 3: Purchase Recommendations

Use the same profile system to recommend content to buy:

```ruby
# app/workflows/suggest_purchases.yml
# Analyzes all family profiles + current library
# Recommends what to add
```

### Phase 4: Multi-Domain

Extend to other media:

- Music picks (albums, playlists)
- Reading picks (books, articles)
- Podcast picks

## Testing the Feature

### Unit Tests

```ruby
# test/models/pick_test.rb
test "current scope only returns non-expired picks" do
  current_pick = picks(:current)
  expired_pick = picks(:expired)

  assert_includes Pick.current, current_pick
  refute_includes Pick.current, expired_pick
end
```

### Integration Test

```ruby
# test/controllers/api/picks_controller_test.rb
test "generate creates new pick via workflow" do
  profile = profiles(:kate)
  profile.update(description: "Loves reality TV...")

  post generate_api_profile_pick_url(profile)
  assert_response :created

  pick = Pick.current_for(profile)
  assert_not_nil pick
  assert_not_nil pick.pickable
  assert pick.caption.present?
end
```

### Manual Testing

```bash
# Start server
bin/dev

# Generate pick
curl -X POST http://localhost:3000/api/profiles/1/pick/generate

# View pick
curl http://localhost:3000/api/profiles/1/pick

# Expire pick
curl -X DELETE http://localhost:3000/api/profiles/1/pick

# View history
curl http://localhost:3000/api/profiles/1/picks/history
```

## Files Created

```
db/migrate/
  20251106000001_create_picks.rb
  20251106000002_add_description_to_profiles.rb

app/models/
  pick.rb

app/workflows/
  generate_pick.yml
  schemas/swift/
    PickRecommendation.swift

app/controllers/api/
  picks_controller.rb

app/views/api/picks/
  _pick.json.jbuilder
  show.json.jbuilder
  index.json.jbuilder

config/
  routes.rb (updated)

docs/
  PICKS_API.md
  PICKS_FEATURE.md (this file)
```

## Documentation

- **[PICKS_API.md](PICKS_API.md)** - Complete API reference with examples
- **[JBUILDER_GUIDE.md](JBUILDER_GUIDE.md)** - View templates guide
- **This file** - Feature overview and architecture

---

**Built with:** Rails 8, Apple Foundation Models, Auto Workflows  
**Date:** November 6, 2025  
**Status:** Ready for migration & testing
