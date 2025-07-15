GroupClass.delete_all
puts "delete all group class"

# GroupClass Private Session
c = GroupClass.new(name: "Private Session (1 Session)")
c.price = 1750000
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = "Private lessons focus on the individual needs of an athlete. It is a one on one session with a coach. Sessions can be based on any of the game’s 4 components, including Technical, Tactical, Physical and Psychological, depending on the players and coaches goals. Private lessons are the fastest way to improve and are recommended to accelerate the advanced player’s tennis development."
c.save
puts "Create Group Class: #{c.name}"

c = GroupClass.new(name: "Private Session (5 Session)")
c.price = 8450000
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = "Private lessons focus on the individual needs of an athlete. It is a one on one session with a coach. Sessions can be based on any of the game’s 4 components, including Technical, Tactical, Physical and Psychological, depending on the players and coaches goals. Private lessons are the fastest way to improve and are recommended to accelerate the advanced player’s tennis development."
c.save
puts "Create Group Class: #{c.name}"

c = GroupClass.new(name: "Private Session (10 Session)")
c.price = 16400000
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = "Private lessons focus on the individual needs of an athlete. It is a one on one session with a coach. Sessions can be based on any of the game’s 4 components, including Technical, Tactical, Physical and Psychological, depending on the players and coaches goals. Private lessons are the fastest way to improve and are recommended to accelerate the advanced player’s tennis development."
c.save
puts "Create Group Class: #{c.name}"

# GroupClass Semi-Private
c = GroupClass.new(name: "Semi-Private Lesson")
c.price = 1950000
c.price_pax = 120000
c.min_pax = 2
c.max_pax = 5
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = "Semi-private tennis lessons offer a focused, personalized experience for two players, allowing both to work closely with a coach while benefiting from peer interaction. Sessions can be based on any of the game’s 4 components, including Technical, Tactical, Physical and Psychological, depending on the players and coaches goals. Private lessons are the fastest way to improve and are recommended to accelerate the advanced player’s tennis development."
c.save
puts "Create Group Class: #{c.name}"

# GroupClass Group Class
c = GroupClass.new(name: "Adult Group Class")
c.price = 1740000
c.price_pax = 580000
c.min_pax = 3
c.max_pax = 6
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = %q{
<p>
  <strong>RED STAGE:</strong> Elementary program that focuses on the basics of the game. Through partner based activities that utilise FPMS, students get to learn how tennis is played in a safe and social environment.
</p>
<p>
  Concentrates on:
</p>
<ul>
  <li>
    Spacial awareness
  </li>
  <li>
    Ball tracking skills
  </li>
  <li>
    Hand/eye coordination
  </li>
</ul>

<p><strong>ORANGE STAGE:</strong> Primary stage that considers athletic development and learning the skills of tennis. Understanding and practising specific strokes will be introduced to assist physical and mental development. Social and behavioural skills are taught to allow the students to know what it’s like to be an athlete.</p>

<p>
  Concentrates on:
</p>

<ul>
  <li>
    Basic technique fundamentals
  </li>

  <li>
    Knowledge of tennis rules
  </li>

  <li>
    Introduction to tactical fundamentals
  </li>
</ul>

<p>
  <strong>YELLOW STAGE:</strong> This stage is designed to accommodate teenage players who are wishing to continue their tennis development in a more social and recreational group environment.
</p>
<p>
  Concentrates on:
</p>
<ul>
  <li>
    Intermediate to advanced technique
  </li>
  <li>
    Continuing Match tactical fundamentals
  </li>
  <li>
    Practice Routines
  </li>
  <li>
    Physical Training Tips
  </li>
</ul>
}
c.save
puts "Create Group Class: #{c.name}"

# GroupClass Group Class
c = GroupClass.new(name: "Child Group Class")
c.price = 1760000
c.price_pax = 440000
c.min_pax = 4
c.max_pax = 8
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = %q{
<p>
  <strong>RED STAGE:</strong> Elementary program that focuses on the basics of the game. Through partner based activities that utilise FPMS, students get to learn how tennis is played in a safe and social environment.
</p>
<p>
  Concentrates on:
</p>
<ul>
  <li>
    Spacial awareness
  </li>
  <li>
    Ball tracking skills
  </li>
  <li>
    Hand/eye coordination
  </li>
</ul>

<p><strong>ORANGE STAGE:</strong> Primary stage that considers athletic development and learning the skills of tennis. Understanding and practising specific strokes will be introduced to assist physical and mental development. Social and behavioural skills are taught to allow the students to know what it’s like to be an athlete.</p>

<p>
  Concentrates on:
</p>

<ul>
  <li>
    Basic technique fundamentals
  </li>

  <li>
    Knowledge of tennis rules
  </li>

  <li>
    Introduction to tactical fundamentals
  </li>
</ul>

<p>
  <strong>YELLOW STAGE:</strong> This stage is designed to accommodate teenage players who are wishing to continue their tennis development in a more social and recreational group environment.
</p>
<p>
  Concentrates on:
</p>
<ul>
  <li>
    Intermediate to advanced technique
  </li>
  <li>
    Continuing Match tactical fundamentals
  </li>
  <li>
    Practice Routines
  </li>
  <li>
    Physical Training Tips
  </li>
</ul>
}
c.save
puts "Create Group Class: #{c.name}"

# GroupClass Adult Social Class
c = GroupClass.new(name: "Adult Premium Social Class")
c.price = 920000
c.price_pax = 460000
c.min_duration = 2
c.min_pax = 2
c.max_pax = 4
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = "Players get to learn the sport in a social environment. From technique training to match play, our group classes provide a way for players to put their learning into practice with coaches and other players. This class ranges from beginners, intermediate to even family classes."
c.save
puts "Create Group Class: #{c.name}"

# GroupClass Adult Social Class
c = GroupClass.new(name: "Adult Super Social Class")
c.price = 760000
c.price_pax = 380000
c.min_duration = 2
c.min_pax = 2
c.max_pax = 6
c.notes = "Prices are inclusive of court fee, service fee and applicable taxes"
c.description = "Players get to learn the sport in a social environment. From technique training to match play, our group classes provide a way for players to put their learning into practice with coaches and other players. This class ranges from beginners, intermediate to even family classes."
c.save
puts "Create Group Class: #{c.name}"
