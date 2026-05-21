GroupClassSchedule.delete_all
GroupClassPack.delete_all
GroupClass.delete_all
puts "delete all group classes"

tennis = Sport.find_by(name: "Tennis")
padel  = Sport.find_by(name: "Padel")
tennis_court = Court.joins(:sport).where(sports: { name: "Tennis" }).first
padel_court  = Court.joins(:sport).where(sports: { name: "Padel" }).first

private_lesson_desc = "Private lessons focus on the individual needs of an athlete. It is a one on one session with a coach. Sessions can be based on any of the game's 4 components, including Technical, Tactical, Physical and Psychological, depending on the players and coaches goals. Private lessons are the fastest way to improve and are recommended to accelerate the advanced player's tennis development."

# Private Session — Tennis (3 packs)
c = GroupClass.create!(
  name: "Private Session",
  sport: tennis,
  category: "private_lesson",
  price: 1750000,
  min_pax: 1,
  max_pax: 1,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: private_lesson_desc
)
GroupClassPack.create!(group_class: c, sessions_count: 1,  price: 1750000,  label: "1 Session")
GroupClassPack.create!(group_class: c, sessions_count: 5,  price: 8450000,  label: "5 Sessions")
GroupClassPack.create!(group_class: c, sessions_count: 10, price: 16400000, label: "10 Sessions")
puts "Create Group Class: #{c.name}"

# Semi-Private Lesson — Tennis
c = GroupClass.create!(
  name: "Semi-Private Lesson",
  sport: tennis,
  category: "private_lesson",
  price: 1950000,
  price_pax: 120000,
  min_pax: 2,
  max_pax: 5,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: "Semi-private tennis lessons offer a focused, personalized experience for two players, allowing both to work closely with a coach while benefiting from peer interaction. Sessions can be based on any of the game's 4 components, including Technical, Tactical, Physical and Psychological, depending on the players and coaches goals. Private lessons are the fastest way to improve and are recommended to accelerate the advanced player's tennis development."
)
puts "Create Group Class: #{c.name}"

group_class_desc = %q{
<p>
  <strong>RED STAGE:</strong> Elementary program that focuses on the basics of the game. Through partner based activities that utilise FPMS, students get to learn how tennis is played in a safe and social environment.
</p>
<p>
  Concentrates on:
</p>
<ul>
  <li>Spacial awareness</li>
  <li>Ball tracking skills</li>
  <li>Hand/eye coordination</li>
</ul>

<p><strong>ORANGE STAGE:</strong> Primary stage that considers athletic development and learning the skills of tennis. Understanding and practising specific strokes will be introduced to assist physical and mental development. Social and behavioural skills are taught to allow the students to know what it's like to be an athlete.</p>

<p>Concentrates on:</p>
<ul>
  <li>Basic technique fundamentals</li>
  <li>Knowledge of tennis rules</li>
  <li>Introduction to tactical fundamentals</li>
</ul>

<p>
  <strong>YELLOW STAGE:</strong> This stage is designed to accommodate teenage players who are wishing to continue their tennis development in a more social and recreational group environment.
</p>
<p>Concentrates on:</p>
<ul>
  <li>Intermediate to advanced technique</li>
  <li>Continuing Match tactical fundamentals</li>
  <li>Practice Routines</li>
  <li>Physical Training Tips</li>
</ul>
}

# Adult Group Class — Tennis
c = GroupClass.create!(
  name: "Adult Group Class",
  sport: tennis,
  category: "group_class",
  price: 1740000,
  price_pax: 580000,
  min_pax: 3,
  max_pax: 6,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: group_class_desc
)
puts "Create Group Class: #{c.name}"

# Child Group Class — Tennis
c = GroupClass.create!(
  name: "Child Group Class",
  sport: tennis,
  category: "group_class",
  price: 1760000,
  price_pax: 440000,
  min_pax: 4,
  max_pax: 8,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: group_class_desc
)
puts "Create Group Class: #{c.name}"

social_class_desc = "Players get to learn the sport in a social environment. From technique training to match play, our group classes provide a way for players to put their learning into practice with coaches and other players. This class ranges from beginners, intermediate to even family classes."

# Adult Premium Social Class — Tennis, prescheduled Monday 09:00–11:00
c = GroupClass.create!(
  name: "Adult Premium Social Class",
  sport: tennis,
  category: "social_class",
  price: 920000,
  price_pax: 460000,
  min_pax: 2,
  max_pax: 4,
  min_duration: 2,
  is_prescheduled: true,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: social_class_desc
)
GroupClassSchedule.create!(group_class: c, day_of_week: 1, start_time: "09:00", end_time: "11:00", court: tennis_court)
puts "Create Group Class: #{c.name}"

# Adult Super Social Class — Tennis, prescheduled Tuesday 09:00–11:00
c = GroupClass.create!(
  name: "Adult Super Social Class",
  sport: tennis,
  category: "social_class",
  price: 760000,
  price_pax: 380000,
  min_pax: 2,
  max_pax: 6,
  min_duration: 2,
  is_prescheduled: true,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: social_class_desc
)
GroupClassSchedule.create!(group_class: c, day_of_week: 2, start_time: "09:00", end_time: "11:00", court: tennis_court)
puts "Create Group Class: #{c.name}"

# Private Session Padel — Padel
c = GroupClass.create!(
  name: "Private Session Padel",
  sport: padel,
  category: "private_lesson",
  price: 1950000,
  min_pax: 1,
  max_pax: 1,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: "Private Padel lessons offer focused, one-on-one coaching tailored to your individual game. Work with an experienced coach to develop your technique, footwork, and strategy on the Padel court."
)
GroupClassPack.create!(group_class: c, sessions_count: 1, price: 1950000, label: "1 Session")
GroupClassPack.create!(group_class: c, sessions_count: 5, price: 2750000, label: "5 Sessions")
puts "Create Group Class: #{c.name}"

# Ladies Night CLass — Padel, prescheduled Friday 16:00–17:00
c = GroupClass.create!(
  name: "Ladies Night CLass",
  sport: padel,
  category: "group_class",
  price: 1000000,
  price_pax: 850000,
  min_pax: 4,
  max_pax: 12,
  min_duration: 1,
  is_prescheduled: true,
  notes: "Prices are inclusive of court fee, service fee and applicable taxes",
  description: "Join us every Friday evening for Ladies Night Padel — a fun and social session open to female players of all levels. Enjoy friendly games, coaching tips, and great company on the court."
)
GroupClassSchedule.create!(group_class: c, day_of_week: 5, start_time: "16:00", end_time: "17:00", court: padel_court)
puts "Create Group Class: #{c.name}"
